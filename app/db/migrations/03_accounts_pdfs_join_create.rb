# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    # create_join_table(collaborator_id: :accounts, pdf_id: :pdfs)
    create_table(:accounts_pdfs) do
      foreign_key :collaborator_id, :accounts, type: 'uuid'
      foreign_key :pdf_id, :pdfs, type: 'uuid'
      primary_key [:collaborator_id, :pdf_id]
      index [:collaborator_id, :pdf_id]
    end
  end
end
