# frozen_string_literal: true

module CoEditPDF
  # Policy of account and pdf
  class PdfPolicy
    def initialize(account, pdf, auth_scope = nil)
      @account = account
      @pdf = pdf
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && (account_is_owner? || account_is_collaborator?)
    end

    # duplication is ok! by Soumya.ray
    def can_edit?
      can_write? && (account_is_owner? || account_is_collaborator?)
    end

    def can_delete?
      can_write? && account_is_owner?
    end

    def can_leave?
      account_is_collaborator?
    end

    def can_add_documents?
      can_write? && (account_is_owner? || account_is_collaborator?)
    end

    def can_remove_documents?
      can_write? && (account_is_owner? || account_is_collaborator?)
    end

    def can_add_collaborators?
      account_is_owner?
    end

    def can_remove_collaborators?
      account_is_owner?
    end

    def can_collaborate?
      not (account_is_owner? or account_is_collaborator?)
    end

    def summary
      {
        can_view:                 can_view?,
        can_edit:                 can_edit?,
        can_delete:               can_delete?,
        can_leave:                can_leave?,
        can_add_documents:        can_add_documents?,
        can_delete_documents:     can_remove_documents?,
        can_add_collaborators:    can_add_collaborators?,
        can_remove_collaborators: can_remove_collaborators?,
        can_collaborate:          can_collaborate?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('projects') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('projects') : false
    end

    def account_is_owner?
      @pdf.owner == @account
    end

    def account_is_collaborator?
      @pdf.collaborators.include?(@account)
    end
  end
end
