require_relative "authentication/version"
require_relative "authentication/service"

module Firebase
  module Authentication
    ALGORITHM = "RS256".freeze
    ISSUER_BASE_URL = "https://securetoken.google.com/".freeze
    CLIENT_CERT_URL = "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com".freeze

    class << self
      def verify(token)
        Rails.logger.info "#{self.class.name}\##{__method__} called."
        Rails.logger.info token
        raise "id token must be a String" unless token.is_a?(String)

        full_decoded_token = _decode_token(token)

        err_msg = _validate_jwt(full_decoded_token)
        raise err_msg if err_msg

        public_key = _fetch_public_keys[full_decoded_token[:header]["kid"]]
        unless public_key
          raise 'Firebase ID token has "kid" claim which does not correspond to a known public key.'\
                "Most likely the ID token is expired, so get a fresh token from your client app and try again."
        end

        certificate = OpenSSL::X509::Certificate.new(public_key)
        decoded_token = _decode_token(token, certificate.public_key, verify: true, options: { algorithm: ALGORITHM, verify_iat: true })

        {
          "uid" => decoded_token[:payload]["sub"],
          "decoded_token" => decoded_token
        }
      end

      def create_custom_token(uid, claims = {})
        private_key = OpenSSL::PKey::RSA.new Global.firebase.private_key.gsub('\\n', "\n")
        service_account_email = Global.firebase.client_email
        now_seconds = Time.now.to_i
        payload = { iss: service_account_email,
                    sub: service_account_email,
                    aud: "https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit",
                    iat: now_seconds,
                    exp: now_seconds + (60 * 60),
                    uid: uid,
                    claims: claims }
        JWT.encode payload, private_key, "RS256"
      end

      private

      def _decode_token(token, key = nil, verify: false, options: {})
        Rails.logger.info "#{self.class.name}\##{__method__} called."
        begin
          decoded_token = JWT.decode(token, key, verify, options)
        rescue JWT::ExpiredSignature => e
          raise "Firebase ID token has expired. Get a fresh token from your client app and try again. #{e.message}"
        rescue JWT::InvalidAudError, JWT::DecodeError, JWT::VerificationError => e
          raise "Firebase JWT Error. #{e.message}"
        rescue StandardError => e
          raise "Firebase ID token has invalid signature. #{e.message}"
        end

        {
          payload: decoded_token[0],
          header: decoded_token[1]
        }
      end

      def _fetch_public_keys
        Rails.logger.info "#{self.class.name}\##{__method__} called."
        uri = URI.parse(CLIENT_CERT_URL)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true

        res = https.start do
          https.get(uri.request_uri)
        end
        data = JSON.parse(res.body)

        if data["error"]
          msg = "Error fetching public keys for Google certs: #{data["error"]}"
          msg += " (#{res["error_description"]})" if data["error_description"]

          raise msg
        end

        data
      end

      def _validate_jwt(json)
        Rails.logger.info "#{self.class.name}\##{__method__} called."
        error = _validate_jwt_header(json[:header])
        error || _validate_jwt_payload(json[:payload])
      end

      def _validate_jwt_header(header)
        Rails.logger.info "#{self.class.name}\##{__method__} called."
        return 'Firebase ID token has no "kid" claim.' unless header["kid"]

        return "Firebase ID token has incorrect algorithm. Expected \"#{ALGORITHM}\" but got \"#{header["alg"]}\"."\
        unless header["alg"] == ALGORITHM
      end

      def _validate_jwt_payload(payload)
        Rails.logger.info "#{self.class.name}\##{__method__} called."
        project_id = ENV.fetch("FIREBASE_PROJECT_ID")
        unless payload["aud"] == project_id
          return "Firebase ID token has incorrect \'aud\' (audience) claim. Expected \"#{project_id}\" but got \"#{payload["aud"]}\"."
        end

        issuer = ISSUER_BASE_URL + project_id
        unless payload["iss"] == issuer
          return "Firebase ID token has incorrect \'iss\' (issuer) claim. Expected \"#{issuer}\" but got \"#{payload["iss"]}\"."
        end

        return 'Firebase ID token has no "sub" (subject) claim.' unless payload["sub"].is_a?(String)
        return 'Firebase ID token has an empty string "sub" (subject) claim.' if payload["sub"].empty?
        return 'Firebase ID token has "sub" (subject) claim longer than 128 characters.' if payload["sub"].size > 128
      end
    end
  end
end
