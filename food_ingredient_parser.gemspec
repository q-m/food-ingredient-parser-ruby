$:.unshift(File.expand_path(File.dirname(__FILE__) + '/lib'))
require 'food_ingredient_parser/version'

Gem::Specification.new do |s|
  s.name             = 'food_ingredient_parser'
  s.version          = FoodIngredientParser::VERSION
  s.date             = '2018-08-31'
  s.summary          = 'Parser for ingredient lists found on food products.'
  s.authors          = ['wvengen']
  s.email            = ['dev-ruby@willem.engen.nl']
  s.homepage         = 'https://github.com/q-m/food-ingredient-parser-ruby'
  s.license          = 'MIT'
  s.description      = <<-EOD
    Food products often contain an ingredient list of some sort. This parser
    tries to recognize the syntax and returns a structured representation of the
    food ingredients.
  EOD
  s.metadata         = {
    'bug_tracker_uri' => 'https://github.com/q-m/food-ingredient-parser-ruby/issues',
    'source_code_uri' => 'https://github.com/q-m/food-ingredient-parser-ruby',
  }

  s.files            = `git ls-files *.gemspec lib`.split("\n")
  s.executables      = `git ls-files bin`.split("\n").map(&File.method(:basename))
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.require_paths    = ['lib']

  s.add_runtime_dependency 'treetop', '~> 1.6'
end
