# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, pdfs'
    create_accounts
    create_owned_pdfs
    add_collaborators
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_pdfs.yml")
PDF_INFO = YAML.load_file("#{DIR}/pdfs_seed.yml")
CONTRIB_INFO = YAML.load_file("#{DIR}/pdfs_collaborators.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    CoEditPDF::Account.create(account_info)
  end
end

def create_owned_pdfs
  OWNER_INFO.each do |owner|
    account = CoEditPDF::Account.first(name: owner['owner_name'])
    owner['pdf_name'].each do |pdf_name|
      pdf_data = PDF_INFO.find { |pdf| pdf['filename'] == pdf_name }
      account.add_owned_pdf(pdf_data)
    end
  end
end

def add_collaborators
  CONTRIB_INFO.each do |contrib|
    pdf = CoEditPDF::Pdf.first(filename: contrib['pdf_name'])
    contrib['collaborator_email'].each do |email|
      collaborator = CoEditPDF::Account.first(email: email)
      pdf.add_collaborator(collaborator)
    end
  end
end
