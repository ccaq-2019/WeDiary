# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Users Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:users].each do |user_data|
      CoEditPDF::User.create(user_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    user_data = DATA[:users][0]
    user = CoEditPDF::User.first

    _(user.email).must_equal user_data['email']
    _(user.name).must_equal user_data['name']
  end

  it 'SECURITY: should not use deterministic integers' do
    user = CoEditPDF::User.first

    _(user.id).wont_be_instance_of Integer
    _(proc { user.id - user.id }).must_raise NoMethodError
  end

  it 'SECURITY: should secure sensitive attributes' do
    user = CoEditPDF::User.first
    stored_user = app.DB[:users].first

    _(stored_user[:email_secure]).wont_equal user.email
  end
end
