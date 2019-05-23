# frozen_string_literal: true

require 'roda'
require_relative './app'

# rubocop:disable Metrics/BlockLength
module CoEditPDF
  # Web controller for CoEditPDF API
  class Api < Roda
    accounts = Account.where(name: :$find_name)
    pdfs = Pdf.where(id: :$find_id)

    route('pdfs') do |routing|
      @pdf_route = "#{@api_root}/pdfs"

      # GET api/v1/pdfs/[pdf_id]
      routing.get String do |pdf_id|
        # rubocop:disable Style/UnneededInterpolation
        pdf = pdfs.call(:first, find_id: "#{pdf_id}")
        # rubocop:enable Style/UnneededInterpolation
        pdf ? pdf.to_json : raise('PDF not found')
      rescue StandardError => e
        routing.halt 404, { message: e.message }.to_json
      end

      # GET api/v1/pdfs
      routing.get do
        # rubocop:disable Style/UnneededInterpolation
        owned_pdfs = accounts.call(:first, find_name: @auth_account['name']).owned_pdfs
        # rubocop:enable Style/UnneededInterpolation
        JSON.pretty_generate(data: owned_pdfs)
      rescue StandardError
        routing.halt 403, { message: 'Could not find any projects' }.to_json
      end

      # POST api/v1/pdfs
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_pdf = CreatePdfForOwner.call(
          owner_name: @auth_account['name'], pdf_data: new_data
        )
        raise 'Could not save pdf' unless new_pdf

        response.status = 201
        response['Location'] = "#{@pdf_route}/#{new_pdf.id}"
        { message: 'PDF saved', data: new_pdf }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError
        routing.halt 500, { message: 'Database error' }.to_json
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
