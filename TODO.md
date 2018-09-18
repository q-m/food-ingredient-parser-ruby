
# Issues

- `saus: (tomaat, water)` is not parsed
- Sometimes a dot is found in the middle of a comma-separated list, and all after that is marked as additional info.
- Separate `74% varkensvlees waarvan 32,3% varkensseparatorvlees`? (not parsed now)
- Sometimes dash is separator: `stabilisatoren: e407-e412-e415` (but not always: `kleurstof: paprika-extract`).
- `char` misses many unicode characters. Maybe it would be useful to base it on exclusions instead.
- double marks do occur: `Groenten* (tomaat* **: 31%, ui*, SELDERIJ*, wortel*). * Bio ** Duurzame tomaten.`
