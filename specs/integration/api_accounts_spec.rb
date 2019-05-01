# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Account Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting accounts' do
    it 'HAPPY: should be able to get list of all accounts' do
      CoEditPDF::Account.create(DATA[:accounts][0])
      CoEditPDF::Account.create(DATA[:accounts][1])

      get 'api/v1/accounts'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single account' do
      existing_account = DATA[:accounts][1]
      CoEditPDF::Account.create(existing_account)
      id = CoEditPDF::Account.first.id

      get "/api/v1/accounts/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal id
      _(result['data']['attributes']['name']).must_equal existing_account['name']
      _(result['data']['attributes']['email']).must_equal existing_account['email']
    end

    it 'SAD: should return error if unknown account requested' do
      get '/api/v1/accounts/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      CoEditPDF::Account.create(name: 'New Account', email: 'account1@mail.com')
      CoEditPDF::Account.create(name: 'Newer Account', email: 'account2@mail.com')
      get 'api/v1/accounts/2%20or%20id%3E0' # 2 or id > 0

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Accounts' do
    before do
      @account_data = DATA[:accounts][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new accounts' do
      post 'api/v1/accounts', @account_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      account = CoEditPDF::Account.first

      _(created['id']).must_equal account.id
      _(created['name']).must_equal @account_data['name']
      _(created['email']).must_equal @account_data['email']
    end

    it 'SECURITY: should not create account with mass assignment' do
      bad_data = @account_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/accounts', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
