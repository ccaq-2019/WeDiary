# frozen_string_literal: true

module CoEditPDF
  # Service object to add a collaborator to another owner's existing pdf
  class AddCollaboratorToPdf
    # Error for policy violation
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as collaborator'
      end
    end

    def self.call(auth:, collaborator_email:, pdf_id:)
      collaborator = Account.first(email: collaborator_email)
      pdf = Pdf.first(id: pdf_id)
      policy = CollaborationRequestPolicy.new(pdf,
                                              collaborator,
                                              auth[:scope])

      raise ForbiddenError unless policy.can_invite?

      pdf.add_collaborator(collaborator)
      collaborator
    end
  end
end
