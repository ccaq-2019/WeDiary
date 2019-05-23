# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Auth Token' do
  before do
    @payload = { name: 'Angels', email: 'angels@mlb.com' }
  end

  it 'should return the correct payload' do
    token = AuthToken.create(@payload)
    payload = AuthToken.payload(token)

    _(payload.to_json).must_equal @payload.to_json
  end

  it 'should raise ExpiredTokenError if the token is expired' do
    token = AuthToken.create(@payload, 0)
    proc {
      AuthToken.payload(token)
    }.must_raise AuthToken::ExpiredTokenError
  end

  it 'should raise InvalidTokenError if the token is invalid' do
    proc {
      AuthToken.payload('fake_token')
    }.must_raise AuthToken::InvalidTokenError
  end
end
