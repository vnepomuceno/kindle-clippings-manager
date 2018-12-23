require 'dotenv/load'
require 'mongo'

module KindleClippings
  module Repository
    class Books
      COLLECTION_NAME = 'books'.freeze

      attr_reader :connection

      def initialize
        db_url = ENV['MONGO_DB_URL']
        raise 'MongoDB URL not configured' if db_url.nil?

        @connection = Mongo::Client.new(db_url)
      end

      def upsert(book)
        highlights = book.highlights.map do |highlight|
          highlight.to_hash
        end
        find_result = connection[COLLECTION_NAME].find(author: book.author, book_title: book.book_title)
        if find_result.count.zero?
          connection[COLLECTION_NAME].insert_one(author: book.author, book_title: book.book_title,
                                                 highlights: highlights)
        else
          highlights.each do |highlight|
            connection[COLLECTION_NAME].update_one({'_id' => find_result.first[:_id]},
                                                   '$push' => {'highlights' => highlight})
          end
        end
      end
    end
  end
end
