# frozen_string_literal: true

require 'json'
require 'sequel'

module CoEditPDF
  # Holds User Data
  class User < Sequel::Model
    one_to_many :pdfs
    plugin :association_dependencies, pdfs: :destroy

    plugin :timestamps

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
