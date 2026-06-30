# LEK of rhino rays in South Africa

This repository contains R scripts used to produce spatial figures and the
species identification confidence heatmap for the manuscript:

> Who knows what? Local ecological knowledge of rhino rays among coastal ocean users in South Africa
> 
> Mia J. Groeneveld, Evan Nazareth, Juliana D. Klein, Michaela van Staden, Rhett H. Bennett, Aletta E. Bester- van der Merwe

## Data availability

Raw survey response data are not included in this repository to protect
respondent anonymity. Geocoded location data were derived from
respondent-provided text descriptions, cleaned to match OpenStreetMap
location parameters (https://www.openstreetmap.org/), and georeferenced
using the `tidygeocoder` R package (Cambon et al. 2021).

Province boundary data: `gadm41_ZAF_1.json` (GADM, https://gadm.org/).

Maps were post-edited in Canva

## Dependencies

```r
install.packages(c(
  "ggplot2", "sf", "rnaturalearth", "rnaturalearthdata",
  "ggspatial", "cowplot", "readxl", "tidygeocoder", "dplyr", "tidyr"
))
```
