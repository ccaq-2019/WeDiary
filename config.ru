# frozen_string_literal: true

require './app/controllers/app.rb'
run WeDiary::Api.freeze.app
