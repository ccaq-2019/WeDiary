# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaboratorToProject service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      CoEditPDF::Account.create(account_data)
    end

    pdf_data = DATA[:pdfs].first

    @owner = CoEditPDF::Account.all[0]
    @collaborator = CoEditPDF::Account.all[1]
    @pdf = CoEditPDF::CreatePdfForOwner.call(
      owner_name: @owner.name, pdf_data: pdf_data
    )
  end

  it 'HAPPY: should be able to add a collaborator to a pdf' do
    CoEditPDF::AddCollaboratorToPdf.call(
      collaborator_id: @collaborator.id,
      pdf_id: @pdf.id
    )

    _(@collaborator.collaborations.count).must_equal 1
    _(@collaborator.collaborations.first).must_equal @pdf
  end

  it 'BAD: should not add owner as a collaborator' do
    proc {
      CoEditPDF::AddCollaboratorToPdf.call(
        collaborator_id: @owner.id,
        pdf_id: @pdf.id
      )
    }.must_raise CoEditPDF::AddCollaboratorToPdf::OwnerNotCollaboratorError
  end
end
