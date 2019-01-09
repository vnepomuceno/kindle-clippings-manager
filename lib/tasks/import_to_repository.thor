require_relative '../interactors/clippings_parser'

class ImportToRepository < Thor
  desc 'import', 'import clippings to repository'
  def import
    puts 'Importing clippings to repository'
    clippings_parser_interactor = KindleClippings::Interactor::ClippingsParser.new
    clippings_parser_interactor.parse(ENV['INPUT_FILE_NAME'])
  end
end
