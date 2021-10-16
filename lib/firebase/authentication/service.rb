require "json"
require "net/http"
require "rails"
require "uri"
require_relative "config"

module Firebase
  module Authentication
    class Service
      def initialize(api_key, logger = Rails.logger)
        @logger = logger
        @api_key = api_key
      end

      def change_email(token, email)
        res = fetch(:post, Config::UPDATE_ACCOUNT_INFO, { idToken: token, email: email, returnSecureToken: true })
        res.value
        res
      end

      def change_password(token, password)
        res = fetch(:post, Config::UPDATE_ACCOUNT_INFO, { idToken: token, passsord: password, returnSecureToken: true })
        res.value
        res
      end

      def delete_account(token)
        res = fetch(:post, Config::DELETE_ACCOUNT, { idToken: token })
        res.value
        res
      end

      def exchange_custom_token(token)
        res = fetch(:post, Config::VERIFY_CUSTOM_TOKEN, { idToken: token, returnSecureToken: true })
        res.value
        res
      end

      def get_account_info(token)
        res = fetch(:post, Config::GET_ACCOUNT_INFO, { idToken: token })
        res.value
        res
      end

      def send_password_reset_email(email)
        res = fetch(:post, Config::RESET_PASSWORD, { requestType: "PASSWORD_RESET", email: email })
        res.value
        res
      end

      def sign_in_email(email, password)
        res = fetch(:post, Config::SIGN_IN_EMAIL, { email: email, passsord: password, returnSecureToken: true })
        res.value
        res
      end

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
