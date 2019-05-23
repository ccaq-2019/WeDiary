# frozen_string_literal: true

module CoEditPDF
  # Service object to create a new pdf for an owner
  class CreatePdfForOwner
    @accounts = Account.where(name: :$find_name)

    def self.call(owner_name:, pdf_data:)
      @accounts.call(:first, find_name: owner_name)
               .add_owned_pdf(pdf_data)
    end
  end
end
