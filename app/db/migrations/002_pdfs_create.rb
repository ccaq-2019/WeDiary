# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:pdfs) do
      primary_key :id
      foreign_key :user_id, table: :users

      String :filename, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
