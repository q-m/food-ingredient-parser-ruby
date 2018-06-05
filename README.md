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

## Test data

[data/ingredient-samples-nl](`data/ingredient-samples-nl`) contains about 150k
real-world ingredient lists found on the Dutch market. Each line contains one ingredient
list, and newlines are encoded as `\n`.
Currently about half of them is recognized and parsed. We aim to reach at least 90%.

