require 'treetop'

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

class RootNode < SyntaxNode
  def to_h
    h = { contains: contains.to_a }
    if notes && notes_ary = to_a_deep(notes, NoteNode)&.map(&:text_value)
      h[:notes] = notes_ary if notes_ary.length > 0
    end
    h
  end
end

class ListNode < SyntaxNode
  def to_a
    to_a_deep(contains, IngredientNode).map(&:to_h)
  end
end

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

class NestedIngredientNode < IngredientNode
  def to_h
    super.merge({ contains: to_a_deep(contains, IngredientNode).map(&:to_h) })
  end
end

class AmountNode < SyntaxNode
  def to_h
    { amount: amount.text_value }
  end
end

class NoteNode < SyntaxNode
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

class IngredientsParser < RootParser
  def parse(s, clean: true)
    s = self.clean(s) if clean
    super(s)
  end

  def clean(s)
    s.gsub!("\u0092", "'")            # windows-1252 apostrophe - https://stackoverflow.com/a/15564279/2866660
    s.gsub!("aÄs", "aïs")             # encoding issue for maïs
    s.gsub!("Ã¯", "ï")                # encoding issue
    s.gsub!("Ã«", "ë")                # encoding issue
    s.gsub!(/\A\s*"(.*)"\s*\z/, '\1') # enclosing double quotation marks
    s.gsub!(/\A\s*'(.*)'\s*\z/, '\1') # enclosing single quotation marks
    s
  end
end
