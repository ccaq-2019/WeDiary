# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Account Handling' do
  include Rack::Test::Methods

  before do
    header 'CONTENT_TYPE', 'application/json'
    wipe_database
  end

  describe 'Getting account information' do
    it 'HAPPY: should be able to get details of a single account' do
      account_data = DATA[:accounts][1]
      account = CoEditPDF::Account.create(account_data)

      header 'Authorization', auth_header(account_data)
      get "/api/v1/accounts/#{account.name}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']['attributes']
      account_data = result['account']['attributes']
      _(account_data['id']).must_equal account.id
      _(account_data['name']).must_equal account.name
      _(account_data['email']).must_equal account.email
      _(account_data['salt']).must_be_nil
      _(account_data['password']).must_be_nil
      _(account_data['password_hash']).must_be_nil
      _(result['auth_token']).wont_be_nil
    end

    it 'SAD: should return error if unknown account requested' do
      get '/api/v1/accounts/foobar'

      _(last_response.status).must_equal 403
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      CoEditPDF::Account.create(
        name: 'New Account', email: 'account1@mail.com'
      )
      CoEditPDF::Account.create(
        name: 'Newer Account', email: 'account2@mail.com'
      )
      get 'api/v1/accounts/2%20or%20id%3E0' # 2 or id > 0

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 403
      _(last_response.body['id']).must_be_nil
    end
  end

  describe 'Creating New Accounts' do
    before do
      @account_data = DATA[:accounts][1]
    end

    it 'HAPPY: should be able to create new accounts' do
      post 'api/v1/accounts', @account_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      account = CoEditPDF::Account.first

      _(created['id']).must_equal account.id
      _(created['name']).must_equal @account_data['name']
      _(created['email']).must_equal @account_data['email']
      _(account.password?(@account_data['password'])).must_equal true
      _(account.password?('not_really_the_password')).must_equal false
    end

    it 'SECURITY: should not create account with mass assignment' do
      bad_data = @account_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/accounts', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
