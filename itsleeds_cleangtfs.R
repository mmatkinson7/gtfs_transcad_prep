#install.packages("remotes") # If you do not already have the remotes package
#remotes::install_github("ITSleeds/UK2GTFS")
library(UK2GTFS)
library(dplyr)

#https://github.com/ITSLeeds/UK2GTFS/tree/0ecf4243a211aaa0520c948716612592867e03f5
setwd("J:/My Drive/gtfs_to_transcad")

fred <- gtfs_read("J:\\My Drive\\gtfs_to_transcad\\GTFS_Recap_-_Fall_2018.zip")

gtfs_validate_internal(fred)

fred2 <- gtfs_clean(fred)


gtfs_write(fred2, folder = getwd(),
           name = "mbta2018_its_clean")


write.table(fred2$stop_times, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/stop_times.txt",na="",sep=",",row.names = FALSE)
write.table(fred2$stops, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/stops.txt",na="",sep=",",row.names = FALSE)
write.table(fred2$agency, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/agency.txt",na="",sep=",",row.names = FALSE)
write.table(fred2$routes, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/routes.txt",na="",sep=",",row.names = FALSE)
write.table(fred2$trips, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/trips.txt",na="",sep=",",row.names = FALSE)
write.table(fred2$calendar, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/calendar.txt",na="",sep=",",row.names = FALSE)
write.table(fred2$calendar_dates, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/calendar_dates.txt",na="",sep=",",row.names = FALSE)
write.table(fred2$shapes, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/shapes.txt",na="",sep=",",row.names = FALSE)
write.table(fred2$transfers, file="J:/My Drive/gtfs_to_transcad/mbta2018_its_clean/transfers.txt",na="",sep=",",row.names = FALSE)


