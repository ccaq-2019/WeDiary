# frozen_string_literal: true

require 'json'
require 'sequel'

module CoEditPDF
  # Holds PDF Data
  class Pdf < Sequel::Model
    dataset_module do
      def where(inputs)
        if inputs.is_a?(Hash)
          if inputs.key?(:filename)
            inputs[:filename_digest] = inputs.delete :filename
            inputs[:filename_digest] = SecureDB.digest(inputs[:filename_digest])
          end
        end
        super(inputs)
      end

      def first(*args)
        inputs = args[0]
        unless inputs.nil?
          if inputs.key?(:filename)
            inputs[:filename_digest] = inputs.delete :filename
            inputs[:filename_digest] = SecureDB.digest(inputs[:filename_digest])
          end
          args[0] = inputs
        end
        super(*args)
      end
    end

    many_to_one :owner, class: :'CoEditPDF::Account'

    many_to_many :collaborators,
                 class: :'CoEditPDF::Account',
                 join_table: :accounts_pdfs,
                 left_key: :pdf_id, right_key: :collaborator_id

    plugin :association_dependencies,
           collaborators: :nullify

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
      self.filename_digest = SecureDB.digest(plaintext)
    end

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'pdf',
          attributes: {
            id: id,
            filename: filename
          },
          include: {
            owner: owner
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
