# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AuthenticateAccount service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      CoEditPDF::Account.create(account_data)
    end
  end

  it 'HAPPY: should authenticate valid account credentials' do
    credentials = DATA[:accounts].first
    account = CoEditPDF::AuthenticateAccount.call(
      name: credentials['name'], password: credentials['password']
    )
    _(account).wont_be_nil
  end

  it 'SAD: will not authenticate with invalid password' do
    credentials = DATA[:accounts].first
    proc {
      CoEditPDF::AuthenticateAccount.call(
        name: credentials['name'], password: 'malword'
      )
    }.must_raise CoEditPDF::AuthenticateAccount::UnauthorizedError
  end

  it 'BAD: will not authenticate with invalid credentials' do
    proc {
      CoEditPDF::AuthenticateAccount.call(
        name: 'maluser', password: 'malword'
      )
    }.must_raise CoEditPDF::AuthenticateAccount::UnauthorizedError
  end
end
