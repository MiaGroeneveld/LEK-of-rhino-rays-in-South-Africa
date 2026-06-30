# ============================================================
# Figure: Pup and group sighting location map
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
sightings_raw <- read_excel("data/locations_pup_group.xlsx")

sightings_geo <- sightings_raw %>%
  geocode(address = Location, method = "osm")

write.csv(sightings_geo, "data/pup_group_geocoded.csv", row.names = FALSE)

# ------------------------------------------------------------
# 2. COLOURS
# ------------------------------------------------------------
type_cols <- c(
  "Pup sightings"   = "#F5793A",
  "Group sightings" = "#85C0F9"
)

# ------------------------------------------------------------
# 3. BASEMAP DATA
# ------------------------------------------------------------
world     <- ne_countries(scale = "medium", returnclass = "sf")
provinces <- st_read("data/gadm41_ZAF_1.json")

# ------------------------------------------------------------
# 4. PLOT
# ------------------------------------------------------------
p <- ggplot() +
  geom_sf(data = world, fill = "gray95", color = "gray70", linewidth = 0.2) +
  geom_sf(data = provinces, fill = NA, color = "gray70", linewidth = 0.2) +
  geom_point(data = sightings_geo,
             aes(x = long, y = lat, color = Type),
             size = 3, alpha = 0.7) +
  scale_color_manual(values = type_cols, name = "Sighting type") +
  coord_sf(xlim = c(14, 35.5), ylim = c(-36, -19), expand = FALSE) +
  annotation_scale(location = "br", width_hint = 0.1,
                    line_width = 0.3, text_cex = 0.6) +
  scale_x_continuous(breaks = seq(15, 35, by = 5),
                      labels = function(x) paste0(abs(x), "\u00b0")) +
  scale_y_continuous(breaks = seq(-35, -20, by = 5),
                      labels = function(y) paste0(abs(y), "\u00b0")) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.major = element_line(color = "gray90", linewidth = 0.2),
    axis.title   = element_blank(),
    axis.text    = element_text(size = 9, color = "black"),
    legend.title = element_text(size = 9, face = "bold", color = "black"),
    legend.text  = element_text(size = 8, color = "black")
  )

# ------------------------------------------------------------
# 5. EXPORT
# ------------------------------------------------------------
ggsave("figures/pup_group_sightings_map.png", plot = p, width = 8, height = 7, dpi = 600)
ggsave("figures/pup_group_sightings_map.pdf", plot = p, width = 8, height = 7)

message("Done — pup_group_sightings_map.png/.pdf saved")
