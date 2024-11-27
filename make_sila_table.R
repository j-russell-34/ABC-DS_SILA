library(tidyverse)
library(dplyr)
library(purrr)
library(glue)

in_dir <- "/Users/jasonrussell/Documents/INPUTS/sila_A001"
out_dir <- "/Users/jasonrussell/Documents/OUTPUTS/sila_A001"

#import qdec and sclimbic data
qdec <- read.table(glue("{in_dir}/long.qdec.table.dat"), header = TRUE)
centiloid <- read.csv(glue("{in_dir}/ABC_DS_centiloid.csv"))

#add event to subject id in centiloid table
centiloid$fsid <- glue("{as.character(centiloid$subject_label)}_e{as.character(centiloid$event_sequence)}")

#combine dataframes based on subject_id/event code
data <- merge(qdec, centiloid, by="fsid")

write.csv(data, file = glue("{out_dir}/ABC_DS_sila_tall.csv"))