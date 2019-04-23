# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test User Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting users' do
    it 'HAPPY: should be able to get list of all users' do
      CoEditPDF::User.create(DATA[:users][0])
      CoEditPDF::User.create(DATA[:users][1])

      get 'api/v1/users'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single user' do
      existing_user = DATA[:users][1]
      CoEditPDF::User.create(existing_user)
      id = CoEditPDF::User.first.id

      get "/api/v1/users/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal id
      _(result['data']['attributes']['name']).must_equal existing_user['name']
      _(result['data']['attributes']['email']).must_equal existing_user['email']
    end

    it 'SAD: should return error if unknown user requested' do
      get '/api/v1/users/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating New Users' do
    before do
      @user_data = DATA[:users][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new users' do
      post 'api/v1/users', @user_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      user = CoEditPDF::User.first

      _(created['id']).must_equal user.id
      _(created['name']).must_equal @user_data['name']
      _(created['email']).must_equal @user_data['email']
    end

    it 'SECURITY: should not create user with mass assignment' do
      bad_data = @user_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/users', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
