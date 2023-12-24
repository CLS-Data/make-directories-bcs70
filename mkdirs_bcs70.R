# install.packages(c("tidyverse", "labelled")) # Uncomment if you need to install
library(tidyverse)
library(glue)
library(magrittr)
library(haven)
library(labelled)

rm(list = ls())

# 1. Unzip UKDS Files ----
ukds_folders <- tribble(
  ~code, ~ukds_fld, ~sweep_fld,
  '2666', 'Birth and 22-Month Subsample, 1970-1972', '0y',
  '2690', '42-Month Subsample, 1973', '42m',
  '2699', 'Age 5, Sweep 2 1975', '5y',
  '3535', 'Age 16, Sweep 4, 1986', '16y',
  '3723', 'Age 10, Sweep 3, 1980', '10y',
  '3833', 'Age 26, Sweep 5, 1996', '26y',
  '4715', 'Age 21 Sample Survey, 1992', '21y',
  '5225', 'Age 16, Sweep 4 Head Teacher Questionnaire, 1986', '16y',
  '5558', 'Age 29, Sweep 6, 1999-2000', '29y',
  '5585', 'Age 34, Sweep 7, 2004-2005', '34y',
  '5641', 'Response Dataset, 1970-2016', 'xwave',
  '6095', 'Age 16, Sweep 4 Arithmetic Test, 1986', '16y',
  '6557', 'Age 38, Sweep 8, 2008-2009', '38y',
  '6941', 'Partnership Histories, 1986-2016', 'xwave',
  '6943', 'Activity Histories, 1986-2016', 'xwave',
  '7064', 'Age 10, Sweep 3 Special Needs Survey, 1980', '10y',
  '7473', 'Age 42, Sweep 9, 2012', '42y',
  '8288', 'Age 16, Sweep 4 Reading and Matrices Tests, 1986', '16y',
  '8547', 'Age 46, Sweep 10, 2016-2018', '46y',
  '8611', 'Age 46, Sweep 10 Accelerometry Data, 2016-2018', '46y',
  '8618', 'Age 16, Sweep 4 Dietary Diaries, 1986', '16y'
)

ukds_dict <- ukds_folders %>%
  select(code, ukds_fld) %>%
  deframe()

dir.create("UKDS")

unzip_folder <- function(zipped){
  sn <- str_sub(zipped, 8, 11)
  exdir <- glue("UKDS/{ukds_dict[sn]}")
  unzip(zipped, exdir = exdir)
}
list.files("Zipped", "\\.zip", full.names = TRUE) %>%
  walk(unzip_folder)


# 2. Place in Sweep Folders ----
## a. Make Sweep Folders ----
unique(ukds_folders$sweep_fld) %>%
  walk(dir.create)

## b. Move Files ----
fld_to_sweep <- function(file){
  dashes <- str_locate_all(file, "\\/")[[1]][1:2, 1]
  ukds_fld <- str_sub(file, dashes[1] + 1, dashes[2] - 1)
  sweep_fld <- ukds_folders$sweep_fld[ukds_folders$ukds_fld == ukds_fld]
  return(sweep_fld)
}

df_file <- glue("UKDS") %>%
  list.files("\\.dta$", recursive = TRUE, full.names = TRUE) %>%
  tibble(file = .) %>%
  mutate(n_dashes = str_count(file, "\\/"),
         dash_pos = str_locate_all(file, "\\/") %>%
           map2_int(n_dashes, ~ .x[.y, 1]),
         dta = str_sub(file, dash_pos + 1),
         folder = map_chr(file, fld_to_sweep),
         new_path = glue("{folder}/{dta}"))

df_file %$%
  walk2(file, new_path, ~ file.copy(.x, .y))


# 3. Make Variable Lookup ----
make_lookfor <- function(file){
  data <- read_dta(file, n_max = 1)
  
  tibble(pos = 1:ncol(data),
         variable = names(data),
         label = var_label(data, unlist = TRUE),
         col_type = map_chr(data, vctrs::vec_ptype_abbr),
         value_labels = map(data, val_labels))
}

lookup <- df_file %>%
  mutate(lookup = map(new_path, make_lookfor)) %>%
  select(folder, dta, lookup) %>%
  unnest(lookup)

lookup %>%
  select(-value_labels) %>%
  write_csv("lookup.csv")

saveRDS(lookup, file = "lookup.Rds")
