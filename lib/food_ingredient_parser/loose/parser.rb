require_relative '../cleaner'
require_relative 'scanner'
require_relative 'transform/amount'

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
      n = Scanner.new(s).scan
      n = Transform::Amount.transform!(n) if n
      n
    end
  end
end
