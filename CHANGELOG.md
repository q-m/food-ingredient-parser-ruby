# 1.1.7 (2020-12-28)

* Keep chemical ingredient names together
* Support more variates of amount
* Small parsing and cleaning improvements

# 1.1.6 (2020-11-19)

* Parsing improvements

# 1.1.5 (2019-11-14)

* Small parsing improvements

# 1.1.4 (2018-10-22)

* Fix alphabetic mark detection
* Recognize percentage followed by name without space
* Improve e-number handling

# 1.1.3 (2018-10-12)

* Parsing improvements

# 1.1.2 (2018-09-28)

* Parsing improvements (split E-numbers when separated by dashes)

# 1.1.1 (2018-09-25)

* Parsing improvements

# 1.1.0 (2018-09-24)

* Parsing improvements
* Add `to_html` to the loose parser
* Include loose parser in example

# 1.0.0 (2018-09-21)

* Small parsing improvements

# 1.0.0.pre.9 (2018-09-19)

* Some small parsing improvements for both parsers
* The loose parser doesn't return empty names anymore (unless you use the `normalize: true` option)
* Prepare for returning multiple marks
* Allow colon before a bracket

This version is not fully backwards compatible, as marks are now returned as an array in `to_h`.

# 1.0.0.pre.8 (2018-09-19)

* Only recognize 'and' as separator when required for parsing
* Improve note parsing and recognition

# 1.0.0.pre.7 (2018-09-18)

* Fix colon nesting

# 1.0.0.pre.6 (2018-09-17)

* Add a loose parser

This version is not fully backwards compatible: the strict parser has been
renamed from `FoodIngredientParser::Parser` to `FoodIngredientParser::Strict::Parser`.

# 1.0.0.pre.5 (2018-09-07)

* Add depth to HTML output
* Interactive editor example

# 1.0.0.pre.4 (2018-09-05)

* Add method to generate HTML output of original text
* Pass parse options to Treetop (unstable interface)
* Parsing improvements for amount and mark

# 1.0.0.pre.3 (2018-08-31)

* Parsing improvements

# 1.0.0.pre.2 (2018-08-10)

* Fix test tool when text cannot be parsed

# 1.0.0.pre.1 (2018-08-09)

* Initial release
