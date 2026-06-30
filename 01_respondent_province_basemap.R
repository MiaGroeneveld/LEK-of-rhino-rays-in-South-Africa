# ============================================================
# Figure: South Africa province basemap with Africa inset
# Used as base for respondent distribution map
# (respondent counts and labels added in Canva)
# ============================================================

library(ggplot2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(ggspatial)

# ------------------------------------------------------------
# 1. DATA
# ------------------------------------------------------------
world     <- ne_countries(scale = "medium", returnclass = "sf")
africa    <- ne_countries(continent = "Africa", scale = "medium", returnclass = "sf")
provinces <- st_read("data/gadm41_ZAF_1.json")

# ------------------------------------------------------------
# 2. MAIN MAP
# ------------------------------------------------------------
main_map <- ggplot() +
  geom_sf(data = world, fill = "gray95", color = "gray70", linewidth = 0.2) +
  geom_sf(data = provinces, fill = "gray95", color = "gray40", linewidth = 0.5) +
  coord_sf(xlim = c(15, 34), ylim = c(-35.5, -21), expand = FALSE) +
  annotation_scale(location = "br", width_hint = 0.15,
                    line_width = 0.3, text_cex = 0.7) +
  scale_x_continuous(breaks = seq(15, 35, by = 5),
                      labels = function(x) paste0(abs(x), "\u00b0E")) +
  scale_y_continuous(breaks = seq(-35, -20, by = 5),
                      labels = function(y) paste0(abs(y), "\u00b0S")) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.major = element_line(color = "gray90", linewidth = 0.2),
    axis.title   = element_blank(),
    axis.text    = element_text(size = 9, color = "black"),
    text         = element_text(color = "black"),
    panel.border = element_rect(color = "gray40", fill = NA, linewidth = 0.5)
  )

# ------------------------------------------------------------
# 3. AFRICA INSET
# Black box shows SA map extent
# ------------------------------------------------------------
sa_bbox <- st_as_sfc(st_bbox(c(
  xmin = 15, xmax = 34, ymin = -35.5, ymax = -21
), crs = 4326))

africa_inset <- ggplot() +
  geom_sf(data = world, fill = "gray95", color = "gray60", linewidth = 0.15) +
  geom_sf(data = africa, fill = "gray95", color = "gray50", linewidth = 0.15) +
  geom_sf(data = sa_bbox, fill = NA, color = "black", linewidth = 0.5) +
  coord_sf(xlim = c(-20, 55), ylim = c(-40, 40), expand = FALSE) +
  theme_void() +
  theme(
    panel.border     = element_rect(color = "gray40", fill = NA, linewidth = 0.3),
    panel.background = element_rect(fill = "white", color = NA)
  )

# ------------------------------------------------------------
# 4. EXPORT
# Main map and Africa inset exported separately and combined
# manually in Canva (respondent counts/labels also added there)
# ------------------------------------------------------------
ggsave("figures/province_basemap_main.png", plot = main_map, width = 8, height = 7, dpi = 600)
ggsave("figures/province_basemap_inset.png", plot = africa_inset, width = 3, height = 4, dpi = 600)

message("Done — province_basemap_main.png and province_basemap_inset.png saved")
