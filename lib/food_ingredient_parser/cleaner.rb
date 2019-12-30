module FoodIngredientParser
  module Cleaner

    def self.clean(s)
      s.gsub!("\u00ad", "")             # strip soft hyphen
      s.gsub!("\u0092", "'")            # windows-1252 apostrophe - https://stackoverflow.com/a/15564279/2866660
      s.gsub!("‚", ",")                 # normalize unicode comma
      s.gsub!("aÄs", "aïs")             # encoding issue for maïs
      s.gsub!("Ã¯", "ï")                # encoding issue
      s.gsub!("Ã«", "ë")                # encoding issue
      s.gsub!(/\A\s*"(.*)"\s*\z/, '\1') # enclosing double quotation marks
      s.gsub!(/\A\s*'(.*)'\s*\z/, '\1') # enclosing single quotation marks
      s
    end

  end
end
