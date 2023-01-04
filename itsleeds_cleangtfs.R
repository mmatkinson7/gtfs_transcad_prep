
##### README #####
# This file is intended to replicate part of the ITS Leeds UK2GTFS package for 
# cleaning GTFS zip files in Massachusetts in support of TDM23.
# Functions are very similar, just lightly edited to meet more of our needs
# regarding MBTA RECAP GTFS files.
# 
# Resident Metaphysician: Margaret Atkinson (matkinson@ctps.org)
#
# Note: This file is used before the ipynb file that consolidates the routes
#       and trips in the GTFS files prior to importing the GTFS into TransCAD.
#       Run this first! (then python, then transcad tool)

##### LIBRARIES #####

#install.packages("remotes") # If you do not already have the remotes package
#remotes::install_github("ITSleeds/UK2GTFS")
library(UK2GTFS)
library(dplyr)
library(lubridate)
library(readr)

#https://github.com/ITSLeeds/UK2GTFS/tree/0ecf4243a211aaa0520c948716612592867e03f5

##### INPUTS #####

setwd("J:/Shared drives/TMD_TSA/Model/networks/Transit/gtfs/bnrd/gtfs_zip")
gtfs_zip = "/gtfs_bnrd_100422.zip"

out_folder <- "C:\\Users\\matkinson.AD\\Downloads\\bnrd"
dates <- c() #MBTA 2019: dates <- c("20181024")

##### FUNCTIONS #####

gtfs_read2 <- function(path){
  checkmate::assert_file_exists(path)
  
  tmp_folder <- file.path(tempdir(),"gtfsread")
  dir.create(tmp_folder)
  utils::unzip(path, exdir = tmp_folder)
  
  files <- list.files(tmp_folder, pattern = ".txt")
  
  gtfs <- list()
  message_log <- c("Unable to find optional files: ")
  
  if(checkmate::test_file_exists(file.path(tmp_folder,"agency.txt"))){
    gtfs$agency <- readr::read_csv(file.path(tmp_folder,"agency.txt"), lazy = FALSE)
  } else {
    warning("Unable to find required file: agency.txt")
  }
  
  if(checkmate::test_file_exists(file.path(tmp_folder,"stops.txt"))){
    gtfs$stops <- readr::read_csv(file.path(tmp_folder,"stops.txt"), lazy = FALSE)
  } else {
    warning("Unable to find required file: stops.txt")
  }
  
  if(checkmate::test_file_exists(file.path(tmp_folder,"routes.txt"))){
    gtfs$routes <- readr::read_csv(file.path(tmp_folder,"routes.txt"),
                                   col_types = readr::cols(route_id = readr::col_character(),
                                                           route_short_name = readr::col_character(),
                                                           route_long_name = readr::col_character()),
                                   lazy = FALSE)
  } else {
    warning("Unable to find required file: routes.txt")
  }
  
  if(checkmate::test_file_exists(file.path(tmp_folder,"trips.txt"))){
    gtfs$trips <- readr::read_csv(file.path(tmp_folder,"trips.txt"),
                                  col_types = readr::cols(trip_id = readr::col_character(),
                                                          route_id = readr::col_character()),
                                  lazy = FALSE)
  } else {
    warning("Unable to find required file: trips.txt")
  }
  
  if(checkmate::test_file_exists(file.path(tmp_folder,"stop_times.txt"))){
    gtfs$stop_times <- readr::read_csv(file.path(tmp_folder,"stop_times.txt"),
                                       col_types = readr::cols(trip_id = readr::col_character(),
                                                               departure_time = readr::col_character(),
                                                               arrival_time = readr::col_character()),
                                       lazy = FALSE)
    
  } else {
    warning("Unable to find required file: stop_times.txt")
  }
  
  if(checkmate::test_file_exists(file.path(tmp_folder,"calendar.txt"))){
    gtfs$calendar <- readr::read_csv(file.path(tmp_folder,"calendar.txt"),
                                     col_types = readr::cols(start_date = readr::col_character(),
                                                             end_date = readr::col_character()),
                                     lazy = FALSE)
    
  } else {
    message("Unable to find conditionally required file: calendar.txt")
  }
  
  if(checkmate::test_file_exists(file.path(tmp_folder,"calendar_dates.txt"))){
    gtfs$calendar_dates <- readr::read_csv(file.path(tmp_folder,"calendar_dates.txt"),
                                           col_types = readr::cols(date = readr::col_character()),
                                           lazy = FALSE)
  } else {
    message("Unable to find conditionally required file: calendar_dates.txt")
  }
  
  if(checkmate::test_file_exists(file.path(tmp_folder,"shapes.txt"))){
    gtfs$shapes <- readr::read_csv(file.path(tmp_folder,"shapes.txt"),
                                   lazy = FALSE)
  } else {
    message_log <- c(message_log, "shapes.txt")
  }
  
  if(checkmate::test_file_exists(file.path(tmp_folder,"transfers.txt"))){
    gtfs$transfers <- readr::read_csv(file.path(tmp_folder,"transfers.txt"),
                                      lazy = FALSE)
  } else {
    message_log <- c(message_log, "transfers.txt")
  }
  
  if(checkmate::test_file_exists(file.path(tmp_folder,"levels.txt"))){
    gtfs$levels <- readr::read_csv(file.path(tmp_folder,"levels.txt"),
                                      lazy = FALSE)
  } else {
    message_log <- c(message_log, "levels.txt")
  }
  
  if(checkmate::test_file_exists(file.path(tmp_folder,"facilities.txt"))){
    gtfs$facilities <- readr::read_csv(file.path(tmp_folder,"facilities.txt"),
                                   lazy = FALSE)
  } else {
    message_log <- c(message_log, "facilities.txt")
  }
  if(checkmate::test_file_exists(file.path(tmp_folder,"facilities_properties.txt"))){
    gtfs$facilities_properties <- readr::read_csv(file.path(tmp_folder,"facilities_properties.txt"),
                                       lazy = FALSE)
  } else {
    message_log <- c(message_log, "facilities_properties.txt")
  }
  if(checkmate::test_file_exists(file.path(tmp_folder,"lines.txt"))){
    gtfs$lines <- readr::read_csv(file.path(tmp_folder,"lines.txt"),
                                                  lazy = FALSE)
  } else {
    message_log <- c(message_log, "lines.txt")
  }
  if(checkmate::test_file_exists(file.path(tmp_folder,"multi_route_trips.txt"))){
    gtfs$multi_route_trips <- readr::read_csv(file.path(tmp_folder,"multi_route_trips.txt"),
                                  lazy = FALSE)
  } else {
    message_log <- c(message_log, "multi_route_trips.txt")
  }
  if(checkmate::test_file_exists(file.path(tmp_folder,"pathways.txt"))){
    gtfs$pathways <- readr::read_csv(file.path(tmp_folder,"pathways.txt"),
                                              lazy = FALSE)
  } else {
    message_log <- c(message_log, "pathways.txt")
  }
  if(checkmate::test_file_exists(file.path(tmp_folder,"route_patterns.txt"))){
    gtfs$route_patterns <- readr::read_csv(file.path(tmp_folder,"route_patterns.txt"),
                                     lazy = FALSE)
  } else {
    message_log <- c(message_log, "route_patterns.txt")
  }
  if(checkmate::test_file_exists(file.path(tmp_folder,"calendar_attributes.txt"))){
    gtfs$calendar_attributes <- readr::read_csv(file.path(tmp_folder,"calendar_attributes.txt"),
                                                lazy = FALSE)
  } else {
    message_log <- c(message_log, "calendar_attributes.txt")
  }
  if(checkmate::test_file_exists(file.path(tmp_folder,"directions.txt"))){
    gtfs$directions <- readr::read_csv(file.path(tmp_folder,"directions.txt"),
                                       lazy = FALSE)
  } else {
    message_log <- c(message_log, "directions.txt")
  }
  
  unlink(tmp_folder, recursive = TRUE)
  
  
  if(length(message_log) > 0){
    message(paste(message_log, collapse = " "))
  }

  return(gtfs)
}




gtfs_clean2 <- function(gtfs) {
  # 1 Remove stops with no locations
  gtfs$stop_times <- gtfs$stop_times[gtfs$stop_times$stop_id %in% unique(gtfs$stops$stop_id), ]
  
  # 2 Remove stops that are never used
  gtfs$stops <- gtfs$stops[gtfs$stops$stop_id %in% unique(gtfs$stop_times$stop_id) |
                             gtfs$stops$stop_id %in% unique(gtfs$stops$parent_station),]
  
  # Replace "" agency_id with dummy name
  gtfs$agency$agency_id[gtfs$agency$agency_id == ""] <- "MISSINGAGENCY"
  gtfs$routes$agency_id[gtfs$routes$agency_id == ""] <- "MISSINGAGENCY"
  gtfs$agency$agency_name[gtfs$agency$agency_name == ""] <- "MISSINGAGENCY"
  
  
  # filter out problematic stops from multiple files
  gtfs$stops$parent_station <-unlist(lapply(gtfs$stops$parent_station, 
                                            function(x) ifelse(x %in% gtfs$stops$stop_id, x, NA)))
  for (x in c('transfers','pathways')){
    if (x %in% names(gtfs)) {
      gtfs[[x,exact=TRUE]]['from_stop_id'] <-unlist(lapply(gtfs[[x,exact=TRUE]]['from_stop_id'], 
                                                           function(x) ifelse(x %in% gtfs$stops$stop_id, x, NA)))
      gtfs[[x,exact=TRUE]]['to_stop_id'] <-unlist(lapply(gtfs[[x,exact=TRUE]]['to_stop_id'], 
                                                         function(x) ifelse(x %in% gtfs$stops$stop_id, x, NA)))
      gtfs[[x]] <- gtfs[[x]] %>% filter(!is.na(to_stop_id) & !is.na(from_stop_id))
    }
  }
  
  
  # remove shape_dist_traveled field - inconsistent, incorrect, and causes error. Not needed.
  gtfs$stop_times <- gtfs$stop_times %>% select(-shape_dist_traveled)
  
  
  
  if ('calendar_attributes' %in% names(gtfs)) {
    
    # choose only weekday schedules in all three calendar tables
    gtfs$calendar_attributes <- gtfs$calendar_attributes %>% 
      filter(service_description == "Weekday schedule" &
               service_schedule_name == "Weekday" &
               service_schedule_type == "Weekday")
    
    gtfs$calendar <- gtfs$calendar %>% filter(service_id %in% gtfs$calendar_attributes$service_id)
  }
  
  
  if ('calendar_dates' %in% names(gtfs)) {
    gtfs$calendar_dates <- gtfs$calendar_dates %>% filter(service_id %in% gtfs$calendar$service_id)
    
    if (length(dates) > 0){
      # if want to filter out dates too: 
      gtfs$calendar_dates <- gtfs$calendar_dates %>% filter(date %in% dates)
      
      drops <- gtfs$calendar_dates %>% 
        filter(exception_type == 2) %>% 
        select(service_id)
      
      if (length(dates) == 1){
        gtfs$calendar <- gtfs$calendar %>% 
          filter(!((start_date > dates | end_date < dates) & (grepl("BUS",service_id)))) %>%
          filter(!(service_id %in% drops))
        
        gtfs$calendar$start_date <- dates
        gtfs$calendar$end_date <- dates
      }
      
    }
  }
  
  #filter out trips for cleanliness
  gtfs$trips <- gtfs$trips %>% filter(service_id %in% gtfs$calendar$service_id)
  gtfs$stop_times <- gtfs$stop_times %>% filter(trip_id %in% gtfs$trips$trip_id)
  return(gtfs)
}



write_gtfs <- function(gtfs) {
  # write out mandatory files
  mandatory_files = c('routes','trips','stops','stop_times','calendar','agency')
  
  for (x in mandatory_files) {
    write.table(gtfs[[x]], file=paste0(out_folder,"\\",x,".txt"),na="",sep=",",row.names = FALSE)
  }
  
  # write out non-mandatory files (optional but in mbta)
  optional_files = c('calendar_dates','shapes','transfers','levels','facilities_properties','lines',
                     'multi_route_trips','pathways','route_patterns','facilities','directions',
                     'calendar attributes')
  for (x in optional_files){
    if (x %in% names(gtfs)){
      write.table(gtfs[[x]], file=paste0(out_folder,"\\",x,".txt"),na="",sep=",",row.names = FALSE)
    }
  }
}



##### RUN #####

redGTFS <- gtfs_read2(paste0(getwd(),gtfs_zip))
problems(redGTFS$stops)

cleanGTFS <- gtfs_clean2(redGTFS)

write_gtfs(cleanGTFS)



