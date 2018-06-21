require 'treetop'

class SyntaxNode < Treetop::Runtime::SyntaxNode
  private

  def to_a_deep(n, cls)
    if n.is_a?(cls)
      [n.to_h]
    elsif n.nonterminal?
      n.elements.map {|m| to_a_deep(m, cls) }.flatten(1).compact
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
    to_a_deep(contains, IngredientNode)
  end
end

class IngredientNode < SyntaxNode
  def to_h
    h = {}
    h.merge!(to_a_deep(ing, IngredientNode)&.first&.to_h || {}) if respond_to?(:ing)
    h.merge!(to_a_deep(amount, AmountNode)&.first&.to_h || {}) if respond_to?(:amount)
    h[:name] = name.text_value if respond_to?(:name)
    h[:mark] = mark.text_value if respond_to?(:mark) && mark.text_value != ''
    h
  end
end

class NestedIngredientNode < IngredientNode
  def to_h
    super.merge({ contains: to_a_deep(contains, IngredientNode) })
  end
end

class AmountNode < SyntaxNode
  def to_h
    { amount: amount.text_value }
  end
end

Treetop.load 'grammars/common'
Treetop.load 'grammars/amount'
Treetop.load 'grammars/ingredient_simple'
Treetop.load 'grammars/ingredient_nested'
Treetop.load 'grammars/ingredient_coloned'
Treetop.load 'grammars/ingredient'
Treetop.load 'grammars/list'
Treetop.load 'grammars/list_coloned'
Treetop.load 'grammars/list_newlined'
Treetop.load 'grammars/root'

class IngredientsParser < RootParser; end
