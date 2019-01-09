require_relative '../types'

module KindleClippings
  class Highlight < Dry::Struct
    attribute :content, Types::Strict::String
    attribute :location, Types::Strict::String.optional
    attribute :page, Types::Strict::String.optional
    attribute :type, Types::Strict::String.optional
  end
end
