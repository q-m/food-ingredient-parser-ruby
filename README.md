# WiP - Food ingredient parser

Ingredients listed on food products in various ways. This [Ruby](https://www.ruby-lang.org/)
program parses the ingredient text and returns a structured representation.

_This is under development and not yet fully finished._

## Dependencies

Ruby, the gem [treetop](http://cjheath.github.io/treetop), and optionally [pry](http://pryrepl.org/).

## Example

```ruby
require_relative 'ingredients-parser'

s = "Water* 60%, suiker 30%, voedingszuren: citroenzuur, appelzuur, zuurteregelaar: E576/E577, " \
    + "natuurlijke citroen-limoen aroma's 0,2%, zoetstof: steviolglycosiden, * = Biologisch. " \
    + "E = door de E.U. goedgekeurde toevoeging."
parser = IngredientsParser.new
puts parser.parse(s).to_h.inspect
```
Results in
```
{
  :contains=>[
    {:name=>"Water", :amount=>"60%", :mark=>"*"},
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

```
$ ./test.rb -h
Usage: ./test.rb [options] --file|-f <filename>
       ./test.rb [options] --string|-s <ingredients>

    -f, --file FILE                  Parse all lines of the file as ingredient lists.
    -s, --string INGREDIENTS         Parse specified ingredient list.
    -q, --[no-]quiet                 Only show summary.
    -p, --parsed                     Only show lines that were successfully parsed.
    -n, --noresult                   Only show lines that had no result.
    -v, --[no-]verbose               Show more data (parsed tree).
    -h, --help                       Show this help

$ ./test.rb -v -s "tomato"
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

$ ./test.rb -q -f data/test-cases
parsed 35 (100.0%), no result 0 (0.0%)
```

## Test data

[`data/ingredient-samples-nl`](data/ingredient-samples-nl) contains about 150k
real-world ingredient lists found on the Dutch market. Each line contains one ingredient
list (newlines are encoded as `\n`, empty lines and those starting with `#` are ignored).
Currently almost three quarter is recognized and parsed. We aim to reach at least 90%.

