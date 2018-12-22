# frozen_string_literal: true

require_relative 'lib/interactors/kindle_clippings_lib/interactors'

parser = ClippingsParserInteractor.new
parser.parse(ENV['INPUT_FILE_NAME'])
