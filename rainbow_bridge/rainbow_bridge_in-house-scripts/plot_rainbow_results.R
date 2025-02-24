# Set the working directory to the location of the script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

getwd()

# Load necessary packages
library(ggplot2)
library(dplyr)

# Read the TSV file
pre_data <- read.csv("blast_lca_taxonomy.tsv", sep = "\t", header = TRUE)

# Create a new data frame with qcov and pident rounded to two decimal points for plotting purposes
data <- pre_data %>%
  mutate(qcov = round(qcov, 1),
         pident = round(pident, 1))

# Create a histogram of the count of unique species
species_count <- data %>%
  group_by(species) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

species_plot <- ggplot(species_count, aes(x = reorder(species, -count), y = count)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = count), vjust = -0.5) +
  labs(x = "Species", y = "Number of ZOTUs", title = "Count of ZOTUs per Species") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Save the species histogram as a PNG file
ggsave("zotus_per_species.png", plot = species_plot, width = 10, height = 8)

# Create a histogram of the count of unique family
family_count <- data %>%
  group_by(family) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

family_plot <- ggplot(family_count, aes(x = reorder(family, -count), y = count)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = count), vjust = -0.5) +
  labs(x = "Family", y = "Number of ZOTUs", title = "Count of ZOTUs per Family") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Save the family histogram as a PNG file
ggsave("zotus_per_family.png", plot = family_plot, width = 10, height = 8)

##### Violins

### pident

# Create a histogram of the count of unique species
#species_count_normal_order <- data %>%
#  group_by(species) %>%
#  summarise(count = n()) %>%
#  arrange(count)

# Convert pident to numeric
#data$pident <- as.numeric(as.character(data$pident))

# Create violin plot for pident distribution per species including "LCA_dropped"
#violin_plot_pident <- ggplot(data, aes(x = pident, y = factor(species, levels = species_count_normal_order$species))) +
#  geom_violin() +
#  geom_point(data = data %>% group_by(species) %>% filter(n() == 1), 
#             aes(x = pident, y = species), 
#             color = "black", size = 1) +
#  geom_jitter(data = data %>% group_by(species) %>% filter(n() >= 2 & n() <= 5), 
#              aes(x = pident, y = species), 
#              color = "black", size = 1) +
#  labs(x = "pident", y = "Species", title = "Pident distribution per species") +
# scale_x_reverse() 

#violin_plot_pident

# Save the violin plot as a PNG file
#ggsave("pident_per_species.png", plot = violin_plot_pident, width = 10, height = 6)


#### Boxplots

## qcov

# Convert qcov to numeric
data$qcov <- as.numeric(as.character(data$qcov))

# Create a data frame for species count to get the order by abundance
species_count_asc <- data %>%
  group_by(species) %>%
  summarise(count = n()) %>%
  arrange(count)  # Order by abundance, low to high

# Create boxplot for qcov distribution per species including "LCA_dropped"
boxplot_qcov <- ggplot(data, aes(x = qcov, y = factor(species, levels = species_count_asc$species))) +
  geom_boxplot() +
  geom_point(data = data %>% group_by(species) %>% filter(n() == 1), 
             aes(x = qcov, y = species), 
             color = "black", size = 0.5) +
  geom_jitter(data = data %>% group_by(species) %>% filter(n() >= 2 & n() <= 5), 
              aes(x = qcov, y = species), 
              color = "black", size = 0.5, width = 0.1) +
  labs(x = "qcov", y = "Species", title = "Qcov distribution per species") +
  scale_x_reverse()

boxplot_qcov

# Save the boxplot as a PNG file
ggsave("qcov_per_species.png", plot = boxplot_qcov, width = 10, height = 8)

## pident

# Convert pident to numeric
data$pident <- as.numeric(as.character(data$pident))

# Create boxplot for pident distribution per species including "LCA_dropped"
boxplot_pident <- ggplot(data, aes(x = pident, y = factor(species, levels = species_count_asc$species))) +
  geom_boxplot() +
  geom_point(data = data %>% group_by(species) %>% filter(n() == 1), 
             aes(x = pident, y = species), 
             color = "black", size = 0.5) +
  geom_jitter(data = data %>% group_by(species) %>% filter(n() >= 2 & n() <= 5), 
              aes(x = pident, y = species), 
              color = "black", size = 0.5, width = 0.1) +
  labs(x = "pident", y = "Species", title = "Pident distribution per species") +
  scale_x_reverse()

# Save the boxplot as a PNG file
ggsave("pident_per_species.png", plot = boxplot_pident, width = 10, height = 6)

## eval

# Convert evalue to numeric
data$evalue <- as.numeric(as.character(data$evalue))

# Create boxplot for evalue distribution per species including "LCA_dropped"
boxplot_evalue <- ggplot(data, aes(x = evalue, y = factor(species, levels = species_count_asc$species))) +
  geom_boxplot() +
  geom_point(data = data %>% group_by(species) %>% filter(n() == 1), 
             aes(x = evalue, y = species), 
             color = "black", size = 0.5) +
  labs(x = "evalue", y = "Species", title = "E-value distribution per species") #+

# Save the boxplot as a PNG file
ggsave("evalue_per_species.png", plot = boxplot_evalue, width = 10, height = 8)

