# frozen_string_literal: true

module CoEditPDF
  # Service object to create a new pdf for an owner
  class CreatePdfForOwner
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add Pdf'
      end
    end

    def self.call(auth:, pdf_data:)
      raise ForbiddenError unless auth[:scope].can_write?('pdf')

      auth[:account].add_owned_pdf(pdf_data)
    end
  end
end
