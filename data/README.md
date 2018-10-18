# Data files

## Tests

The files `test-*` are used for testing the parser(s). `test-cases` are short cases that cover different facets of
parsing ingredient lists, a sort of unit-tests. `test-samples-parsed` are real-world examples that are parsed
correctly, while `test-samples-with-issues` are known to have issues with the strict parser.

These files are licensed under the same license as the software.

## Questionmark

The files `ingredient-samples-qm-*` are contributed by [Questionmark](https://www.thequestionmark.org/) and
available under the terms of the Creative Commons License [CC-BY-NC](https://creativecommons.org/licenses/by-nc/4.0/).

## Open Food Facts

The files `ingredient-samples-off-*` are obtained from [Open Food Facts](https://world.openfoodfacts.org/data).
Splitting per country is done with a command like the following (adapt for different countries):

```
tail -n +1 en.openfoodfacts.org.products.csv | \
  cut -f 34,35 | grep '^Germany' | cut -f 2 | \
  sort | uniq > ingredient-samples-off-de
```

This data is licensed under the [Open Database License](https://opendatacommons.org/licenses/odbl/1.0/).
