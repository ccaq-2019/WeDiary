# frozen_string_literal: true

module CoEditPDF
  # Authorize Account
  class AuthorizeAccount
    # Error if requesting to see forbidden account
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that account'
      end
    end

    def self.call(auth:, name:, auth_scope:)
      account = Account.first(name: name)
      policy = AccountPolicy.new(auth[:account], account)

      raise ForbiddenError unless policy.can_view?

      account_and_token(account, auth_scope)
    end

    def self.account_and_token(account, auth_scope)
      {
        type:       'authorized_account',
        attributes: {
          account:    account,
          auth_token: AuthToken.create(account, auth_scope)
        }
      }
    end
  end
end
