# frozen_string_literal: true

require 'base64'

# Parses Json with keys as symbols
class PdfManipulation
  def initialize(pdf_id, pdf_content_base64)
    @id = pdf_id
    content = Base64.strict_decode64(pdf_content_base64)
    File.open("#{@id}.pdf", 'wb') { |file| file.write(content) }
    @document = HexaPDF::Document.open("#{@id}.pdf")
  end

  def add_text(edit_data)
    page = @document.pages[0]
    height = page.box.height.round
    canvas = page.canvas(type: :overlay)
    canvas.font('Helvetica', size: 15)
    canvas.text(edit_data['text'],
                at: [edit_data['x'].to_i, height - edit_data['y'].to_i])
    self
  end

  def content_base64
    @document.write("#{@id}.pdf")
    content = File.open("#{@id}.pdf", 'rb').read
    Base64.strict_encode64(content)
  end
end
