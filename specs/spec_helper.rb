# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:pdfs].delete
  app.DB[:accounts].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:pdfs] = YAML.safe_load File.read('app/db/seeds/pdf_seeds.yml')
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/account_seeds.yml')
