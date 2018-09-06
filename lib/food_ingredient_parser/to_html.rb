require 'cgi'

# Adds HTML output functionality to a Treetop Node.
#
# The node needs to provide a {#to_h} method (for {#to_html_h}).
#
module FoodIngredientParser::ToHtml

  # Markup original ingredients list text in HTML.
  #
  # The input text is returned as HTML, augmented with CSS classes
  # on +span+s for +name+, +amount+, +mark+ and +note+.
  #
  # @return [String] HTML representation of ingredient list.
  def to_html
    node_to_html(self)
  end

  private

  def node_to_html(node, cls=nil, depth=0)
    el_cls = {}               # map of node instances to class names for contained elements
    terminal = node.terminal? # whether to look at children elements or not

    if node.is_a?(FoodIngredientParser::Grammar::AmountNode)
      cls ||= "amount"
    elsif node.is_a?(FoodIngredientParser::Grammar::NoteNode)
      cls ||= "note"
      terminal = true # NoteNodes may contain other NoteNodes, we want it flat.
    elsif node.is_a?(FoodIngredientParser::Grammar::IngredientNode)
      el_cls[node.name] = "name" if node.respond_to?(:name)
      el_cls[node.mark] = "mark" if node.respond_to?(:mark)
      if node.respond_to?(:contains)
        el_cls[node.contains] = "contains depth#{depth}"
        depth += 1
      end
    elsif node.is_a?(FoodIngredientParser::Grammar::RootNode)
      if node.respond_to?(:contains)
        el_cls[node.contains] = "depth#{depth}"
        depth += 1
      end
    end

    val = if terminal
      CGI.escapeHTML(node.text_value)
    else
      node.elements.map {|el| node_to_html(el, el_cls[el], depth) }.join("")
    end

    cls ? "<span class='#{cls}'>#{val}</span>" : val
  end
end
