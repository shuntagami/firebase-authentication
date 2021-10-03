# frozen_string_literal: true

module Firebase
  module Authentication
    module Config
      BASE_URI = "https://identitytoolkit.googleapis.com/v1/accounts:"

      GET_ACCOUNT_INFO = "lookup?key="
      DELETE_ACCOUNT = "delete?key="
      FETCH_PROVIDERS_FOR_EMAIL = "createAuthUri?key="
      RESET_PASSWORD = "sendOobCode?key="
      SIGN_IN_EMAIL = "signInWithPassword?key="
      SIGN_IN_OAUTH = "signInWithIdp?key="
      SIGN_UP_EMAIL = "signUp?key="
      UPDATE_ACCOUNT_INFO = "update?key="
    end
  end
end
