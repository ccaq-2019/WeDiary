# frozen_string_literal: true

module CoEditPDF
  # Policy to determine if an account can collaborate a particular pdf
  class CollaborationRequestPolicy
    def initialize(pdf, target_account)
      @pdf = pdf
      @requestor_account = pdf.owner
      @target_account = target_account
      @requestor = PdfPolicy.new(@requestor_account, @pdf)
      @target = PdfPolicy.new(@target_account, @pdf)
    end

    def can_invite?
      @requestor.can_add_collaborators? && @target.can_collaborate?
    end

    def can_remove?
      @requestor.can_remove_collaborators? && target_is_collaborator?
    end

    private

    def target_is_collaborator?
      @pdf.collaborators.include?(@target_account)
    end
  end
end
