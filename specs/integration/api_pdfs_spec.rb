# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test PDF Document Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = CoEditPDF::Account.create(@account_data)
    @wrong_account = CoEditPDF::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting PDF Documents' do
    before do
      @account.add_owned_pdf(DATA[:pdfs][0])
      @account.add_owned_pdf(DATA[:pdfs][1])
    end

    it 'HAPPY: should be able to get list of authorized PDF documents' do
      header 'Authorization', auth_header(@account_data)
      get 'api/v1/pdfs'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body

      _(result['data']['owned']['pdfs'].count).must_equal 2
      _(result['data']['collaborate']['pdfs'].count).must_equal 0
      _(result['data']['collaborate']['policy']).must_be_nil
    end

    it 'BAD: should not process without authorization' do
      get 'api/v1/pdfs'
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['data']).must_be_nil
    end

    it 'HAPPY: should be able to get details of a single pdf' do
      pdf = CoEditPDF::Pdf.first

      header 'Authorization', auth_header(@account_data)
      get "/api/v1/pdfs/#{pdf.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body

      _(result['data']['attributes']['id']).must_equal pdf.id
      _(result['data']['attributes']['filename']).must_equal pdf.filename
    end

    it 'SAD: should return error if unknown pdf requested' do
      header 'Authorization', auth_header(@account_data)
      get '/api/v1/pdfs/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating PDF Documents' do
    before do
      @pdf_data = DATA[:pdfs][0]
    end

    it 'HAPPY: should be able to create new pdfs with valid auth token' do
      header 'Authorization', auth_header(@account_data)
      post 'api/v1/pdfs', @pdf_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      pdf = CoEditPDF::Pdf.first

      _(created['id']).must_equal pdf.id
      _(created['filename']).must_equal pdf.filename
    end

    it 'BAD: should not create PDF documents without authorization' do
      post 'api/v1/pdfs', @pdf_data.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(created).must_be_nil
    end

    it 'SECURITY: should not create PDF documents with mass assignment' do
      bad_data = @pdf_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'Authorization', auth_header(@account_data)
      post 'api/v1/pdfs', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
