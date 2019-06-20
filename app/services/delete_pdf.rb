# frozen_string_literal: true

module CoEditPDF
  # Service object to create a new pdf for an owner
  class DeletePdf
    # Error for policy violation
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that pdf'
      end
    end

    def self.call(account:, pdf:)
      policy = PdfPolicy.new(account, pdf)
      raise ForbiddenError unless policy.can_delete?

      pdf.destroy
    end
  end
end
