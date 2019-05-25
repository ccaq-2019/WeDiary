# frozen_string_literal: true

require 'base64'
require 'rbnacl'
require_relative 'key_stretch'

# Crypto methods for mixin
module Securable
  # Generate key for Rake tasks (typically not called at runtime)
  def generate_key
    key = RbNaCl::Random.random_bytes(RbNaCl::SecretBox.key_bytes)
    Base64.strict_encode64 key
  end

  # Generate salt for Rake tests (typically not called at runtime)
  def generate_salt
    new_salt
  end

  # Call setup once to pass in config variable with DB_KEY and DB_SALT attribute
  def setup(base_key, base_salt = nil)
    @base_key = base_key
    @base_salt = base_salt
  end

  def key
    @key ||= Base64.strict_decode64(@base_key)
  end

  def salt
    @salt ||= @base_salt
  end

  # Encrypt or else return nil if data is nil
  def base_encrypt(plaintext)
    simple_box = RbNaCl::SimpleBox.from_secret_key(key)
    simple_box.encrypt(plaintext)
  end

  # Decrypt or else return nil if database value is nil already
  def base_decrypt(ciphertext)
    simple_box = RbNaCl::SimpleBox.from_secret_key(key)
    simple_box.decrypt(ciphertext)
  end

  def base_digest(plaintext)
    digest = password_hash(salt, plaintext)
    Base64.strict_encode64(digest)
  end
end
