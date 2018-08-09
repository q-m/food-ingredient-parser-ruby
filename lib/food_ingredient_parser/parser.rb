require_relative 'grammar'

module FoodIngredientParser
  class Parser

    # Create a new food ingredient parser
    # @return [FoodIngredientParser]
    def initialize
      @parser = Grammar::RootParser.new
    end

    # Parse food ingredient list text into a structured representation.
    # @option clean [Boolean] pass +false+ to disable correcting frequently occuring issues
    # @return [Hash] structured representation of food ingredients
    def parse(s, clean: true)
      s = clean(s) if clean
      @parser.parse(s)
    end

    private

    def clean(s)
      s.gsub!("\u00ad", "")             # strip soft hyphen
      s.gsub!("\u0092", "'")            # windows-1252 apostrophe - https://stackoverflow.com/a/15564279/2866660
      s.gsub!("aÄs", "aïs")             # encoding issue for maïs
      s.gsub!("Ã¯", "ï")                # encoding issue
      s.gsub!("Ã«", "ë")                # encoding issue
      s.gsub!(/\A\s*"(.*)"\s*\z/, '\1') # enclosing double quotation marks
      s.gsub!(/\A\s*'(.*)'\s*\z/, '\1') # enclosing single quotation marks
      s
    end

  end
end
