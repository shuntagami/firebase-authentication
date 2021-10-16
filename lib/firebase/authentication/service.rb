require "json"
require "net/http"
require "rails"
require "uri"
require_relative "config"

module Firebase
  module Authentication
    # A Ruby wrapper for Firebase REST API
    #
    # Query the Firebase Auth backend through a REST API
    #
    # @example
    #   require "firebase/authentication"
    #
    #   service = Firebase::Authentication::Service.new(ENV['API_KEY'])
    #   service.sign_up(email, password)
    #
    # @see https://firebase.google.com/docs/reference/rest/auth
    class Service
      def initialize(api_key, logger = Rails.logger)
        @logger = logger
        @api_key = api_key
      end

      # Change a user's email.
      # @param [String] token
      #   A Firebase Auth ID token for the user.
      # @param [String] email
      #   The user's new email.
      #
      # @return [Net::HTTPOK]
      #
      # @raise [Net::HTTPRetriableError] An error occurred on the server and the request can be retried
      # @raise [Net::HTTPServerException] The request is invalid and should not be retried without modification
      # @raise [Net::HTTPFatalError] An internal server error occurred
      #
      # @see https://firebase.google.com/docs/reference/rest/auth#section-change-email
      def change_email(token, email)
        res = fetch(:post, Config::UPDATE_ACCOUNT_INFO, { idToken: token, email: email, returnSecureToken: true })
        res.value
        res
      end

      # Change a user's password.
      # @param [String] token
      #   A Firebase Auth ID token for the user.
      # @param [String] password
      #   The user's new password.
      #
      # @return [Net::HTTPOK]
      #
      # @raise [Net::HTTPRetriableError] An error occurred on the server and the request can be retried
      # @raise [Net::HTTPServerException] The request is invalid and should not be retried without modification
      # @raise [Net::HTTPFatalError] An internal server error occurred
      #
      # @see https://firebase.google.com/docs/reference/rest/auth#section-change-password
      def change_password(token, password)
        res = fetch(:post, Config::UPDATE_ACCOUNT_INFO, { idToken: token, passsord: password, returnSecureToken: true })
        res.value
        res
      end

      # Delete a user.
      # @param [String] token
      #   The Firebase ID token of the user to delete.
      #
      # @return [Net::HTTPOK]
      #
      # @raise [Net::HTTPRetriableError] An error occurred on the server and the request can be retried
      # @raise [Net::HTTPServerException] The request is invalid and should not be retried without modification
      # @raise [Net::HTTPFatalError] An internal server error occurred
      #
      # @see https://firebase.google.com/docs/reference/rest/auth#section-delete-account
      def delete_account(token)
        res = fetch(:post, Config::DELETE_ACCOUNT, { idToken: token })
        res.value
        res
      end

      # Exchange a custom Auth token for an ID and refresh token
      # @param [String] token
      #   A Firebase Auth custom token from which to create an ID and refresh token pair.
      #
      # @return [Net::HTTPOK]
      #
      # @raise [Net::HTTPRetriableError] An error occurred on the server and the request can be retried
      # @raise [Net::HTTPServerException] The request is invalid and should not be retried without modification
      # @raise [Net::HTTPFatalError] An internal server error occurred
      #
      # @see https://firebase.google.com/docs/reference/rest/auth#section-verify-custom-token
      def exchange_custom_token(token)
        res = fetch(:post, Config::VERIFY_CUSTOM_TOKEN, { idToken: token, returnSecureToken: true })
        res.value
        res
      end

      # Get a user's data
      # @param [String] token
      #   The Firebase ID token of the account.
      #
      # @return [Net::HTTPOK]
      #
      # @raise [Net::HTTPRetriableError] An error occurred on the server and the request can be retried
      # @raise [Net::HTTPServerException] The request is invalid and should not be retried without modification
      # @raise [Net::HTTPFatalError] An internal server error occurred
      #
      # @see https://firebase.google.com/docs/reference/rest/auth#section-get-account-info
      def get_account_info(token)
        res = fetch(:post, Config::GET_ACCOUNT_INFO, { idToken: token })
        res.value
        res
      end

      # Send a password reset email.
      # @param [String] email
      #   User's email address.
      #
      # @return [Net::HTTPOK]
      #
      # @raise [Net::HTTPRetriableError] An error occurred on the server and the request can be retried
      # @raise [Net::HTTPServerException] The request is invalid and should not be retried without modification
      # @raise [Net::HTTPFatalError] An internal server error occurred
      #
      # @see https://firebase.google.com/docs/reference/rest/auth#section-send-password-reset-email
      def send_password_reset_email(email)
        res = fetch(:post, Config::RESET_PASSWORD, { requestType: "PASSWORD_RESET", email: email })
        res.value
        res
      end

      # Signin a user.
      # @param [String] email
      #   The email the user is signing in with.
      # @param [String] password
      #   The password for the account.
      #
      # @return [Net::HTTPOK]
      #
      # @raise [Net::HTTPRetriableError] An error occurred on the server and the request can be retried
      # @raise [Net::HTTPServerException] The request is invalid and should not be retried without modification
      # @raise [Net::HTTPFatalError] An internal server error occurred
      #
      # @see https://firebase.google.com/docs/reference/rest/auth#section-sign-in-email-password
      def sign_in_email(email, password)
        res = fetch(:post, Config::SIGN_IN_EMAIL, { email: email, passsord: password, returnSecureToken: true })
        res.value
        res
      end

      # Signup new user.
      # @param [String] email
      #   The email for the user to create.
      # @param [String] password
      #   The password for the user to create.
      #
      # @return [Net::HTTPOK]
      #
      # @raise [Net::HTTPRetriableError] An error occurred on the server and the request can be retried
      # @raise [Net::HTTPServerException] The request is invalid and should not be retried without modification
      # @raise [Net::HTTPFatalError] An internal server error occurred
      #
      # @see https://firebase.google.com/docs/reference/rest/auth#section-create-email-password
      def sign_up(email, password)
        res = fetch(:post, Config::SIGN_UP_EMAIL, { email: email, password: password, returnSecureToken: true })
        res.value
        res
      end

      private

      def fetch(verb, path, body = nil)
        uri = URI.parse(Config::BASE_URI + path + @api_key)
        request = case verb
                  when :get
                    Net::HTTP::Get.new(uri)
                  when :post
                    Net::HTTP::Post.new(uri)
                  end
        request.content_type = "application/json"
        request.body = JSON.dump(body)
        Net::HTTP.start(uri.host, uri.port, { use_ssl: true }) do |http|
          http.request(request)
        end
      end
    end
  end
end
