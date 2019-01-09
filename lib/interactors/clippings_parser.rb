require_relative '../repositories/books_repository'
require_relative '../entities/book'
require 'kindleclippings'

module KindleClippings
  module Interactor
    class ClippingsParser
      private
      attr_reader :kindle_parser
      attr_reader :highlights_repository

      public
      def initialize
        @kindle_parser = KindleClippings::Parser.new
        @highlights_repository = KindleClippings::Repository::Books.new
      end

      def parse(filename)
        parse_results = kindle_parser.parse_file(filename)
        parse_results.each do |highlight|
          highlights_repository.upsert(book_object(highlight))
        end
      end

      def book_object(clipping)
        KindleClippings::Book.new(
          author: clipping.author,
          book_title: clipping.book_title,
          highlights: [
            {
              content: clipping.content,
              location: clipping.location,
              page: clipping.page.to_s,
              type: clipping.type,
            }
          ]
        )
      end
    end
  end
end
