require 'cgi'

# Adds HTML output functionality to a Node.
#
module FoodIngredientParser::Loose
  module ToHtml

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

    def node_to_html(node, depth=0)
      children = [*node.contains, *node.notes, node.name, node.amount, node.mark].compact
      children.sort_by! {|n| n.interval.first }

      html = ""
      last_idx = node.interval.first - 1
      children.each do |child|
        # we don't have nodes for all characters, make sure they are in the output
        if child.interval.first - 1 > last_idx
          html += CGI.escapeHTML(node.input[last_idx + 1 .. child.interval.first - 1])
          last_idx = child.interval.first - 1
        end

        if child == node.name
          html += node_to_html_single(child, "name")
          last_idx = child.interval.last
        elsif child == node.amount
          html += node_to_html_single(child, "amount")
          last_idx = child.interval.last
        elsif child == node.mark
          html += node_to_html_single(child, "mark")
          last_idx = child.interval.last
        elsif node.notes.include?(child)
          html += node_to_html_single(child, "note")
          last_idx = child.interval.last
        elsif node.contains.include?(child)
          cls = "depth#{depth}"
          cls = "contains #{cls}" if depth > 0
          html += "<span class='#{cls}'>#{node_to_html(child, depth + 1)}</span>"
          last_idx = child.interval.last
        end
      end

      # include any trailing characters
      if children.any? && last_idx < node.interval.last
        html += CGI.escapeHTML(node.input[last_idx + 1 .. node.interval.last])
      end

      html
    end

    def node_to_html_single(node, cls=nil)
      ws1, txt, ws2 = node.text_value.match(/\A(\s*)(.*?)(\s*)\z/).captures.map {|s| CGI.escapeHTML(s)}
      cls && txt.size > 0 ? "#{ws1}<span class='#{cls}'>#{txt}</span>#{ws2}" : "#{ws1}#{txt}#{ws2}"
    end
  end
end
