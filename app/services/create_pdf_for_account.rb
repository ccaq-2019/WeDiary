# frozen_string_literal: true

# rubocop:disable Style/UnneededInterpolation
module CoEditPDF
  # Service object to create a new pdf for an owner
  class CreatePdfForOwner
    @accounts = Account.where(id: :$find_id)

    def self.call(owner_id:, pdf_data:)
      @accounts.call(:first, find_id: "#{owner_id}")
               .add_owned_pdf(pdf_data)
    end
  end
end
# rubocop:enable Style/UnneededInterpolation
