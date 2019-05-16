# frozen_string_literal: true

# rubocop:disable Style/UnneededInterpolation
module CoEditPDF
  # Service object to add a collaborator to another owner's existing pdf
  class AddCollaboratorToPdf
    # Error for owner cannot be collaborator
    class OwnerNotCollaboratorError < StandardError
      def initialize(msg = nil)
        @credentials = msg
      end

      def message
        'Owner cannot be collaborator of project'
      end
    end

    @accounts = Account.where(id: :$find_id)
    @pdfs = Pdf.where(id: :$find_id)

    def self.call(collaborator_id:, pdf_id:)
      collaborator = @accounts.call(:first, find_id: "#{collaborator_id}")
      pdf = @pdfs.call(:first, find_id: "#{pdf_id}")
      raise(OwnerNotCollaboratorError) if pdf.owner.id == collaborator.id

      pdf.add_collaborator(collaborator)
      collaborator
    end
  end
end
# rubocop:enable Style/UnneededInterpolation
