require 'treetop'

class SyntaxNode < Treetop::Runtime::SyntaxNode
  private

  def to_a_deep(n)
    if n.is_a?(IngredientNode)
      [n.to_h]
    elsif n.nonterminal?
      n.elements.map {|m| to_a_deep(m) }.flatten(1).compact
    end
  end
end

class RootNode < SyntaxNode
  def to_a
    contains.to_a
  end
end

class ListNode < SyntaxNode
  def to_a
    to_a_deep(contains)
  end
end

class IngredientNode < SyntaxNode
  def to_h
    { name: name.text_value.strip }.merge((amount.to_h rescue {})) # @todo get rid of rescue
  end
end

class NestedIngredientNode < IngredientNode
  def to_h
    super.merge({ contains: to_a_deep(contains) })
  end
end

class AmountNode < SyntaxNode
  def to_h
    { amount: amount.text_value.strip }
  end
end

Treetop.load 'ingredients-parser'
