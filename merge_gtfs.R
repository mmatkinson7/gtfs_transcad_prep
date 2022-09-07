# Merge GTFS from multiple Agencies

library(gtfstools)
library(dplyr)
library(tidyverse)


#https://cloud.r-project.org/web/packages/gtfstools/gtfstools.pdf

setwd("C:/Users/matkinson.AD/Downloads/gtfs_0824222")

all_gtfs <- sapply(list.files(),read_gtfs)

merged_gtfs <- merge_gtfs(all_gtfs)

vtab <- validate_gtfs(merged_gtfs) # deprecated

write_gtfs(merged_gtfs, "all_gtfs.zip")
