# frozen_string_literal: true

require_relative 'lib/interactors/clippings_parser'

parser = KindleClippings::Interactor::ClippingsParser.new
parser.parse(ENV['INPUT_FILE_NAME'])
