## ===================================================================== ##
## Script: extract_dataset.r
##
## Purpose: extracts the application level data for households
##  applying for social housing.
## 
## Author: Vinay Benny - SIU
## Date: 31/07/2016
## 
## ===================================================================== ##


print("Running extract_dataset.R");

# initialise connection 
 connstr <- set_conn_string()

# Read the sql query file and create query
app_data_query <- "../sql/source_data_query.sql"


# Run Housing applications data query on the database and fetch dat
applications_data <- as_tibble(read_sql_table(query_object = app_data_query, connection_string = connstr))



print("Completed extract_dataset.R")

