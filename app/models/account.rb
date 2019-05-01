# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative './password'

module CoEditPDF
  # Holds User Data
  class Account < Sequel::Model
    one_to_many :owned_pdfs, class: :'CoEditPDF::Pdf', key: :owner_id
    plugin :association_dependencies, owned_pdfs: :destroy

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :name, :email, :password

    # Secure getters and setters
    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = CoEditPDF::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

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
