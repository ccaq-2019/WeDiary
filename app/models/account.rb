# frozen_string_literal: true

require 'json'
require 'sequel'

module CoEditPDF
  # Holds User Data
  class Account < Sequel::Model
    one_to_many :owned_pdfs, class: :'CoEditPDF::Pdf', key: :owner_id
    plugin :association_dependencies, owned_pdfs: :destroy

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :name, :email

    # Secure getters and setters
    def email
      SecureDB.decrypt(email_secure)
    end

    def email=(plaintext)
      self.email_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'user',
            attributes: {
              id: id,
              name: name,
              email: email
            }
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
