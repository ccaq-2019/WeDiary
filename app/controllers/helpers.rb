# frozen_string_literal: true

module CoEditPDF
  # Methods for controllers to mixin
  module SecureRequestHelpers
    def secure_request?(routing)
      routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end

    def authorization(headers)
      return nil unless headers['Authorization']

      scheme, auth_token = headers['Authorization'].split(' ')
      return nil unless scheme.match?(/^Bearer$/i)

      contents = AuthToken.contents(auth_token)
      account_data = contents['payload']['attributes']

      { account: Account.first(name: account_data['name']),
        scope: AuthScope.new(contents['scope']) }
    end
  end
end
