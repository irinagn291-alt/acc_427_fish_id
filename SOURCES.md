# Fish ID — bundled source register

Checked 27 November 2026. No runtime API, API key, network model download, backend or paid service is used.

## Model and sample

Fish ID ships the official iNaturalist Small 2 vision model from release v25.01.15. The publisher provides an 8-bit Core ML model, taxonomy and MIT licence in its model distribution repository. The application includes the complete copyright and permission notice in `ReefLens/Resources/iNaturalist_LICENSE.txt`. [Publisher release](https://github.com/inaturalist/model-files/releases/tag/v25.01.15) · [MIT licence](https://github.com/inaturalist/model-files/blob/v25.01.15/LICENSE)

The model accepts a 299 × 299 RGB image and returns an array of 507 softmax scores. The app reads the output named `Identity` through Core ML and Vision on local CPU. The bundled index maps the 17 species-level outputs descended from Actinopterygii in the publisher's taxonomy. Scores retain their value from the original output across all taxa. A leading non-fish, weak evidence for fish or an unclear species result leaves manual atlas selection available. Similar species and fish outside the model can be confused. The user confirms every saved identification. [Official taxonomy and model assets](https://github.com/inaturalist/model-files/releases/expanded_assets/v25.01.15)

The built-in photograph shows a juvenile rainbow trout, *Oncorhynchus mykiss*, photographed by Sam Stukel/USFWS. The U.S. Fish & Wildlife Service marks the photograph Public Domain. `sample_rainbow.jpg` is the agency's published 1300-pixel JPEG. The sample can be run through the actual offline classifier without adding a find or updating personal statistics. [USFWS photograph and usage rights](https://www.fws.gov/media/rainbow-trout-4)

## Regulatory reference

Only Florida, USA, statewide freshwater is covered. Text is a short independently worded summary, not a complete legal code or a claim of global coverage.

- [FWC General Statewide Bag and Length Limits](https://myfwc.com/fishing/freshwater/regulations/general/): black bass, peacock bass, American eel, grass carp/alligator gar permit rules; local water exceptions apply.
- [FWC Freshwater Regulations](https://myfwc.com/fishing/freshwater/regulations/): current page states no new freshwater rule changes for 2026–27; water-specific rules can still differ.
- [Florida Wildlife Code, Chapter 68A-23](https://flrules.org/gateway/ChapterHome.asp?Chapter=68A-23), rule 68A-23.005: general season July 1–June 30 unless otherwise provided. Special local closures take precedence.

The bundled bag-limit summary was checked against FWC on 27 November 2026, including the combined panfish and separate crappie limits. The app displays the check date, jurisdiction and local-rule caveat in English, Arabic, Traditional Chinese, German, French and Spanish. Bundled references change only with app releases. Recognition never establishes legal identity or edibility. No retention advice is inferred from biological spawning dates.

## Field guide

The atlas covers all 17 fish species in the selected iNaturalist model, plus five manual field-guide profiles: Florida bass, European perch, tench, walleye and black crappie. The 22 profiles describe conspicuous marks, typical length, habitat, geographic range and breeding or larval life history. The Moorish idol is a marine reef fish. The two mosquitofishes give birth to live young. Typical lengths and seasonal descriptions vary with population and locality.

The app keeps legacy records of *Micropterus salmoides* associated with that scientific name. The guide explains its overlap in visible features with *Micropterus nigricans*.

Primary reference pages consulted:

- [TPWD Largemouth Bass](https://tpwd.texas.gov/huntwild/wild/species/lmb/).
- [FWS Northern Pike](https://www.fws.gov/species/northern-pike-esox-lucius).
- [FWS Rainbow Trout](https://www.fws.gov/species/rainbow-trout-oncorhynchus-mykiss).
- [FWS Brook Trout](https://www.fws.gov/species/brook-trout-salvelinus-fontinalis).
- [FWC Bluegill](https://myfwc.com/wildlifehabitats/profiles/freshwater/bluegill/).
- [FWC Freshwater Habitats](https://myfwc.com/wildlifehabitats/habitat/freshwater/).
- [TPWD freshwater species identification booklet](https://tpwd.texas.gov/publications/pwdpubs/media/pwd_lf_k0700_0692.pdf).

Additional fisheries references for the expanded guide:

- [USGS largemouth bass taxonomy and native range](https://nas.er.usgs.gov/queries/factsheet.aspx?SpeciesID=401)
- [USGS eastern mosquitofish diagnosis and range](https://nas.er.usgs.gov/queries/factsheet.aspx?speciesid=849) and [USFWS western mosquitofish](https://www.fws.gov/carp/carp/sites/default/files/documents/2024-06/ecological-risk-screening-summary-western-mosquitofish.pdf)
- [Missouri Department of Conservation channel catfish](https://mdc.mo.gov/discover-nature/field-guide/channel-catfish), [creek chub](https://mdc.mo.gov/discover-nature/field-guide/creek-chub) and [green sunfish](https://mdc.mo.gov/discover-nature/field-guide/green-sunfish)
- [USFWS redbreast sunfish ecological summary](https://www.fws.gov/sites/default/files/documents/2025-04/ecological-risk-screening-summary-redbreast-sunfish.pdf)
- [Fisheries and Oceans Canada yellow perch](https://www.dfo-mpo.gc.ca/species-especes/profiles-profils/yellowperch-perchaude-eng.html) and [Ontario fisheries identification guide](https://www.ontario.ca/page/learn-fish-guide)
- [University of Michigan Animal Diversity Web pumpkinseed](https://animaldiversity.org/accounts/Lepomis_gibbosus/) and [Waikīkī Aquarium Moorish idol](https://www.waikikiaquarium.org/experience/animal-guide/fishes/moorish-idol/moorish-idol/)

All icon and guide artwork is original geometric illustration generated by this project's code. Illustrations are labeled and are not represented as photographs or taxonomic evidence.
