module FoodIngredientParser::Loose
  # Parsing result.
  class Node
    attr_accessor :name, :mark, :amount, :contains
    attr_reader :input, :interval, :auto_close

    def initialize(input, interval, auto_close: false)
      @input = input
      @interval = interval.is_a?(Range) ? interval : ( interval .. interval )
      @auto_close = auto_close
      @contains = []
      @name = @mark = @amount = nil
    end

    def ends(index)
      @interval = @interval.first .. index
    end

    def <<(child)
      @contains << child
    end

    def text_value
      @input[@interval]
    end

    def to_h
      r = {}
      r[:name] = name.text_value.strip if name && name.text_value.strip != ''
      r[:mark] = mark.text_value.strip if mark
      r[:amount] = amount.text_value.strip if amount
      r[:contains] = contains.map(&:to_h).reject {|c| c == {} } if contains.any?
      r
    end

    def inspect(indent="")
      inspect_self(indent) +
      inspect_children(indent)
    end

    def inspect_self(indent="")
      [
        indent + "Node interval=#{@interval}",
        name ? "name=#{name.text_value.strip.inspect}" : nil,
        mark ? "mark=#{mark.text_value.strip.inspect}" : nil,
        amount ? "amount=#{amount.text_value.strip.inspect}" : nil,
        auto_close ? "auto_close" : nil
      ].compact.join(", ")
    end

    def inspect_children(indent="")
      contains.map do |child|
        "\n" + child.inspect(indent + "  ")
      end.join("")
    end
  end
end
