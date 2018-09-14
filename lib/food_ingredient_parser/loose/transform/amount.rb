require 'treetop'
require_relative '../../strict/nodes'
Treetop.load File.dirname(__FILE__) + '/../../strict/grammar/common'
Treetop.load File.dirname(__FILE__) + '/../../strict/grammar/amount'
Treetop.load File.dirname(__FILE__) + '/amount_from_name'

require_relative '../node'

module FoodIngredientParser::Loose
  module Transform
    # Transforms node tree to extract amount into its own attribute.
    class Amount
      def self.transform!(node)
        new(node).transform!
      end

      def initialize(node)
        @node = node
        @parser = FoodIngredientParser::Loose::Transform::AmountFromNameParser.new
      end

      def transform!
        transform_name
        transform_contains
        @node
      end

      private

      # Extract amount from name, if any.
      def transform_name(node = @node)
        if !node.amount && parsed = parse_amount(node.name&.text_value)
          offset = node.name.interval.first

          amount = parsed.amount.amount
          node.amount = Node.new(node.input, offset + amount.interval.first .. offset + amount.interval.last - 1)

          name = parsed.respond_to?(:name) && parsed.name
          if name && name.interval.count > 0
            node.name = Node.new(node.input, offset + name.interval.first .. offset + name.interval.last - 1)
          else
            node.name = nil
          end
        end

        # recursively transform contained nodes
        node.contains&.each(&method(:transform_name))
      end

      # If first or last child is an amount, it's this node's amount.
      # Assumes all names already have extracted their amounts with {{#transform_name}}.
      def transform_contains(node = @node)
        if !node.amount && node.contains.any?
          if node.contains.first.name.nil? && node.contains.first.amount
            node.amount = node.contains.shift.amount
          elsif node.contains.count > 1 && node.contains.last.name.nil? && node.contains.last.amount
            node.amount = node.contains.pop.amount
          end
        end

        # recursively transform contained nodes
        node.contains.each(&method(:transform_contains))
      end

      def parse_amount(s)
        @parser.parse(s) if s && s.strip != ''
      end
    end
  end
end
