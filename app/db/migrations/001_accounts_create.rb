# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts) do
      uuid :id, primary_key: true

      String :name, null: false, unique: true
      String :email_secure, unique: true
      String :email_digest, unique: true
      String :password_digest

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
