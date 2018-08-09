require 'treetop/runtime'

# Needs to be in grammar namespace so Treetop can find the nodes.
module FoodIngredientParser::Grammar

  # Treetop syntax node with our additions, use this as parent for all our own nodes.
  class SyntaxNode < Treetop::Runtime::SyntaxNode
    private

    def to_a_deep(n, cls)
      if n.is_a?(cls)
        [n]
      elsif n.nonterminal?
        n.elements.map {|m| to_a_deep(m, cls) }.flatten(1).compact
      end
    end
  end

  # Root object, contains everything else.
  class RootNode < SyntaxNode
    def to_h
      h = { contains: contains.to_a }
      if notes && notes_ary = to_a_deep(notes, NoteNode)&.map(&:text_value)
        h[:notes] = notes_ary if notes_ary.length > 0
      end
      h
    end
  end

  # List of ingredients.
  class ListNode < SyntaxNode
    def to_a
      to_a_deep(contains, IngredientNode).map(&:to_h)
    end
  end

  # Ingredient
  class IngredientNode < SyntaxNode
    def to_h
      h = {}
      h.merge!(to_a_deep(ing, IngredientNode)&.first&.to_h || {}) if respond_to?(:ing)
      h.merge!(to_a_deep(amount, AmountNode)&.first&.to_h || {}) if respond_to?(:amount)
      h[:name] = name.text_value if respond_to?(:name)
      h[:name] = pre.text_value + h[:name] if respond_to?(:pre)
      h[:name] = h[:name] + post.text_value if respond_to?(:post)
      h[:mark] = mark.text_value if respond_to?(:mark) && mark.text_value != ''
      h
    end
  end

  # Ingredient with containing ingredients.
  class NestedIngredientNode < IngredientNode
    def to_h
      super.merge({ contains: to_a_deep(contains, IngredientNode).map(&:to_h) })
    end
  end

  # Amount, specifying an ingredient.
  class AmountNode < SyntaxNode
    def to_h
      { amount: amount.text_value }
    end
  end

  # Note at the end of the ingredient list.
  class NoteNode < SyntaxNode
  end

end
