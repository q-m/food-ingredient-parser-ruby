require_relative '../cleaner'
require_relative 'scanner'
require_relative 'transform/amount'
require_relative 'transform/handle_missing_name'
require_relative 'transform/split_e_numbers'

module FoodIngredientParser::Loose
  class Parser

    # Create a new food ingredient stream parser
    # @return [FoodIngredientParser::StreamParser]
    def initialize
    end

    # Parse food ingredient list text into a structured representation.
    #
    # @option clean [Boolean] pass +false+ to disable correcting frequently occuring issues
    # @option normalize [Boolean] pass +false+ to disable some normalizations (handling missing names)
    # @return [FoodIngredientParser::Loose::Node] structured representation of food ingredients
    def parse(s, clean: true, normalize: true, **options)
      s = FoodIngredientParser::Cleaner.clean(s) if clean
      n = Scanner.new(s).scan
      n = Transform::Amount.transform!(n) if n
      n = Transform::SplitENumbers.transform!(n) if n
      n = Transform::HandleMissingName.transform!(n) if n && normalize
      n
    end
  end
end
