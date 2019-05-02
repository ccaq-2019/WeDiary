# frozen_string_literal: true

# rubocop:disable Style/UnneededInterpolation
module CoEditPDF
  # Service object to add a collaborator to another owner's existing pdf
  class AddCollaboratorToPdf
    @accounts = Account.where(id: :$find_id)
    @pdfs = Pdf.where(id: :$find_id)

    def self.call(collaborator_id:, pdf_id:)
      collaborator = @accounts.call(:first, find_id: "#{collaborator_id}")
      pdf = @pdfs.call(:first, finid_id: "#{pdf_id}")
      return false if pdf.owner.id == collaborator.id

      pdf.add_collaborator(collaborator)
    end
  end
end
# rubocop:enable Style/UnneededInterpolation
