# frozen_string_literal: true

module CoEditPDF
  # Service object to create a new pdf for an owner
  class CreatePdfForOwner
    def self.call(account:, pdf_data:)
      account.add_owned_pdf(pdf_data)
    end
  end
end
