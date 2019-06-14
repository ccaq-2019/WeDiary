# frozen_string_literal: true

require_relative './app'

# rubocop:disable Metrics/BlockLength
module CoEditPDF
  # Web controller for CoEditPDF API
  class Api < Roda
    route('pdfs') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @pdf_route = "#{@api_root}/pdfs"
      routing.on String do |pdf_id|
        # GET api/v1/pdfs/[pdf_id]
        routing.get do
          pdf = Pdf.first(id: pdf_id)
          pdf = GetPdfQuery.call(
            account: @auth_account, pdf: pdf
          )

          { data: pdf }.to_json
        rescue GetPdfQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetPdfQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND PDF ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        routing.on 'collaborators' do
          # PUT api/v1/pdfs/[pdf_id]/collaborators
          routing.put do
            req_data = JSON.parse(routing.body.read)

            collaborator = AddCollaboratorToPdf.call(
              collaborator_email: req_data['collaborator_email'],
              pdf_id: pdf_id
            )

            { data: collaborator }.to_json
          rescue AddCollaboratorToPdf::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/pdfs/[pdf_id]/collaborators
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            collaborator = RemoveCollaborator.call(
              collaborator_email: req_data['collaborator_email'],
              pdf_id: pdf_id
            )

            { message: "#{collaborator.name} removed from projet",
              data: collaborator }.to_json
          rescue RemoveCollaborator::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end

      # GET api/v1/pdfs
      routing.get do
        pdfs = PdfPolicy::AccountScope.new(@auth_account).viewable

        JSON.pretty_generate(data: pdfs)
      rescue StandardError
        routing.halt 403,
                     { message: 'Could not find any PDF documents' }.to_json
      end

      # POST api/v1/pdfs
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_pdf = CreatePdfForOwner.call(
          owner_name: @auth_account['name'],
          pdf_data: { filename: new_data['filename'],
                      content: new_data['file_read'] }
        )

        # File.open("./#{new_data['filename']}", 'wb') do |f|
        #   f.write(Base64.strict_decode64(new_data['file_read']))
        # end

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
