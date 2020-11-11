require_relative 'node'

module FoodIngredientParser::Loose
  class Scanner

    SEP_CHARS  = "|;,.".freeze
    MARK_CHARS = "¹²³⁴⁵ᵃᵇᶜᵈᵉᶠᵍªº⁽⁾†‡•°▪◊#^˄*~".freeze
    PREFIX_RE  = /\A\s*(ingredients|contains|ingred[iï][eë]nt(en)?(declaratie)?|bevat|dit zit er\s?in|samenstelling|zutaten)\b\s*[:;.]?\s*/i.freeze
    NOTE_RE    = /\A\b(dit product kan\b|deze verpakking kan\b|kan sporen\b.*?\bbevatten\b|voor allergenen\b|allergenen\b|allergie[- ]informatie(\s*:|\b)|E\s*=|gemaakt in\b|geproduceerd in\b|bevat mogelijk\b|kijk voor meer\b|allergie-info|in de fabriek\b|in dit bedrijf\b|voor [0-9,.]+ (g\.?|gr\.?|ram|ml).*\bis [0-9,.]+ (g\.?|gr\.?|ram|ml).*\bgebruikt\b)/i.freeze
    # Keep in sync with +abbrev+ in the +Common+ grammar, plus relevant ones from the +Amount+ grammar.
    ABBREV_RE  = Regexp.union(
      /\A(
        N°\b |
        °C\b |
        (ijzer|chroom|koper)\s*\(I+\)\s*[[:alnum:]]+\b |
        L\(\+\)[ -][[:alnum:]]+\b |
        L\.\s+rhamnosus\b | L\.\s+acidophilus\b | L\.\s+casei\b | B\.\s+lactis | A\.\s+oryzae |
        S\.\s+thermophilus\b | L\.\sbulgaricus\b |
        T\.\s*aestivum\b(\s+vitt\.)? |
        nucifera\s+L\. |
        type\s+"\d+" |
        E-e?\d{3}[a-z]?\s*\(i+\) |
        www\.[-_\/:%.A-Za-z0-9]+
      )/xi,
      *%w[
        a.o.p b.g.a b.o.b c.a c.i d.e d.m.v d.o.c d.o.p d.s e.a e.g e.u f.i.l f.o.s i.a
        i.d i.e i.g.m.e i.g.p i.m.v i.o i.v.m l.s.l n.a n.b n.o n.v.t o.a o.b.v p.d.o
        p.g.i q.s s.l s.s t.o.v u.h.t v.g v.s w.a w.o w.v vit denat alc vol conc subsp
        min max ca
      ].map {|s| /\A#{Regexp.escape(s)}\b\.?/i}
    ).freeze

    def initialize(s, index: 0)
      @s = s                           # input string
      @i = index                       # current index in string
      @cur = nil                       # current node we're populating
      @ancestors = [Node.new(@s, @i)]  # nesting hierarchy
      @iterator = :beginning           # scan_iteration_<iterator> to use for parsing
      @dest = :contains                # append current node to this attribute on parent
    end

    def scan
      loop do
        method(:"scan_iteration_#{@iterator}").call
      end

      close_all_ancestors
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
      m = @s[@i .. -1].match(PREFIX_RE)
      @i += m.offset(0).last if m
      # now continue with the standard parsing
      @iterator = :standard
      false
    end

    def scan_iteration_standard
      if (len = abbrev_len) > 0   # defer iterations until after any abbreviation
        cur # reference to record starting position
        @i += len - 1
      elsif "([".include?(c)      # open nesting
        open_parent
      elsif ")]".include?(c)      # close nesting
        add_child
        close_parent
      elsif is_notes_start?       # usually a dot marks the start of notes
        close_all_ancestors
        @iterator = :notes
        @dest = :notes
      elsif is_sep?               # separator
        add_child
      elsif ":".include?(c)       # another open nesting
        if @s[@i+1..-1] =~ /\A\s*(\(|\[)/
          # ignore colon before an open bracket, then it's a regular nesting
          name_until_here
        else
          open_parent(auto_close: true)
          @iterator = :colon
        end
      elsif is_mark? && !cur.mark # mark after ingredient
        name_until_here
        len = mark_len
        cur.mark = Node.new(@s, @i .. @i+len-1)
        @i += len - 1
      else
        cur # reference to record starting position
      end
    end

    def scan_iteration_colon
      if (len = abbrev_len) > 0 # defer iterations until after any abbreviation
        cur # reference to record starting position
        @i += len - 1
      elsif "/".include?(c)     # slash separator in colon nesting only
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

    def scan_iteration_notes
      if (len = abbrev_len) > 0 # defer iterations until after any abbreviation
        cur # reference to record starting position
        @i += len - 1
      elsif is_sep?(chars: ".")    # dot means new note
        add_child
      else
        cur
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

    def is_sep?(chars: SEP_CHARS)
      chars.include?(c) && @s[@i-1..@i+1] !~ /\A\d.\d\z/
    end

    def is_mark?(i = @i)
      mark_len(i) > 0 && @s[i..i+1] !~ /\A°[CF]/
    end

    def mark_len(i = @i)
      j = i
      while @s[j] && MARK_CHARS.include?(@s[j])
        j += 1
      end
      j - i
    end

    def abbrev_len
      m = @s[@i .. -1].match(ABBREV_RE)
      m ? m.offset(0).last : 0
    end

    def is_notes_start?
      # @todo use more heuristics: don't assume dot is notes when separator is a dot, and only toplevel?
      ml = mark_len
      if ( is_mark? && @s[@i+ml .. -1] =~ /\A\s*=/ ) ||                      # "* = Biologisch"
         ( is_mark? && @s[@i-1] =~ /\s/ && @s[@i+ml .. -1] =~ /\A\s*\w/ ) || # " **Biologisch"
         ( @s[@i..-1] =~ NOTE_RE )                                           # "E=", "Kan sporen van", ...
        @i -= 1 # we want to include the mark in the note
        true
      # End of sentence
      elsif dot_is_not_sep? && is_sep?(chars: ".")
        true
      else
        false
      end
    end

    def add_child
      name_until_here
      cur.ends(@i-1)
      parent.send(@dest) << cur
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

    def close_all_ancestors
      while @ancestors.count > 1
        add_child
        close_parent
      end
      add_child
    end

    def name_until_here
      cur.name ||= begin
        i, j = cur.interval.first, @i - 1
        i += mark_len(i) # skip any mark in front
        # Set name if there is any. There is one corner-case that needs to be avoided when
        # a nesting was opened without a name, which would set the name to the nesting text.
        # In this case, the name starts with an open-nesting symbol, which should never happen.
        if j >= i && !"([:".include?(@s[i])
          Node.new(@s, i .. j)
        end
      end
    end

    def dot_is_not_sep?
      # if separator is dot ".", don't use it for note detection
      if @dot_is_not_sep.nil?
        @dot_is_not_sep = begin
          # @todo if another separator is found more often, dot is not a separator
          num_words = @s.split(/\s+/).count
          num_dots = @s.count(".")
          # heuristic: 1/4+ of the words has a dot, with at least five words
          num_words < 5 || 4 * num_dots < num_words
        end
      end
      @dot_is_not_sep
    end
  end
end
