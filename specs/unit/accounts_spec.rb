# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Accounts Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      CoEditPDF::Account.create(account_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    account_data = DATA[:accounts][0]
    account = CoEditPDF::Account.first

    _(account.email).must_equal account_data['email']
    _(account.name).must_equal account_data['name']
  end

  it 'SECURITY: should not use deterministic integers' do
    account = CoEditPDF::Account.first

    _(account.id).wont_be_instance_of Integer
    _(proc { account.id - account.id }).must_raise NoMethodError
  end

  it 'SECURITY: should secure sensitive attributes' do
    account = CoEditPDF::Account.first
    stored_account = app.DB[:accounts].first

    _(stored_account[:email_secure]).wont_equal account.email
  end
end
