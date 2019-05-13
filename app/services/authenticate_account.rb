# frozen_string_literal: true

module CoEditPDF
  # Error for invalid credentials
  class UnauthorizedError < StandardError
    def initialize(msg = nil)
      @credentials = msg
    end

    def message
      "Invalid Credentials for: #{@credentials[:username]}"
    end
  end

  # Find account and check password
  class AuthenticateAccount
    def self.call(credentials)
      account = Account.first(name: credentials[:name])
      account.password?(credentials[:password]) ? account : raise
    rescue StandardError
      raise UnauthorizedError, credentials
    end
  end
end
