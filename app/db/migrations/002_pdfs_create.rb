# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:pdfs) do
      uuid :id, primary_key: true
      foreign_key :owner_id, table: :accounts, null: false, type: :uuid

      String :filename_secure, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
