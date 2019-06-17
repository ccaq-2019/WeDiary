# frozen_string_literal: true

module CoEditPDF
  # Policy to determine if account can view a pdf
  class PdfPolicy
    # Scope of pdf policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_pdfs(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |pdf|
            includes_collaborator?(pdf, @current_account)
          end
        end
      end

      private

      def all_pdfs(account)
        owned_pdf_policy = if account.owned_pdfs.any?
                             PdfPolicy.new(account, account.owned_pdfs[0])
                                      .summary
                           end

        collaborate_pdf_policy = if account.collaborations.any?
                                   PdfPolicy.new(account,
                                                 account.collaborations[0])
                                            .summary
                                 end

        {
          owned: { pdfs: get_all_pdfs_detail(account.owned_pdfs),
                   policy: owned_pdf_policy },
          collaborate: { pdfs: get_all_pdfs_detail(account.collaborations),
                         policy: collaborate_pdf_policy }
        }
      end

      def get_all_pdfs_detail(pdfs)
        pdfs.map(&:full_details)
      end

      def includes_collaborator?(pdf, account)
        pdf.collaborators.include? account
      end
    end
  end
end
