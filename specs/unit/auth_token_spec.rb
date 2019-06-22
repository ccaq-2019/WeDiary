# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Auth Token' do
  before do
    @payload = { name: 'Angels', email: 'angels@mlb.com' }
  end

  it 'should return the correct contents' do
    token = AuthToken.create(@payload)
    contents = AuthToken.contents(token)

    _(contents['payload'].to_json).must_equal @payload.to_json
  end

  it 'should raise ExpiredTokenError if the token is expired' do
    token = AuthToken.create(@payload, AuthScope.new, 0)
    proc {
      AuthToken.contents(token)
    }.must_raise AuthToken::ExpiredTokenError
  end

  it 'should raise InvalidTokenError if the token is invalid' do
    proc {
      AuthToken.contents('fake_token')
    }.must_raise AuthToken::InvalidTokenError
  end
end
