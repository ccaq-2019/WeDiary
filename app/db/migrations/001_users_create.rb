# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id

      String :name, null: false
      String :email, unique: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
