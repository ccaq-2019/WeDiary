# frozen_string_literal: true

require 'roda'
require_relative './app'

module CoEditPDF
  # Web controller for CoEditPDF API
  class Api < Roda
    accounts = Account.where(id: :$find_id)

    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      routing.on String do |account_id| # TODO: change id to name
        # TODO: will this be called?
        # GET api/v1/accounts/[account_id]
        routing.get do
          # rubocop:disable Style/UnneededInterpolation
          account = accounts.call(:first, find_id: "#{account_id}")
          # rubocop:enable Style/UnneededInterpolation
          account ? account.to_json : raise('Account not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # POST api/v1/accounts
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_account = Account.create(new_data)
        raise('Could not save account') unless new_account

        response.status = 201
        # TODO: change id to name
        response['Location'] = "#{@account_route}/#{new_account.id}"
        { message: 'Account saved', data: new_account }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => e
        puts e.inspect
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
