# Food ingredient parser

[![Gem Version](https://badge.fury.io/rb/food_ingredient_parser.svg)](https://rubygems.org/gems/food_ingredient_parser)

Ingredients are listed on food products in various ways. This [Ruby](https://www.ruby-lang.org/)
gem and program parses the ingredient text and returns a structured representation.

## Installation

```
gem install food_ingredient_parser
```

This will also install the dependency [treetop](http://cjheath.github.io/treetop).
If you want colored output for the test program, also install [pry](http://pryrepl.org/): `gem install pry`.

## Example

```ruby
require 'food_ingredient_parser'

s = "Water* 60%, suiker 30%, voedingszuren: citroenzuur, appelzuur, zuurteregelaar: E576/E577, " \
    + "natuurlijke citroen-limoen aroma's 0,2%, zoetstof: steviolglycosiden, * = Biologisch. " \
    + "E = door de E.U. goedgekeurde toevoeging."
parser = FoodIngredientParser::Strict::Parser.new
puts parser.parse(s).to_h.inspect
```
Results in
```ruby
{
  :contains=>[
    {:name=>"Water", :amount=>"60%", :marks=>["*"]},
    {:name=>"suiker", :amount=>"30%"},
    {:name=>"voedingszuren", :contains=>[
      {:name=>"citroenzuur"}
    ]},
    {:name=>"appelzuur"},
    {:name=>"zuurteregelaar", :contains=>[
      {:name=>"E576"},
      {:name=>"E577"}
    ]},
    {:name=>"natuurlijke citroen-limoen aroma's", :amount=>"0,2%"},
    {:name=>"zoetstof", :contains=>[
      {:name=>"steviolglycosiden"}
    ]}
  ],
  :notes=>[
    "* = Biologisch",
    "E = door de E.U. goedgekeurde toevoeging"
  ]
}
```

## Test tool

The executable `food_ingredient_parser` is available after installing the gem. If you're
running this from the source tree, use `bin/food_ingredient_parser` instead.

```
$ food_ingredient_parser -h
Usage: bin/food_ingredient_parser [options] --file|-f <filename>
       bin/food_ingredient_parser [options] --string|-s <ingredients>

    -f, --file FILE                  Parse all lines of the file as ingredient lists.
    -s, --string INGREDIENTS         Parse specified ingredient list.
    -q, --[no-]quiet                 Only show summary.
    -p, --parsed                     Only show lines that were successfully parsed.
    -n, --noresult                   Only show lines that had no result.
    -r, --parser PARSER              Use specific parser (strict, loose).
    -e, --[no-]escape                Escape newlines
    -c, --[no-]color                 Use color
        --[no-]html                  Print as HTML with parsing markup
    -v, --[no-]verbose               Show more data (parsed tree).
        --version                    Show program version.
    -h, --help                       Show this help

$ food_ingredient_parser -v -s "tomato"
"tomato"
RootNode+Root3 offset=0, "tomato" (contains,notes):
  SyntaxNode offset=0, ""
  SyntaxNode offset=0, ""
  SyntaxNode offset=0, ""
  ListNode+List13 offset=0, "tomato" (contains):
    SyntaxNode+List12 offset=0, "tomato" (ingredient):
      SyntaxNode+Ingredient0 offset=0, "tomato":
        SyntaxNode offset=0, ""
        IngredientNode+IngredientSimpleWithAmount3 offset=0, "tomato" (ing):
          IngredientNode+IngredientSimple5 offset=0, "tomato" (name):
            SyntaxNode+IngredientSimple4 offset=0, "tomato" (word):
              SyntaxNode offset=0, "tomato":
                SyntaxNode offset=0, "t"
                SyntaxNode offset=1, "o"
                SyntaxNode offset=2, "m"
                SyntaxNode offset=3, "a"
                SyntaxNode offset=4, "t"
                SyntaxNode offset=5, "o"
              SyntaxNode offset=6, ""
        SyntaxNode offset=6, ""
      SyntaxNode offset=6, ""
  SyntaxNode+Root2 offset=6, "":
    SyntaxNode offset=6, ""
    SyntaxNode offset=6, ""
    SyntaxNode offset=6, ""
  SyntaxNode offset=6, ""
{:contains=>[{:name=>"tomato"}]}

$ food_ingredient_parser --html -s "tomato"
<div class="root"><span class='depth0'><span class='name'>tomato</span></span></div>

$ food_ingredient_parser -v -r loose -s "tomato"
"tomato"
Node interval=0..5
  Node interval=0..5, name="tomato"
{:contains=>[{:name=>"tomato"}]}

$ food_ingredient_parser -q -f data/test-cases
parsed 35 (100.0%), no result 0 (0.0%)
```

If you want to use the output in (shell)scripts, the options `-e -c` may be quite useful.

## `to_html`

When ingredient lists are entered manually, it can be very useful to show how the text is
recognized. This can help understanding why a certain ingredients list cannot be parsed.

For this you can use the `to_html` method on the parsed output, which returns the original
text, augmented with CSS classes for different parts.

```ruby
require 'food_ingredient_parser'

parsed = FoodIngredientParser::Strict::Parser.new.parse("Saus (10% tomaat*, zout). * = bio")
puts parsed.to_html
```

```html
<span class='depth0'>
  <span class='name'>Saus</span> (
  <span class='contains depth1'>
    <span class='amount'>10%</span> <span class='name'>tomaat</span><span class='mark'>*</span>,
    <span class='name'>zout</span>
  </span>)
</span>.
<span class='note'>* = bio</span>
```

For an example of an interactive editor, see [examples/editor.rb](examples/editor.rb).

![editor example screenshot](examples/editor-screenshot.png)

## Loose parser

The strict parser only parses ingredient lists that conform to one of the many different
formats expected. If you'd like to return a result always, even if that is not necessarily
completely correct, you can use the _loose_ parser. This does not use Treetop, but looks
at the input character for character and tries to make the best of it. Nevertheless, if you
just want to have _some_ result, this can still be very useful.

```ruby
require 'food_ingredient_parser'

parsed = FoodIngredientParser::Loose::Parser.new.parse("Saus [10% tomaat*, (zout); peper.")
puts parsed.to_h
```

Even though the strict parser would not give a result, the loose parser returns:
```ruby
{
  :contains=>[
    {:name=>"Saus", :contains=>[
      {:name=>"tomaat", :marks=>["*"], :amount=>"10%", {
        :contains=>[{:name=>"zout"}
      ]},
      {:name=>"peper"}
    ]}
  ]
}
```

## Compatibility

From the 1.0.0 release, the main interface will be stable. This comprises the two parser's `parse`
methods (incl. documented options), its `nil` result when parsing failed, and the parsed output's
`to_h` and `to_html` methods. Please note that parsed node trees may be subject to change, even within
a major release. Within a minor release, node trees are expected to remain stable.

So if you only use the stable interface (`parse`, `to_h` and `to_html`), you can lock your version
to e.g. `~> 1.0`. If you depend on more, lock your version against e.g. `~> 1.0.0` and test when you
upgrade to `1.1`.

## Languages

While most of the parsing is language-independent, some parts need knowledge about certain words
(like abbreviations and amount specifiers). The gem was developed with ingredient lists in Dutch (nl),
plus a bit of English and German. Support for other languages is already good, but lacks in certain
areas: improvements are welcome (starting with a corpus in [data/](data/)).

Many ingredient lists from the USA are structured a bit differently than those from Europe, they
parse less well (that is probably a matter of tine-tuning).

## Test data

[`data/ingredient-samples-qm-nl`](data/ingredient-samples-qm-nl) contains about 150k
real-world ingredient lists found on the Dutch market. Each line contains one ingredient
list (newlines are encoded as `\n`, empty lines and those starting with `#` are ignored).
The strict parser currently parses 80%, while the loose parser returns something for all of them.

## License

This software is distributed under the [MIT license](LICENSE). Data may have a [different license](data/README.md).
