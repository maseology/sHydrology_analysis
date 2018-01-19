##########################################################
############## HYDAT/SQLite querying ##################### 
##########################################################
# By M. Marchildon
#
# Jan 19, 2018
##########################################################

library(RSQLite)


###########################################################################################
## connect to the HYDAT sqlite3 file
###########################################################################################
dbcnxn <- function(dbFP){
  dbc <- dbConnect(RSQLite::SQLite(), dbname=dbFP)
  # get a list of all tables
  # dbListTables(dbc)  
  return(dbc)
}


###########################################################################################
## collect locations
###########################################################################################
qStaLoc <- function(dbc, prov=NULL){

  # get the STATIONS table as a data.frame
  tblSta <- dbGetQuery(dbc,'select * from STATIONS')
  if (!is.null(prov)){tblSta <- tblSta[tblSta$PROV_TERR_STATE_LOC == prov,]}
  tblSta <- tblSta[!is.na(tblSta$DRAINAGE_AREA_GROSS),]
  tblSta <- tblSta[!is.na(tblSta$LATITUDE),]
  
  # query date ranges
  YRb <- vector('numeric',length=length(tblSta$STATION_NUMBER))
  YRe <- vector('numeric',length=length(tblSta$STATION_NUMBER))
  cnt <- 0
  for (s in tblSta$STATION_NUMBER){
    q <- dbGetQuery(dbc, paste0('select * from DLY_FLOWS where STATION_NUMBER = "',s,'"'))
    cnt <- cnt + 1
    if (nrow(q)==0) {
      # print(paste0('no data for station ',s))
      YRb[cnt] <- NA
      YRe[cnt] <- NA
    } else {
      YRb[cnt] <- min(q$YEAR)
      YRe[cnt] <- max(q$YEAR)      
    }
  }
  tblSta$StartYear <- YRb
  tblSta$EndYear <- YRe
  tblSta$sID <- tblSta$STATION_NUMBER
  tblSta <- tblSta[!is.na(tblSta$StartYear),]
  tblSta <- tblSta[!is.na(tblSta$EndYear),]
  colnames(tblSta)[1] <- "sName"
  colnames(tblSta)[2] <- "sName2"
  return(tblSta)
}


###########################################################################################
## collect location info
###########################################################################################
qStaInfo <- function(dbc,staID){
  qSta <- dbGetQuery(dbc, paste0('select * from STATIONS where STATION_NUMBER = "',staID,'"'))
  qSta$sID = qSta$STATION_NUMBER
  colnames(qSta)[1] <- "sName"
  colnames(qSta)[2] <- "sName2"
  colnames(qSta)[9] <- "drainage_area"
  return(qSta)
}
qStaCarea <- function(dbc,staID){
  qSta <- dbGetQuery(dbc, paste0('select * from STATIONS where STATION_NUMBER = "',staID,'"'))
  return(qSta$DRAINAGE_AREA_GROSS)
}


###########################################################################################
## HYDAT temporal Query
###########################################################################################
qTemporal <- function(dbc,staID){
  qFlow <- dbGetQuery(dbc, paste0('select * from DLY_FLOWS where STATION_NUMBER = "',staID,'"'))
  # qFlow <- dbGetQuery(dbc, 'select * from DLY_FLOWS where STATION_NUMBER = "02HB002"')
  DTb <- as.Date(paste0(as.numeric(qFlow[1,2]),'-',as.numeric(qFlow[1,3]),'-01'))
  DTe <- as.Date(paste0(as.numeric(tail(qFlow[2],1)),'-',as.numeric(tail(qFlow[3],1)),'-01'))
  POR <- as.numeric(DTe-DTb)
  Flow <- vector('numeric', length=POR)
  Flag <- vector('character', length=POR)
  Date <- vector('character', length=POR)
  cnt <- 0
  
  for(i in 1:nrow(qFlow)){
    yr <- qFlow[i,2]
    mo <- as.numeric(qFlow[i,3])
    
    for(d in 1:qFlow[i,5]){
      cnt <- cnt + 1
      Date[cnt] <- paste0(yr,'-',mo,'-',d)
      Flow[cnt] <- qFlow[i,(d-1)*2+12]
      Flag[cnt] <- qFlow[i,(d-1)*2+13]
    }
  }
  
  Date <- as.Date(Date)
  # anyDuplicated(Date)
  Flag[is.na(Flag)] <- ""
  hyd <- data.frame(Date,Flow,Flag)
  hyd <- hyd[!is.na(hyd$Flow),]
  return(hyd[!is.na(hyd$Date),])
}


###########################################################################################
## HYDAT temporal Query (of many stations)
###########################################################################################
qTemporal.many <- function(dbc,stalst){
  stStations <- paste0( 'STATION_NUMBER = "',stalst[1],'"')
  for (i in 2:length(stalst)) {
    stStations <- paste0(stStations, ' OR STATION_NUMBER = "', stalst[i], '"')
  }
  qFlow <- dbGetQuery(dbc, paste0('select * from DLY_FLOWS where ', stStations))
  Station <- vector('character', length=nrow(qFlow))
  Flow <- vector('numeric', length=nrow(qFlow))
  Flag <- vector('character', length=nrow(qFlow))
  Date <- vector('character', length=nrow(qFlow))
  cnt <- 0
  
  for(i in 1:nrow(qFlow)){
    sta <- qFlow[i,1]
    yr <- qFlow[i,2]
    mo <- as.numeric(qFlow[i,3])
    
    for(d in 1:qFlow[i,5]){
      cnt <- cnt + 1
      Date[cnt] <- paste0(yr,'-',mo,'-',d)
      Station[cnt] <- sta
      Flow[cnt] <- qFlow[i,(d-1)*2+12]
      Flag[cnt] <- qFlow[i,(d-1)*2+13]
    }
  }
  
  Date <- as.Date(Date)
  # anyDuplicated(Date)
  Flag[is.na(Flag)] <- ""
  hyd <- data.frame(Station,Date,Flow,Flag)
  hyd <- hyd[!is.na(hyd$Date),]
  hyd <- hyd[!is.na(hyd$Flow),]
  return(hyd)
}