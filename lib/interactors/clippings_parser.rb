require_relative '../repositories/books_repository'
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
          highlights_repository.upsert(highlight)
        end
      end
    end
  end
end
