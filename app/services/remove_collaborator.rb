# frozen_string_literal: true

module CoEditPDF
  # Remove a collaborator from another owner's existing pdf
  class RemoveCollaborator
    # Error for policy violation
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.call(collaborator_email:, pdf_id:)
      pdf = Pdf.first(id: pdf_id)
      collaborator = Account.first(email: collaborator_email)

      policy = CollaborationRequestPolicy.new(pdf, collaborator)
      raise ForbiddenError unless policy.can_remove?

      pdf.remove_collaborator(collaborator)
      collaborator
    end
  end
end
