# ============================================================
# Figure: Species identification confidence (C) heatmap
# Mean C-values by user group and species
# ============================================================

library(ggplot2)
library(tidyr)
library(dplyr)

# ------------------------------------------------------------
# 1. DATA
# Structure: user group, then per species: n_recognised, n_answered, c_ave
# calculated in excel
# ------------------------------------------------------------
data <- data.frame(
  user_group = c("Water sports participants", "Divers", "Recreational fishers",
                 "Coastal residents", "Researchers",
                 "Subsistence fishers", "Commercial fishers"),

  lesser_n = c(37, 34, 65,  9,  9, 3, 2),
  lesser_N = c(70, 62, 71, 21, 10, 3, 2),
  lesser_c = c(0.37, 0.39, 0.45, 0.26, 0.47, 0.47, 0.29),

  blunt_n  = c(19,  8, 28,  4,  1, 0, 1),
  blunt_N  = c(67, 58, 70, 19, 10, 2, 2),
  blunt_c  = c(0.54, 0.51, 0.44, 0.35, 0.50, NA, 0.25),

  grey_n   = c(10, 10, 24,  4,  4, 0, 1),
  grey_N   = c(66, 57, 71, 20, 10, 2, 2),
  grey_c   = c(0.44, 0.48, 0.44, 0.40, 0.71, NA, 0.08),

  speck_n  = c( 6,  5,  8,  4,  0, 0, 1),
  speck_N  = c(68, 56, 69, 19, 10, 2, 2),
  speck_c  = c(0.38, 0.17, 0.31, 0.29, NA, NA, 0.08),

  bow_n    = c( 2, 11, 25,  2,  4, 0, 0),
  bow_N    = c(66, 57, 71, 20, 10, 2, 2),
  bow_c    = c(0.46, 0.68, 0.53, 0.38, 0.65, NA, NA),

  wedge_n  = c(13, 13, 32,  4,  5, 1, 1),
  wedge_N  = c(66, 55, 72, 20, 10, 2, 2),
  wedge_c  = c(0.39, 0.47, 0.44, 0.19, 0.62, 0.25, 0.25),

  stringsAsFactors = FALSE
)

# ------------------------------------------------------------
# 2. RESHAPE TO LONG FORMAT
# ------------------------------------------------------------
species_list <- c("A. annulatus", "A. blochii", "A. leucospilus",
                   "A. ocellatus", "R. ancylostomus", "R. djiddensis")
prefix_list  <- c("lesser", "blunt", "grey", "speck", "bow", "wedge")

long <- bind_rows(lapply(seq_along(species_list), function(i) {
  sp  <- species_list[i]
  pre <- prefix_list[i]
  data.frame(
    user_group = data$user_group,
    species    = sp,
    c_ave      = data[[paste0(pre, "_c")]],
    n_rec      = data[[paste0(pre, "_n")]],
    n_ans      = data[[paste0(pre, "_N")]],
    stringsAsFactors = FALSE
  )
}))

long <- long %>%
  mutate(cell_label = ifelse(is.na(c_ave), "-", paste0(n_rec, "/", n_ans)))

long$species <- factor(long$species, levels = species_list)

group_order <- c("Water sports participants", "Divers", "Recreational fishers",
                  "Coastal residents", "Researchers",
                  "Subsistence fishers", "Commercial fishers")
long$user_group <- factor(long$user_group, levels = rev(group_order))

# ------------------------------------------------------------
# 3. PLOT
# ------------------------------------------------------------
p <- ggplot(long, aes(x = species, y = user_group, fill = c_ave)) +
  geom_tile(color = "white", linewidth = 0.8) +
  geom_text(aes(label = cell_label), size = 3.2, color = "black") +
  scale_fill_gradient(
    low      = "#D6E4F0",
    high     = "#0F2080",
    na.value = "#F0F0F0",
    name     = "Mean identification\nconfidence (C)",
    limits   = c(0, 1),
    breaks   = c(0, 0.25, 0.50, 0.75, 1.0),
    labels   = c("0.00", "0.25", "0.50", "0.75", "1.00")
  ) +
  scale_x_discrete(position = "top") +
  labs(x = NULL, y = NULL) +
  theme_minimal(base_size = 12) +
  theme(
    text         = element_text(color = "black"),
    axis.text.x  = element_text(face = "italic", size = 10, angle = 30,
                                 hjust = 0, vjust = 0.02, color = "black"),
    axis.text.y  = element_text(size = 10, color = "black"),
    panel.grid   = element_blank(),
    legend.position = "right",
    legend.title = element_text(size = 9, face = "bold", color = "black"),
    legend.text  = element_text(size = 8, color = "black"),
    plot.margin  = margin(10, 10, 10, 10)
  )

# ------------------------------------------------------------
# 4. EXPORT
# ------------------------------------------------------------
ggsave("figures/confidence_heatmap.png", plot = p, width = 9, height = 5, dpi = 600)
ggsave("figures/confidence_heatmap.pdf", plot = p, width = 9, height = 5)

message("Done — confidence_heatmap.png/.pdf saved")
