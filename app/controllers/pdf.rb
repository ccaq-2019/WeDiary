# frozen_string_literal: true

require_relative './app'

# rubocop:disable Metrics/BlockLength
module CoEditPDF
  # Web controller for CoEditPDF API
  class Api < Roda
    route('pdfs') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @pdf_route = "#{@api_root}/pdfs"
      routing.on String do |pdf_id|
        routing.on 'collaborators' do
          # PUT api/v1/pdfs/[pdf_id]/collaborators
          routing.put do
            req_data = JSON.parse(routing.body.read)

            collaborator = AddCollaboratorToPdf.call(
              auth: @auth,
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
              auth: @auth,
              collaborator_email: req_data['collaborator_email'],
              pdf_id: pdf_id
            )

            { message: "#{collaborator.name} removed from pdf",
              data: collaborator }.to_json
          rescue RemoveCollaborator::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on 'edit' do
          routing.put do
            req_data = JSON.parse(routing.body.read)
            edited_pdf = PutPdf.call(
              auth: @auth,
              pdf_id: pdf_id,
              edit_data: req_data['edit_data']
            )

            { message: "Modification to #{edited_pdf.filename} was added",
              data: edited_pdf }.to_json
          end
        end

        # GET api/v1/pdfs/[pdf_id]
        routing.get do
          pdf = Pdf.first(id: pdf_id)
          pdf = GetPdfQuery.call(
            auth: @auth, pdf: pdf
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

        # DELETE api/v1/pdfs/[pdf_id]
        routing.delete do
          pdf = Pdf.first(id: pdf_id)
          pdf = DeletePdf.call(
            auth: @auth, pdf: pdf
          )

          { message: "#{pdf.filename} was deleted",
            data: pdf }.to_json
        rescue DeletePdf::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
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
          auth: @auth,
          pdf_data: new_data
        )

        raise 'Could not save pdf' unless new_pdf

        response.status = 201
        response['Location'] = "#{@pdf_route}/#{new_pdf.id}"
        { message: 'PDF saved', data: new_pdf }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => e
        puts [e.class, e.message].join ': '
        routing.halt 500, { message: 'Database error' }.to_json
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
