require_relative '../support/mongo_connection'

module KindleClippings
  module Support
    class MongoDbIntegration
      COLLECTION = 'books'.freeze

      def drop_collection
        MongoConnection.get[COLLECTION].drop
      end

      def close_connection
        MongoConnection.close_connection
      end

      def insert_document(book)
        highlights = book.highlights.map do |highlight|
          highlight.to_hash
        end
        MongoConnection.get[COLLECTION].insert_one(
          book_title: book.book_title,
          author: book.author,
          highlights: highlights,
        )
      end

      def find(object_id)
        MongoConnection.get[COLLECTION].find(_id: object_id).first
      end
    end
  end
end
