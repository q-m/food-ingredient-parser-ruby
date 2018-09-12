require_relative 'grammar'
require_relative '../cleaner'

module FoodIngredientParser::Strict
  class Parser

    # @!attribute [r] parser
    #   @return [Treetop::Runtime::CompiledParser] low-level parser object
    #   @note This attribute is there for convenience, but may change in the future. Take care.
    attr_reader :parser

    # Create a new food ingredient parser
    # @return [FoodIngredientParser::Parser]
    def initialize
      @parser = Grammar::RootParser.new
    end

    # Parse food ingredient list text into a structured representation.
    #
    # @option clean [Boolean] pass +false+ to disable correcting frequently occuring issues
    # @return [FoodIngredientParser::Grammar::RootNode] structured representation of food ingredients
    # @note Unrecognized options are passed to Treetop, but this is not guarenteed to remain so forever.
    def parse(s, clean: true, **options)
      s = FoodIngredientParser::Cleaner.clean(s) if clean
      @parser.parse(s, **options)
    end

  end
end
