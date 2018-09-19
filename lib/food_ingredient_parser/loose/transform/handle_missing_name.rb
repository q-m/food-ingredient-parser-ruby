module FoodIngredientParser::Loose
  module Transform
    # Transforms node tree to handle missing names.
    #
    # The loose parser can return a node tree that has some ingredients without a name.
    # Usually this means that either the parser wasn't smart enough to understand the input,
    # or the input was not strictly clear (e.g. a case like "herbs, (oregano), salt" is often seen).
    #
    # When a contained node is found which doesn't have a name:
    # * For the amount (if any): ignore it (as it's often ambiguous which ingredient it belongs to)
    # * For the marks (if any): ignore it (we might instead add it to the containing ingredients)
    # * For the containing ingredients (if any):
    #   - if the previous ingredient is present and doesn't contain ingredients already,
    #     assume the current contained ingredients are actually part of the previous ingredient.
    #   - if there is no previous ingredient, assume the nesting is wrong and insert them before
    #     the other ingredients one depth level above.
    #   - if there is a previous ingredient which contains ingredients, we can't make much of it,
    #     to avoid losing them, add them as contained ingredients to the previous ingredient.
    #
    class HandleMissingName
      def self.transform!(node)
        new(node).transform!
      end

      def initialize(node)
        @node = node
      end

      def transform!
        transform_children!(@node)
        @node
      end

      private

      def transform_children!(node)
        prev = nil
        new_contains = []
        node.contains.each do |child|
          # Apply recursively. Do it before processing to handle multiple depth levels of missing names.
          transform_children!(child) if child.contains.any?

          if child.name.nil? || child.name.text_value.strip == ''
            # Name is empty, we need to do something.
            if prev
              # there is a previous ingredient: move children to new parent
              prev.contains.push(*child.contains)
            else
              # there is no previous ingredient: move children one level up
              new_contains.push(*child.contains)
            end
          else
            # Nothing to see here, just leave it as it is.
            new_contains << child
          end

          prev = child
        end

        node.contains = new_contains
      end
    end
  end
end
