# WiP - Food ingredient parser

Ingredients listed on food products in various ways. This [Ruby](https://www.ruby-lang.org/) gem
parses the ingredient text and returns a structured representation.

_This is currently being developed, this project is not yet in a usable state._

## Dependencies

Ruby and the gems: [treetop](http://cjheath.github.io/treetop) and pry.

## Test data

[data/ingredient-samples-nl](`data/ingredient-samples-nl`) contains about 150k
real-world ingredient lists found on the Dutch market. Each line contains one ingredient
list, and newlines are encoded as `\n`.
Currently about half of them is recognized and parsed. We aim to reach at least 90%.

