require_relative '../node'

module FoodIngredientParser::Loose
  module Transform
    class SplitENumbers
      # Transforms node tree to split e-number combinations.
      #
      # @note mark and amount is lost, this is not expected on e-numbers

      SPLIT_RE  = /\s*(-|\ben\b|\band\b|\bund\b|\bet\b)\s*/.freeze
      SINGLE_RE = /E(-|\s+)?\d{3}[a-z]?\s*(\([iv]+\)|\[[iv]+\])?/i.freeze
      MATCH_RE  = /\A\s*(#{SINGLE_RE})(?:#{SPLIT_RE}(#{SINGLE_RE}))+\s*\z/i.freeze

      def self.transform!(node)
        new(node).transform!
      end

      def initialize(node)
        @node = node
      end

      def transform!
        transform_node!(@node)
        @node
      end

      private

      def transform_node!(node)
        if node.contains.any?
          node.contains.each {|n| transform_node!(n) }
        else
          node.name_parts.each_with_index do |name, name_index|
            if m = MATCH_RE.match(name.text_value)
              i = 0
              while m = name.text_value.match(SPLIT_RE, i)
                node.contains << new_node(name, i, m.begin(0)-1)
                i = m.end(0)
              end
              node.contains << new_node(name, i, name.interval.last) if i <= name.interval.last
              node.name_parts[name_index] = nil
            end
          end
          # remove cleared name parts
          node.name_parts.reject!(&:nil?)
        end
      end

      def new_node(name, begins, ends)
        offset = name.interval.first
        new_node = Node.new(name.input, offset + begins .. offset + ends)
        new_node.name_parts = [Node.new(name.input, new_node.interval)]
        new_node
      end
    end
  end
end
