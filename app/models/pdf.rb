# frozen_string_literal: true

require 'json'
require 'sequel'

module CoEditPDF
  # Holds PDF Data
  class Pdf < Sequel::Model
    many_to_one :user

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :filename

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
            user: user
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
