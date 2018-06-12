# WiP - Food ingredient parser

Ingredients listed on food products in various ways. This [Ruby](https://www.ruby-lang.org/) gem
parses the ingredient text and returns a structured representation.

_This is currently being developed, this project is not yet in a usable state._

## Dependencies

Ruby and the gems: [treetop](http://cjheath.github.io/treetop) and pry.

## Example

```ruby
require_relative 'ingredients-parser'

s = "Sprankelend water, suiker, voedingszuren: citroenzuur, appelzuur, zuurteregelaar: natriumgluconaat, natuurlijke citroen-limoen aroma's, zoetstof: steviolglycosiden."
parser = IngredientsParser.new
puts parser.parse(s).to_a.inspect
```
Results in
```
[
  {:name=>"Sprankelend water"},
  {:name=>"suiker"},
  {:name=>"voedingszuren", :contains=>[
    {:name=>"citroenzuur"}
  ]},
  {:name=>"appelzuur"},
  {:name=>"zuurteregelaar", :contains=>[
    {:name=>"natriumgluconaat"}
  ]},
  {:name=>"natuurlijke citroen-limoen aroma's"},
  {:name=>"zoetstof", :contains=>[
    {:name=>"steviolglycosiden"}
  ]}
]
```

## Test tool

```
$ ./test.rb -h
Usage: ./test.rb [options] --file|-f <filename>
       ./test.rb [options] --string|-s <ingredients>

    -f, --file FILE                  Parse all lines of the file as ingredient lists.
    -s, --string INGREDIENTS         Parse specified ingredient list.
    -q, --[no-]quiet                 Only show summary.
    -v, --[no-]verbose               Show more data (parsed tree).
    -h, --help                       Show this help

$ ./test.rb -v -s "tomato"
"tomato"
RootNode+Ingredients0 offset=0, "tomato" (contains):
  SyntaxNode offset=0, ""
  ListNode+List13 offset=0, "tomato" (contains):
    SyntaxNode+List12 offset=0, "tomato" (ingredient):
      IngredientNode+SimpleIngredient1 offset=0, "tomato" (name):
        SyntaxNode+SimpleIngredient0 offset=0, "tomato" (char):
          SyntaxNode offset=0, "t"
          SyntaxNode offset=1, "omato":
            SyntaxNode offset=1, "o"
            SyntaxNode offset=2, "m"
            SyntaxNode offset=3, "a"
            SyntaxNode offset=4, "t"
            SyntaxNode offset=5, "o"
      SyntaxNode offset=6, ""
  SyntaxNode offset=6, ""
  SyntaxNode offset=6, ""
  SyntaxNode offset=6, ""
[{:name=>"tomato"}]

$ ./test.rb -q -f data/test-cases
parsed 15, no result 0
```

## Test data

[data/ingredient-samples-nl](`data/ingredient-samples-nl`) contains about 150k
real-world ingredient lists found on the Dutch market. Each line contains one ingredient
list, and newlines are encoded as `\n`.
Currently about half of them is recognized and parsed. We aim to reach at least 90%.

