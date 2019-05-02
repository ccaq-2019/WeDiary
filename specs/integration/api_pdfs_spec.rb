# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test PDF Document Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      CoEditPDF::Account.create(account_data)
    end
  end

  it 'HAPPY: should be able to get list of all PDF documents' do
    account = CoEditPDF::Account.first
    DATA[:pdfs].each do |pdf|
      CoEditPDF::CreatePdfForOwner.call(
        owner_id: account.id, pdf_data: pdf
      )
    end

    get "api/v1/accounts/#{account.id}/pdfs"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 3
  end

  it 'HAPPY: should be able to get details of a single pdf' do
    pdf_data = DATA[:pdfs][1]
    account = CoEditPDF::Account.first
    pdf = CoEditPDF::CreatePdfForOwner.call(
      owner_id: account.id, pdf_data: pdf_data
    )

    get "/api/v1/accounts/#{account.id}/pdfs/#{pdf.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal pdf.id
    _(result['data']['attributes']['filename']).must_equal pdf_data['filename']
  end

  it 'SAD: should return error if unknown pdf requested' do
    account = CoEditPDF::Account.first
    get "/api/v1/accounts/#{account.id}/pdfs/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating PDF Documents' do
    before do
      @account = CoEditPDF::Account.first
      @pdf_data = DATA[:pdfs][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new pdfs' do
      post "api/v1/accounts/#{@account.id}/pdfs", @pdf_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      pdf = CoEditPDF::Pdf.first

      _(created['id']).must_equal pdf.id
      _(created['filename']).must_equal @pdf_data['filename']
    end

    it 'SECURITY: should not create PDF documents with mass assignment' do
      bad_data = @pdf_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/accounts/#{@account.id}/pdfs", bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
