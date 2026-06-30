# ============================================================
# Figure: Species sighting location map
# Faceted by species, point size = number of reports
# ============================================================

library(readxl)
library(tidygeocoder)
library(dplyr)
library(ggplot2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(ggspatial)

# ------------------------------------------------------------
# 1. LOAD AND GEOCODE
# ------------------------------------------------------------
sightings <- read_excel("data/locations.xlsx")

sightings_geo <- sightings %>%
  geocode(address = Location, method = "osm")

write.csv(sightings_geo, "data/sightings_geocoded.csv", row.names = FALSE)

# ------------------------------------------------------------
# 2. BASEMAP DATA
# ------------------------------------------------------------
world     <- ne_countries(scale = "medium", returnclass = "sf")
provinces <- st_read("data/gadm41_ZAF_1.json")

# ------------------------------------------------------------
# 3. COUNT FREQUENCY BY LOCATION
# ------------------------------------------------------------
sightings_count <- sightings_geo %>%
  group_by(Species, Location, lat, long) %>%
  summarise(n = n(), .groups = "drop")

# ------------------------------------------------------------
# 4. SPECIES ORDER, LABELS AND COLOURS
# ------------------------------------------------------------
species_order <- c(
  "Lesser guitarfish", "Bluntnose guitarfish", "Greyspot guitarfish",
  "Speckled guitarfish", "Bowmouth guitarfish", "Whitespotted wedgefish"
)

sightings_count$Species <- factor(sightings_count$Species, levels = species_order)

species_cols <- c(
  "#F5793A",  # Lesser
  "#A34B00",  # Bluntnose
  "#A95AA1",  # Greyspot
  "#7B3294",  # Speckled
  "#85C0F9",  # Bowmouth
  "#0F2080"   # Wedgefish
)

italic_labeller <- as_labeller(
  c(
    "Lesser guitarfish"      = "italic('A. annulatus')",
    "Bluntnose guitarfish"   = "italic('A. blochii')",
    "Greyspot guitarfish"    = "italic('A. leucospilus')",
    "Speckled guitarfish"    = "italic('A. ocellatus')",
    "Bowmouth guitarfish"    = "italic('R. ancylostomus')",
    "Whitespotted wedgefish" = "italic('R. djiddensis')"
  ),
  default = label_parsed
)

# ------------------------------------------------------------
# 5. PLOT
# ------------------------------------------------------------
p <- ggplot() +
  geom_sf(data = world, fill = "gray95", color = "gray70", linewidth = 0.2) +
  geom_sf(data = provinces, fill = NA, color = "gray70", linewidth = 0.2) +
  geom_point(data = sightings_count,
             aes(x = long, y = lat, size = n, color = Species),
             alpha = 0.7) +
  scale_size_continuous(
    range  = c(2, 8),
    name   = "No. of\nreports",
    breaks = c(1, 5, 9),
    labels = c("1", "5", "9")
  ) +
  scale_color_manual(values = species_cols, guide = "none") +
  coord_sf(xlim = c(15, 34), ylim = c(-35.5, -21), expand = FALSE) +
  facet_wrap(~Species, labeller = italic_labeller) +
  annotation_scale(location = "br", width_hint = 0.1,
                    line_width = 0.3, text_cex = 0.6) +
  scale_x_continuous(breaks = seq(15, 35, by = 5),
                      labels = function(x) paste0(abs(x), "\u00b0")) +
  scale_y_continuous(breaks = seq(-35, -20, by = 2),
                      labels = function(y) paste0(abs(y), "\u00b0")) +
  guides(
    size = guide_legend(
      title        = "No. of\nreports",
      title.theme  = element_text(size = 8, face = "bold", color = "black"),
      label.theme  = element_text(size = 7, color = "black"),
      override.aes = list(color = "grey40", alpha = 0.8)
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.major = element_line(color = "gray90", linewidth = 0.2),
    strip.text       = element_text(face = "italic", size = 11, color = "black"),
    axis.title       = element_blank(),
    axis.text        = element_text(size = 8, color = "black"),
    legend.position  = "right",
    legend.title     = element_text(size = 8, face = "bold", color = "black"),
    legend.text      = element_text(size = 7, color = "black"),
    text             = element_text(color = "black")
  )

# ------------------------------------------------------------
# 6. EXPORT
# ------------------------------------------------------------
ggsave("figures/sightings_map.png", plot = p, width = 10, height = 8, dpi = 600)
ggsave("figures/sightings_map.pdf", plot = p, width = 10, height = 8)

message("Done — sightings_map.png/.pdf saved")
