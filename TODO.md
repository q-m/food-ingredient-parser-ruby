
## Extra info after ingredient list.

- "100% BIJENPOLLEN*, *Biologisch. Geen allergenen."
- "Groenten*, zetmeel, zout.\nKan selderij bevatten.\n\n* Duurzaam geteeld\n"
- "Ingrediënten: kruidnoot (...), cacaopoeder.\nBevat >30% cacao\nE=goedgekeurd."
- "Linzen, aroma. Kan gluten, melk en soja bevatten."
- "Melk, SOJA.\nIn de fabriek worden gluten verwerkt."
- "MELK, suiker,\n\naroma, zout." (really happens, e.g. nut 3654140, verified in GS1 data)
- "Saus: tomaat, water.\n\nPasta: tarwe.\n\nKan gluten bevatten."
- "ingredienten:suiker, olie.\nkleurstof beinvloedt kinderen.\ncacao 34%, puur 50.7%\nsporen van noten, gluten en eieren"
- "SPELT volkoren**, roggemeel**, zeezout,\n\n* = Biologisch\n** = Demeter"

These things are already consumed, now, but need to find a place in the data structure.
We can make this 'additional info' (needs adaptation of parse output).


## Abbreviations

Some abbreviations are parsed as separate ingredients
(like _o.a. tarwe_ now becomes _['o', 'a', 'tarwe']_).

* _o.a._ ("onder andere")
* _e.g._ ("europese gemeenschap")


## Characters

`char` misses many unicode characters. Maybe it would be useful to base it on exclusions instead.


## Other issues

- Sometimes ingredient list is enclosed by quotes.
- Sometimes allergens are quoted in html with `<b>...</b>` (can occur intermixed with other forms).
- Sometimes dash is separator: `stabilisatoren: e407-e412-e415` (but not always: `kleurstof: paprika-extract`).
- Occasionally a tab character appears as (line-trailing) whitespace.
- _Aqua, Alcohol denat.*, more_ stops the ingredient list after _denat._
- Sometimes a dot is found in the middle of a comma-separated list, and all after that is marked as additional info.

## Detection of allergens

In various forms:
- `..., volle {melk}, ...`
- `..., volle MELK, ...`
- `... . Kan melk bevatten.` (various forms like `sporen van`, etc.)
- `..., kan melk bevatten.` (ibid)
- `..., botersaus (bevat melk), ...`
- `..., VISsaus (VIS), ...`
- `..., KAAS (17%) (EDAMMER (kleurstof: bèta-caroteen, MOZZARELLA), water, ...`
- `..., <b>melk</b>, ...`
- ...


## Namespace

It would be good to put code and grammers in a namespace, so that it can be loaded in other programs.
May be a matter of adding `module FoodIngredientParser` to some places plus some tiny tweaks.
See also [cjheath/treetop#8](https://github.com/cjheath/treetop/issues/8).
