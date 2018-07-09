
# Issues

- `saus: (tomaat, water)` is not parsed
- Sometimes allergens are quoted in html with `<b>...</b>` (can occur intermixed with other forms).
- Sometimes a dot is found in the middle of a comma-separated list, and all after that is marked as additional info.
- Separate `74% varkensvlees waarvan 32,3% varkensseparatorvlees`? (not parsed now)
- Check if prefix `dit zit er in` is always stripped
- Sometimes dash is separator: `stabilisatoren: e407-e412-e415` (but not always: `kleurstof: paprika-extract`).
- `char` misses many unicode characters. Maybe it would be useful to base it on exclusions instead.
- `and` as last separator (but watch out for `soja- en tarwe-eiwit` and `diverse kruiden en specerijen`).
- double marks do occur: `Groenten* (tomaat* **: 31%, ui*, SELDERIJ*, wortel*). * Bio ** Duurzame tomaten.`


# Ideas

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
