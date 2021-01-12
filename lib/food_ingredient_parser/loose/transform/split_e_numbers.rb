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
        elsif node.name && m = MATCH_RE.match(node.name.text_value)
          i = 0
          while m = node.name.text_value.match(SPLIT_RE, i)
            node.contains << new_node(node, i, m.begin(0)-1)
            i = m.end(0)
          end
          node.contains << new_node(node, i, node.name.interval.last) if i <= node.name.interval.last
          node.name = nil
        end
      end

      def new_node(node, begins, ends)
        offset = node.name.interval.first
        new_node = Node.new(node.input, offset + begins .. offset + ends)
        new_node.name = Node.new(node.input, new_node.interval)
        new_node
      end
    end
  end
end
