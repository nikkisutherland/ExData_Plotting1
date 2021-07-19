####
#
# plot4.R
#
# Copyright (C) 2021 Nikki Sutherland
#
####
# 
# This script takes data from the Individual household electric power consumption
# Data Set in the UC Irvine Machine Learning Repository:
#
#    https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip
#
# and examines how household energy usage varies over February 1st and 2nd in 2007.
# The script plots 4 different plots:  

#     1. Global Active Power (in kilowatts) over the two days
#     2. Voltage over the two days
#     3. Energy Sub-metering (1, 2, and 3 in watt-hour of active energy) over the two days
#     4. Global Reactive Power over the two days
# 
# Sub_metering_1: energy sub-metering No. 1 (in watt-hour of active energy).
#                 It corresponds to the kitchen, containing mainly a dishwasher,
#                 an oven and a microwave (hot plates are not electric but gas powered).
#
# Sub_metering_2: energy sub-metering No. 2 (in watt-hour of active energy).
#                 It corresponds to the laundry room, containing a washing-machine,
#                 a tumble-drier, a refrigerator and a light.
#
# Sub_metering_3: energy sub-metering No. 3 (in watt-hour of active energy).
#                 It corresponds to an electric water-heater and an air-conditioner.
# 
####


## Load packages
library(data.table) # fread
library(plyr)       # mutate

## Setup data directory
if (!file.exists("./data")) { dir.create("./data") }

## Download the data
zipfile <- tempfile()
download.file("https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip", zipfile)
dateDownloaded <- date()

## Unzip the file
unzip(zipfile, overwrite = TRUE, list = FALSE, junkpaths = TRUE, exdir = "./data",
      unzip = "internal", setTimes = FALSE)

## Only using data from the dates Feb 1, 2007 and Feb 2, 2007 from the semi-colon
## separated household_power_consumption.txt

## The lines we need to read are in consecutive order. Grep for the lines that 
## start with 1/2/2007 or 2/2/2007, as the date is formatted DD/MM/YYYY. This
## returns a vector of matching line numbers. 
lines_to_read <- grep("^[1|2]/2/2007", readLines("./data/household_power_consumption.txt"))
num_lines_read <- length(lines_to_read) # 2880 entries

## We are only starting to read lines at the first Feb 1, 2007 entry, so we skip everything up
## to that point. We are subtracting 1 to account for the header.
num_lines_skip <- lines_to_read[1] - 1

## Get the column names, because we will start reading further down the file and
## the header will be missed.
column_names <- names(fread("./data/household_power_consumption.txt",
                            header = TRUE, sep = ";", nrows = 0))

## Read only the data from Feb 1 and Feb 2
household_data <- fread("./data/household_power_consumption.txt", header = FALSE,
                        sep = ";", na.strings = "?", col.names = column_names,
                        skip = num_lines_skip, nrows = num_lines_read)

## Add a datetime column, which is a combination of the Date and Time columns
household_data <- mutate(household_data,
                         "Date_and_time" = strptime(paste(household_data$Date, household_data$Time),
                                                    format = "%d/%m/%Y %H:%M:%S"))

## Open the PNG device
png(filename = "./figure/plot4.png", width = 480, height = 480, units = "px",
    pointsize = 12, bg = "transparent")

## Create a 2 x 2 grid for the 4 plots
par(mfrow = c(2, 2))

## Add the 4 plots
with(household_data, {
  ## Top left
  ## Plot the Global Active Power every minute, for Feb 1, 2007 and Feb 2, 2007
  plot(Date_and_time, Global_active_power, type = "l",
       xlab = "", ylab = "Global Active Power")
  
  ## Top right
  ## Plot the Voltage every minute, for Feb 1, 2007 and Feb 2, 2007
  plot(Date_and_time, Voltage, type = "l",
       xlab = "datetime", ylab = "Voltage")
  
  ## Bottom left
  ## Plot the Energy sub metering every hour, for Feb 1, 2007 and Feb 2, 2007
  plot(Date_and_time, Sub_metering_1, type = "l",
       xlab = "", ylab = "Energy sub metering")
  
  ## Add the Sub_metering_2 data in red
  lines(Date_and_time, Sub_metering_2, col = "red")
  
  ## Add the Sub_metering_3 data in blue
  lines(Date_and_time, Sub_metering_3, col = "blue")
  
  ## Add the legend for the sub metering
  legend("topright", col = c("black", "red", "blue"), lty=c(1,1,1), bty = "n",
         legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))
  
  ## Bottom right
  ## Plot the Voltage every minute, for Feb 1, 2007 and Feb 2, 2007
  plot(Date_and_time, Global_reactive_power, type = "l",
       xlab = "datetime", ylab = "Global_reactive_power")
  
})


## Close the PNG device
dev.off()

## Delete what we downloaded
unlink(zipfile)
