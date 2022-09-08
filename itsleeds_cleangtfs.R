#install.packages("remotes") # If you do not already have the remotes package
#remotes::install_github("ITSleeds/UK2GTFS")
library(UK2GTFS)
library(dplyr)
library(lubridate)
library(readr)

#https://github.com/ITSLeeds/UK2GTFS/tree/0ecf4243a211aaa0520c948716612592867e03f5
setwd("J:/My Drive/gtfs_to_transcad")


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
  
  if(checkmate::test_file_exists(file.path(tmp_folder,"fare_attributes.txt"))){
    gtfs$fare_attributes <- readr::read_csv(file.path(tmp_folder,"fare_attributes.txt"),
                                            lazy = FALSE)
  } else {
    message_log <- c(message_log, "fare_attributes.txt")
  }
  
  if(checkmate::test_file_exists(file.path(tmp_folder,"fare_rules.txt"))){
    gtfs$fare_rules <- readr::read_csv(file.path(tmp_folder,"fare_rules.txt"),
                                       lazy = FALSE)
  } else {
    message_log <- c(message_log, "fare_rules.txt")
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
    gtfs$transfers <- readr::read_csv(file.path(tmp_folder,"levels.txt"),
                                      lazy = FALSE)
  } else {
    message_log <- c(message_log, "Unable to find conditionally required file: levels.txt")
  }
  
  unlink(tmp_folder, recursive = TRUE)
  
  
  if(length(message_log) > 0){
    message(paste(message_log, collapse = " "))
  }
  
  return(gtfs)
}


mbta18 <- gtfs_read("J:\\My Drive\\gtfs_to_transcad\\GTFS_Recap_-_Fall_2018.zip")
problems(mbta18$stops)

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
  
  # Replace dates and times with GTFS approved format (the GTFS importer transforms the data formats)
  gtfs$stop_times <- transform(gtfs$stop_times, 
                                arrival_time = hms::as_hms(period_to_seconds(arrival_time)),
                                departure_time = hms::as_hms(period_to_seconds(departure_time))
  )
  
  gtfs$calendar <- transform(gtfs$calendar, 
                              end_date = as.numeric(strftime(end_date,'%Y%m%d')),
                              start_date = as.numeric(strftime(start_date,'%Y%m%d'))
  )
  gtfs$calendar_dates <- transform(gtfs$calendar_dates, 
                                    date = as.numeric(strftime(date,'%Y%m%d'))
  )
  
  # filter out problematic stops from multiple files
  gtfs$stops$parent_station <-unlist(lapply(gtfs$stops$parent_station, 
                                             function(x) ifelse(x %in% gtfs$stops$stop_id, x, NA)))
  gtfs$transfers$from_stop_id <-unlist(lapply(gtfs$transfers$from_stop_id, 
                                               function(x) ifelse(x %in% gtfs$stops$stop_id, x, NA)))
  gtfs$transfers$to_stop_id <-unlist(lapply(gtfs$transfers$to_stop_id, 
                                             function(x) ifelse(x %in% gtfs$stops$stop_id, x, NA)))
  gtfs$transfers <- gtfs$transfers %>% filter(!is.na(to_stop_id) & !is.na(from_stop_id))
  
  # if duplicate distance in same trip, remove
  gtfs$stop_times <- gtfs$stop_times %>%
    group_by(trip_id, shape_dist_traveled) %>%
    filter(stop_sequence == min(stop_sequence)) %>%
    distinct
  
  return(gtfs)
}



mbta18_clean <- gtfs_clean2(mbta18)



write.table(mbta18_clean$stop_times, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/stop_times.txt",na="",sep=",",row.names = FALSE)
write.table(mbta18_clean$stops, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/stops.txt",na="",sep=",",row.names = FALSE)
write.table(mbta18_clean$agency, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/agency.txt",na="",sep=",",row.names = FALSE)
write.table(mbta18_clean$routes, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/routes.txt",na="",sep=",",row.names = FALSE)
write.table(mbta18_clean$trips, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/trips.txt",na="",sep=",",row.names = FALSE)
write.table(mbta18_clean$calendar, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/calendar.txt",na="",sep=",",row.names = FALSE)
write.table(mbta18_clean$calendar_dates, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/calendar_dates.txt",na="",sep=",",row.names = FALSE)
write.table(mbta18_clean$shapes, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/shapes.txt",na="",sep=",",row.names = FALSE)
write.table(mbta18_clean$transfers, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/transfers.txt",na="",sep=",",row.names = FALSE)
write.table(mbta18_clean$levels, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/levels.txt",na="",sep=",",row.names = FALSE)

