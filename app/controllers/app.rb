# frozen_string_literal: true

require 'roda'
require 'json'

# rubocop:disable Metrics/BlockLength
module CoEditPDF
  # Web controller for CoEditPDF API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'CoEditPDFAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'users' do
          @user_route = "#{@api_root}/users"

          routing.on String do |user_id|
            routing.on 'pdfs' do
              @pdf_route = "#{@api_root}/users/#{user_id}/pdfs"

              # GET api/v1/users/[user_id]/pdfs/[pdf_id]
              routing.get String do |pdf_id|
                pdf = Pdf.where(user_id: user_id, id: pdf_id).first
                pdf ? pdf.to_json : raise('PDF not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/users/[user_id]/pdfs
              routing.get do
                output = { data: User.first(id: user_id).pdfs }
                JSON.pretty_generate(output)
              end

              # POST api/v1/users/[user_id]/pdfs
              routing.post do
                new_data = JSON.parse(routing.body.read)
                user = User.first(id: user_id)
                new_pdf = user.add_pdf(new_data)

                if new_pdf
                  response.status = 201
                  response['Location'] = "#{@pdf_route}/#{new_pdf.id}"
                  { message: 'PDF saved', data: new_pdf }.to_json
                else
                  routing.halt 400, 'Could not save pdf'
                end

              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/users/[user_id]
            routing.get do
              user = User.first(id: user_id)
              user ? user.to_json : raise('User not found')
            rescue StandardError => error
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # GET api/v1/users
          routing.get do
            output = { data: User.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find users' }.to_json
          end

          # POST api/v1/users
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_user = User.create(new_data)
            raise('Could not save user') unless new_user

            response.status = 201
            response['Location'] = "#{@user_route}/#{new_user.id}"
            { message: 'User saved', data: new_user }.to_json
          rescue StandardError => error
            routing.halt 400, { message: error.message }.to_json
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
