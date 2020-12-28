module FoodIngredientParser
  module Cleaner

    def self.clean(s)
      s.gsub!(/(_x005f_|_)x000d_/i, "\n") # fix sometimes encoding for newline
      s.gsub!("\u00ad", "")               # strip soft hyphen
      s.gsub!("\u0092", "'")              # windows-1252 apostrophe - https://stackoverflow.com/a/15564279/2866660
      s.gsub!("‚", ",")                   # normalize unicode comma
      s.gsub!("aÄs", "aïs")               # encoding issue for maïs
      s.gsub!("Ã¯", "ï")                  # encoding issue
      s.gsub!("Ã«", "ë")                  # encoding issue
      s.gsub!(/\A\s*(["']+)(.*)\1\s*\z/, '\2') # enclosing quotation marks
      s
    end

  end
end
