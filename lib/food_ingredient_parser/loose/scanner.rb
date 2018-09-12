require_relative 'node'

module FoodIngredientParser::Loose
  class Scanner
    def initialize(s, index: 0)
      @s = s
      @i = index
      @ancestors = [Node.new(@s, @i)]
      @iterator = :beginning
    end

    def scan
      loop do
        method(:"scan_iteration_#{@iterator}").call
      end

      while @ancestors.count > 1
        add_child
        close_parent
      end
      add_child
      @ancestors.first.ends(@i-1)
      @ancestors.first
    end

    private

    def loop
      while @i < @s.length
        @i += 1 if yield != false
      end
    end

    def scan_iteration_beginning
      # skip over some common prefixes
      m = @s[@i .. -1].match(/\A\s*(ingredients|contains|ingred[iï][eë]nt(en)?(declaratie)?|bevat|dit zit er\s?in|samenstelling|zutaten)\s*[:;.]\s*/i)
      @i += m.offset(0).last if m
      # now continue with the standard parsing
      @iterator = :standard
      false
    end

    def scan_iteration_standard
      if "([".include?(c)         # open nesting
        open_parent
      elsif ")]".include?(c)      # close nesting
        add_child
        close_parent
      elsif is_sep?               # separator
        add_child
      elsif ":".include?(c)       # another open nesting
        add_child
        open_parent(auto_close: true)
        @iterator = :colon
      elsif is_mark? && !cur.mark # mark after ingredient
        name_until_here
        cur.mark = Node.new(@s, @i)
        while is_mark?
          cur.mark.ends(@i)
          @i += 1
        end
        @i -= 1
      else
        cur # reference to record starting position
      end
    end

    def scan_iteration_colon
      if "/".include?(c)        # slash separator in colon nesting only
        add_child
      elsif is_sep?             # regular separator indicates end of colon nesting
        add_child
        close_parent
        # revert to standard parsing from here on
        @iterator = :standard
        scan_iteration_standard
      elsif "([]):".include?(c) # continue with deeper nesting level
        # revert to standard parsing from here on
        @iterator = :standard
        scan_iteration_standard
      else
        # normal handling for this character
        scan_iteration_standard
      end
    end

    def c
      @s[@i]
    end

    def parent
      @ancestors.last
    end

    def cur
      @cur ||= Node.new(@s, @i)
    end

    def is_mark?
      @s[@i] && "¹²³⁴⁵ᵃᵇᶜᵈᵉᶠᵍªº⁽⁾†‡•°#^*".include?(@s[@i]) && @s[@i+1..-1] !~ /^°[CF]/
    end

    def is_sep?
      ";,.".include?(@s[@i]) && @s[@i-1..@i+1] !~ /\d.\d/
    end

    def add_child
      cur.ends(@i-1)
      cur.name ||= Node.new(@s, cur.interval)
      parent << cur
      @cur = nil
    end

    def open_parent(**options)
      name_until_here
      @ancestors << cur
      @cur = Node.new(@s, @i + 1, **options)
    end

    def close_parent
      return unless @ancestors.count > 1
      @cur = @ancestors.pop
      while @cur.auto_close
        add_child
        @cur = @ancestors.pop
      end
    end

    def name_until_here
      cur.name ||= Node.new(@s, cur.interval.first .. @i-1)
    end
  end
end
