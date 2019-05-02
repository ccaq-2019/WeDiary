# frozen_string_literal: true

require 'roda'
require 'json'

# rubocop:disable Metrics/BlockLength
module CoEditPDF
  # Web controller for CoEditPDF API
  class Api < Roda
    plugin :halt

    accounts = Account.where(id: :$find_id)
    pdfs = Pdf.where(owner_id: :$find_owner_id, id: :$find_id)

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'CoEditPDFAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'accounts' do
          @account_route = "#{@api_root}/accounts"

          routing.on String do |owner_id|
            routing.on 'pdfs' do
              @pdf_route = "#{@api_root}/accounts/#{owner_id}/pdfs"

              # GET api/v1/accounts/[owner_id]/pdfs/[pdf_id]
              routing.get String do |pdf_id|
                # rubocop:disable Style/UnneededInterpolation
                pdf = pdfs.call(
                  :first, find_owner_id: "#{owner_id}", find_id: "#{pdf_id}"
                )
                # rubocop:enable Style/UnneededInterpolation
                pdf ? pdf.to_json : raise('PDF not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/accounts/[owner_id]/pdfs
              routing.get do
                # rubocop:disable Style/UnneededInterpolation
                output = {
                  data: accounts.call(:first, find_id: "#{owner_id}").owned_pdfs
                }
                # rubocop:enable Style/UnneededInterpolation
                JSON.pretty_generate(output)
              end

              # POST api/v1/accounts/[owner_id]/pdfs
              routing.post do
                new_data = JSON.parse(routing.body.read)
                new_pdf = CreatePdfForOwner.call(
                  owner_id: owner_id, pdf_data: new_data
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

            # GET api/v1/accounts/[owner_id]
            routing.get do
              # rubocop:disable Style/UnneededInterpolation
              account = accounts.call(:first, find_id: "#{owner_id}")
              # rubocop:enable Style/UnneededInterpolation
              account ? account.to_json : raise('Account not found')
            rescue StandardError => error
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # GET api/v1/accounts
          routing.get do
            output = { data: Account.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find accounts' }.to_json
          end

          # POST api/v1/accounts
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_account = Account.create(new_data)
            raise('Could not save account') unless new_account

            response.status = 201
            response['Location'] = "#{@account_route}/#{new_account.id}"
            { message: 'Account saved', data: new_account }.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => error
            routing.halt 500, { message: error.message }.to_json
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
