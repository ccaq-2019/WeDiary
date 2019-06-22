# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Pdfs Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      CoEditPDF::Account.create(account_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    pdf_data = DATA[:pdfs][1]
    owner_data = DATA[:accounts][0]
    auth = authorization(owner_data)
    account = CoEditPDF::Account.first
    new_pdf = CoEditPDF::CreatePdfForOwner.call(
      auth: auth, pdf_data: pdf_data
    )

    pdf = CoEditPDF::Pdf.find(id: new_pdf.id)
    _(pdf.filename).must_equal new_pdf.filename
  end

  it 'SECURITY: should not use deterministic integers' do
    pdf_data = DATA[:pdfs][1]
    owner_data = DATA[:accounts][0]
    auth = authorization(owner_data)
    account = CoEditPDF::Account.first
    new_pdf = CoEditPDF::CreatePdfForOwner.call(
      auth: auth, pdf_data: pdf_data
    )

    _(new_pdf.id).wont_be_instance_of Integer
    _(proc { new_pdf.id - new_pdf.id }).must_raise NoMethodError
  end

  it 'SECURITY: should secure sensitive attributes' do
    pdf_data = DATA[:pdfs][1]
    owner_data = DATA[:accounts][0]
    auth = authorization(owner_data)
    account = CoEditPDF::Account.first
    new_pdf = CoEditPDF::CreatePdfForOwner.call(
      auth: auth, pdf_data: pdf_data
    )
    stored_pdf = app.DB[:pdfs].first

    _(stored_pdf[:filename_secure]).wont_equal new_pdf.filename
  end
end
