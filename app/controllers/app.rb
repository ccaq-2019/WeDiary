# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/diary'

module CoEditPDF
  # Web controller for CoEditPDF API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Diary.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'DiaryAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'diary' do
            # GET api/v1/diary/[id]
            routing.get String do |id|
              Diary.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Diary not found' }.to_json
            end

            # GET api/v1/diary
            routing.get do
              output = { diary_ids: Diary.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/diary
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_doc = Diary.new(new_data)

              if new_doc.save
                response.status = 201
                { message: 'Diary saved', id: new_doc.id }.to_json
              else
                routing.halt 400, { message: 'Could not save diary' }.to_json
              end
            end
          end
        end
      end
    end
  end
end
