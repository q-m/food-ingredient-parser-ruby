require_relative '../cleaner'
require_relative 'scanner'

module FoodIngredientParser::Loose
  class Parser

    # Create a new food ingredient stream parser
    # @return [FoodIngredientParser::StreamParser]
    def initialize
    end

    # Parse food ingredient list text into a structured representation.
    #
    # @option clean [Boolean] pass +false+ to disable correcting frequently occuring issues
    # @return [FoodIngredientParser::Loose::Node] structured representation of food ingredients
    def parse(s, clean: true, **options)
      s = FoodIngredientParser::Cleaner.clean(s) if clean
      Scanner.new(s).scan
    end
  end
end
