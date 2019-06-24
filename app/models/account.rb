# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative './password'

module CoEditPDF
  # Holds User Data
  class Account < Sequel::Model
    dataset_module do
      def where(inputs)
        if inputs.is_a?(Hash)
          if inputs.key?(:email)
            inputs[:email_digest] = inputs.delete :email
            inputs[:email_digest] = SecureDB.digest(inputs[:email_digest])
          end
        end
        super(inputs)
      end

      def first(*args)
        inputs = args[0]
        unless inputs.nil?
          if inputs.key?(:email)
            inputs[:email_digest] = inputs.delete :email
            inputs[:email_digest] = SecureDB.digest(inputs[:email_digest])
          end
          args[0] = inputs
        end
        super(*args)
      end
    end

    one_to_many :owned_pdfs, class: :'CoEditPDF::Pdf', key: :owner_id

    many_to_many :collaborations,
                 class: :'CoEditPDF::Pdf',
                 join_table: :accounts_pdfs,
                 left_key: :collaborator_id, right_key: :pdf_id

    plugin :association_dependencies,
           owned_pdfs:     :destroy,
           collaborations: :nullify

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :name, :email, :password

    def self.create_github_account(github_account)
      create(name:  github_account[:username],
             email: github_account[:email])
    end

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
      self.email_digest = SecureDB.digest(plaintext)
    end

    def to_json(options = {})
      JSON(
        {
          type:       'account',
          attributes: public_attributes_hash
        }, options
      )
    end

    def public_attributes_hash
      {
        id:    id,
        name:  name,
        email: email
      }
    end
  end
end
