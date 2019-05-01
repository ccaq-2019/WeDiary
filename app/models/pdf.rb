# frozen_string_literal: true

require 'json'
require 'sequel'

module CoEditPDF
  # Holds PDF Data
  class Pdf < Sequel::Model
    many_to_one :owner, class: :'CoEditPDF::Account'

    many_to_many :collaborators,
                 class: :'CoEditPDF::Account',
                 join_table: :accounts_pdfs,
                 left_key: :pdf_id, right_key: :collaborator_id

    plugin :uuid, field: :id
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :filename

    # Secure getters and setters
    def filename
      SecureDB.decrypt(filename_secure)
    end

    def filename=(plaintext)
      self.filename_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'pdf',
            attributes: {
              id: id,
              filename: filename
            }
          },
          included: {
            owner: owner
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
