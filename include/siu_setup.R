###########################
###     SIU set up      ###
###########################

###Load libraries (that are required for this script)
library(RODBC)

###Create connection string function - courtesy: Christopher Ball
set_conn_string <- function(db = "IDI_Sandpit"){
  tmp <- "DRIVER=ODBC Driver 11 for SQL Server; " 
  tmp <- paste0(tmp, "Trusted_Connection=Yes; ")
  tmp <- paste0(tmp, paste0("DATABASE=", db, " ; "))
  tmp <- paste0(tmp, "SERVER=WPRDSQL36.stats.govt.nz, 49530")
  
  return(tmp)
}

###Create readquery function (for reading in and parsing SQL queries)
readquery <- function(filename){
  paste(readLines(filename), collapse="\n")
}

###Create function for reading in table from SQL (using the connection string and SQL query script) 
read_sql_table <- function(query_object = data_query, connection_string = connstr){
  ###Connect to database
  conn <- odbcDriverConnect(connection = connection_string)
  
  ###Read table and assign to object
  tmp <- sqlQuery(channel = conn, query = readquery(query_object))
  
  ###Close connections
  odbcClose(conn)
  
  return(tmp)
}


###############################################
####
#### Title: ggplot2 theme functions for the SIU
#### Author: Conrad MacCormick
#### Date:10 November 2016
####
#### Directions: Load ggplot2 and compile both 
#### functions. See testing code at the botom
#### for an example.
#### 
###############################################

# library(ggplot2)

####theme_siu####
theme_siu <- function(base_size = 12, base_family = "") 
{
  half_line <- base_size/2
  theme_grey(base_size = base_size, base_family = base_family) %+replace% 
    theme(
      axis.text = element_text(colour = "#315259", family = 'Century Gothic', size = rel(0.8)),
      axis.title = element_text(colour = "#588D97", family = 'Century Gothic'),
      axis.ticks = element_line(colour = "black"), 
      legend.key = element_rect(colour = NA),
      legend.title = element_blank(),
      legend.position = "bottom",
      plot.title = element_text(color = "#588D97", family = 'Century Gothic', size = 15, 
                                margin = margin(b = half_line * 1.2)),
      plot.margin = margin(half_line, half_line, half_line, half_line)
    )
}

#Put in ggplot2 environment to inherit ggplot2 functionality
environment(theme_siu) <- asNamespace("ggplot2")

###############################################################################################

####scale_colour_siu#####
scale_colour_siu <- function(..., values) {
  manual_scale("colour", values = c("#588D97", "#F47C20", "#315259", "#414258", "#262638"), ...)
}

#Put in ggplot2 environment to inherit ggplot2 functionality
environment(scale_colour_siu) <- asNamespace("ggplot2")

###############################################################################################

####scale_fill_siu#####
scale_fill_siu <- function(..., values) {
  manual_scale("fill", values = c("#588D97", "#F47C20", "#315259", "#414258", "#262638"), ...)
}

#Put in ggplot2 environment to inherit ggplot2 functionality
environment(scale_fill_siu) <- asNamespace("ggplot2")

###############################################################################################


siuDarkBlue <- rgb(35, 35, 56, maxColorValue = 255)
siuDarkBlue2 <- rgb(65, 66, 88, maxColorValue = 255)
siuGreen <- rgb(8, 141, 151, maxColorValue = 255)
siuGreen2 <- rgb(49, 82, 89, maxColorValue = 255)
siuOrange <- rgb(244, 124, 32, maxColorValue = 255)
siuGrey <- rgb(189, 186, 192, maxColorValue = 255)
siuGrey2 <- rgb(209, 211, 212, maxColorValue = 255)

