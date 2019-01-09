require_relative '../types'
require_relative 'highlight'

module KindleClippings
  class Book < Dry::Struct
    attribute :author, Types::Strict::String
    attribute :book_title, Types::Strict::String
    attribute :highlights, Types::Strict::Array do
      attribute :content, Types::Strict::String
      attribute :location, Types::Strict::String.optional
      attribute :page, Types::Strict::String.optional
      attribute :type, Types::Strict::String.optional
    end
    attribute :created_at, Types::Strict::String.default(Time.now.utc.to_s)
    attribute :updated_at, Types::Strict::String.default(Time.now.utc.to_s)
  end
end
