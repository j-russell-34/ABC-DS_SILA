library(tidyverse)
library(dplyr)
library(purrr)
library(glue)

in_dir <- "/Users/jasonkru/Documents/inputs/ABCDS/csvs"
out_dir <- "/Users/jasonkru/Documents/outputs/ABCDS/SILA"

#import centiloid and age data
centiloid <- read.csv(glue("{in_dir}/centiloids.csv"))
age <- read.csv(glue("{in_dir}/age_at_event.csv"))

#make fsid column in age dataframe
age$fsid <- glue("{as.character(age$subject_label)}_e{as.character(age$event_sequence)}")

#select fsid, age_at_visit, subject_label and amy_latency_in_days from age dataframe
age <- age %>%
  dplyr::select(fsid, age_at_visit, subject_label, amy_latency_in_days, mri_latency_in_days)

#rename ID column to fsid
colnames(centiloid)[colnames(centiloid) == "ID"] <- "fsid"

#select fsid and centiloid_value from centiloid dataframe
centiloid <- centiloid %>%
  dplyr::select(fsid, Centiloids)

#combine dataframes based on subject_id/event code
data <- inner_join(age, centiloid, by="fsid")


#amy_latency_in_days == NA and fsid ends with _e1 set to 0
data$amy_latency_in_days[is.na(data$amy_latency_in_days) & grepl("_e1", data$fsid)] <- 0

#if amy_latency_in_days == NA fill with value from mri_latency_in_days
data$amy_latency_in_days[is.na(data$amy_latency_in_days)] <- data$mri_latency_in_days[is.na(data$amy_latency_in_days)]

#drop mri_latency_in_days column
data <- data %>%
  dplyr::select(-mri_latency_in_days)

write.csv(data, file = glue("{out_dir}/ABC_DS_sila_tall.csv"))