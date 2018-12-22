require 'kindleclippings'

class ClippingsParserInteractor
  attr_reader :kindle_parser

  def initialize
    @kindle_parser = KindleClippings::Parser.new
  end

  def parse(filename)
    kindle_parser.parse_file(filename)
  end
end
