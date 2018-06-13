
## Remove whitespace greediness

Many rules consume trailing whitespace. This is not a good idea, because sometimes whitespace
separates items on a higher level. E.g. _tomaat (20%)_ now goes wrong and could be solved by this.


## Extra info after ingredient list.

Will we handle these as ingredients, or as 'additional info'?

- "100% BIJENPOLLEN*, *Biologisch. Geen allergenen."
- "Groenten*, zetmeel, zout.\nKan selderij bevatten.\n\n* Duurzaam geteeld\n"
- "Ingrediënten: kruidnoot (...), cacaopoeder.\nBevat >30% cacao\nE=goedgekeurd."
- "Linzen, aroma. Kan gluten, melk en soja bevatten."
- "Melk, SOJA.\nIn de fabriek worden gluten verwerkt."
- "MELK, suiker,\n\naroma, zout." (really happens, e.g. nut 3654140, verified in GS1 data)
- "Saus: tomaat, water.\n\nPasta: tarwe.\n\nKan gluten bevatten."
- "ingredienten:suiker, olie.\nkleurstof beinvloedt kinderen.\ncacao 34%, puur 50.7%\nsporen van noten, gluten en eieren"
- "SPELT volkoren**, roggemeel**, zeezout,\n\n* = Biologisch\n** = Demeter"

Conclusion: we can make this 'additional info'. Needs adaptation of parse output.


## Amounts

Should be fairly straightforward.


## Abbreviations

Some abbreviations are parsed as separate ingredients
(like _o.a. tarwe_ now becomes _['o', 'a', 'tarwe']_).

* _o.a._


## Characters

`char` misses many unicode characters. Maybe it would be useful to base it on exclusions instead.


## Ingredient lists with newlines

In various forms. Pending.

