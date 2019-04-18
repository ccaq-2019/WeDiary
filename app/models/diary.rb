# frozen_string_literal: true

require 'base64'
require 'rbnacl'
require 'json'
require 'date'

module CoEditPDF
  # Holds a diary
  class Diary
    STORE_DIR = 'app/db/store/'

    def initialize(new_diary)
      @id = new_diary['id'] || new_id
      @title = new_diary['title']
      @date = new_diary['date'] || Date.today.to_s
      @content = new_diary['content']
    end

    attr_reader :id, :title, :date, :content

    def to_json(options = {})
      JSON(
        {
          type: 'diary',
          id: id,
          title: title,
          date: date,
          content: content
        },
        options
      )
    end

    def self.setup
      Dir.mkdir(STORE_DIR) unless Dir.exist? STORE_DIR
    end

    def save
      File.write(STORE_DIR + id + '.txt', to_json)
    end

    def self.find(find_id)
      # TODO: check if file exists
      diary_file = File.read(STORE_DIR + find_id + '.txt')
      Diary.new JSON.parse(diary_file)
    end

    def self.all
      Dir.glob(STORE_DIR + '*.txt').map do |filepath|
        # Retrieve the id part from filepath
        filepath.match(/#{Regexp.quote(STORE_DIR)}(.*)\.txt/)[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
