# frozen_string_literal: true

require 'hexapdf'
require 'base64'

module CoEditPDF
  # Service object to edit a existing PDF file
  class PutPdf
    # Error for policy violation
    class ForbiddenError < StandardError
      def message
        'You are not allowed to edit that pdf'
      end
    end

    def self.call(auth:, pdf_id:, edit_data:)
      pdf = Pdf.first(id: pdf_id)
      policy = PdfPolicy.new(auth[:account], pdf, auth[:scope])
      raise ForbiddenError unless policy.can_edit?

      content = PdfManipulation
                .new(pdf.id, pdf.content)
                .add_text(edit_data['text'], edit_data['x'], edit_data['y'])
                .content_base64

      pdf.update(content: content)
      pdf
    end
  end
end
