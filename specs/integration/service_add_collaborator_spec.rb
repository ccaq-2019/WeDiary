# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaboratorToPdf service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      CoEditPDF::Account.create(account_data)
    end

    pdf_data = DATA[:pdfs].first
  
    owner_data = DATA[:accounts][0]
    @owner = CoEditPDF::Account.all[0]
    @collaborator = CoEditPDF::Account.all[1]
    @pdf = @owner.add_owned_pdf(pdf_data)
    @auth = authorization(owner_data)
  end

  it 'HAPPY: should be able to add a collaborator to a pdf' do
    CoEditPDF::AddCollaboratorToPdf.call(
      auth: @auth,
      collaborator_email: @collaborator.email,
      pdf_id: @pdf.id
    )

    _(@collaborator.collaborations.count).must_equal 1
    _(@collaborator.collaborations.first).must_equal @pdf
  end

  it 'BAD: should not add owner as a collaborator' do
    proc {
      CoEditPDF::AddCollaboratorToPdf.call(
        auth: @auth,
        collaborator_email: @owner.email,
        pdf_id: @pdf.id
      )
    }.must_raise CoEditPDF::AddCollaboratorToPdf::ForbiddenError
  end
end
