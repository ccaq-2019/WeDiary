# frozen_string_literal: true

module CoEditPDF
  # Policy to determine if an account can collaborate a particular pdf
  class CollaborationRequestPolicy
    def initialize(pdf, target_account, auth_scope = nil)
      @pdf = pdf
      @requestor_account = pdf.owner
      @target_account = target_account
      @auth_scope = auth_scope
      @requestor = PdfPolicy.new(@requestor_account, @pdf, auth_scope)
      @target = PdfPolicy.new(@target_account, @pdf, auth_scope)
    end

    def can_invite?
      can_write? &&
        (@requestor.can_add_collaborators? && @target.can_collaborate?)
    end

    def can_remove?
      can_write? &&
        (@requestor.can_remove_collaborators? && target_is_collaborator?)
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('pdf') : false
    end

    def target_is_collaborator?
      @pdf.collaborators.include?(@target_account)
    end
  end
end
