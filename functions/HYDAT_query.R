##########################################################
############## HYDAT/SQLite querying ##################### 
##########################################################
# By M. Marchildon
#
# Nov, 2018
##########################################################

library(RSQLite)

###########################################################################################
## connect to the HYDAT sqlite3 file (see queries below)
###########################################################################################
dbcnxn <- function(dbFP){
  if(!file.exists(dbFP)){
    print(paste0(" ERROR: ",dbFP," cannot be found"))
  } else {
    dbc <- dbConnect(RSQLite::SQLite(), dbname=dbFP)
    # get a list of all tables
    # dbListTables(dbc)  
    return(dbc)
  }
}


###########################################################################################
## build location table
###########################################################################################
qStaLoc.table <- function(dbc, prov=NULL){
  # get the STATIONS table as a data.frame
  tblSta <- dbGetQuery(dbc,'select * from STATIONS')
  if (!is.null(prov)){tblSta <- tblSta[tblSta$PROV_TERR_STATE_LOC == prov,]}
  tblSta <- tblSta[!is.na(tblSta$DRAINAGE_AREA_GROSS),]
  tblSta <- tblSta[!is.na(tblSta$LATITUDE),]
  
  # query date ranges
  YRb <- vector('numeric',length=length(tblSta$STATION_NUMBER))
  YRe <- vector('numeric',length=length(tblSta$STATION_NUMBER))
  Cnt <- vector('numeric',length=length(tblSta$STATION_NUMBER))
  Qual <- vector('numeric',length=length(tblSta$STATION_NUMBER))
  i <- 0
  print(paste0(" ** ",date()))
  for (s in tblSta$STATION_NUMBER){
    q <- dbGetQuery(dbc, paste0('select * from DLY_FLOWS where STATION_NUMBER = "',s,'"'))
    i <- i + 1
    if (nrow(q)==0) {
      # print(paste0('no data for station ',s))
      YRb[i] <- NA
      YRe[i] <- NA
      Cnt[i] <- 0
      Qual[i] <- NA
    } else {
      YRb[i] <- min(q$YEAR)
      YRe[i] <- max(q$YEAR) 
      Cnt[i] <- 365.24*nrow(q)
      Qual[i] <- (max(q$YEAR)-min(q$YEAR)+1)/nrow(q)
    }
  }
  tblSta$YRb <- YRb # StartYear
  tblSta$YRe <- YRe # EndYear
  tblSta$CNT <- Cnt
  tblSta$LID <- tblSta$STATION_NUMBER
  tblSta$IID <- tblSta$STATION_NUMBER
  tblSta <- tblSta[!is.na(tblSta$YRb),]
  tblSta <- tblSta[!is.na(tblSta$YRe),]
  colnames(tblSta)[1] <- "NAM1"
  colnames(tblSta)[2] <- "NAM2"
  colnames(tblSta)[7] <- "LAT"
  colnames(tblSta)[8] <- "LNG"
  colnames(tblSta)[9] <- "DA"
  
  return(tblSta)
}

qStaLoc <- function(dbc, staID){
  # get the STATIONS table as a data.frame
  l <- dbGetQuery(dbc, paste0('select * from STATIONS where STATION_NUMBER = "',staID,'"'))
  
  info <- vector("list", 11)
  names(info) <- c("LOC_ID","INT_ID","LOC_NAME","LOC_NAME_ALT1","LAT","LNG","SW_DRAINAGE_AREA_KM2","CNT","YRb","YRe","QUAL") #c("LID","IID","NAM1","NAM2","LAT","LNG","DA","CNT","YRb","YRe","QUAL")
 
  q <- dbGetQuery(dbc, paste0('select * from DLY_FLOWS where STATION_NUMBER = "',staID,'"'))
  if (nrow(q)==0) {
    # print(paste0('no data for station ',s))
    info$YRb <- NA
    info$YRe <- NA
    info$Cnt <- 0
    info$Qual <- NA
  } else {
    info$YRb <- min(q$YEAR)
    info$YRe <- max(q$YEAR) 
    info$CNT <- 365.24*nrow(q)
    info$QUAL <- (max(q$YEAR)-min(q$YEAR)+1)/nrow(q)
  }
  info$LOC_ID <- staID
  info$INT_ID <- staID
  info$LOC_NAME <- staID
  info$LOC_NAME_ALT1 <- l$STATION_NAME
  info$LAT <- l$LATITUDE
  info$LNG <- l$LONGITUDE
  info$SW_DRAINAGE_AREA_KM2 <- l$DRAINAGE_AREA_GROSS

  return(info)
} 


###########################################################################################
## collect location info
###########################################################################################
qStaInfo <- function(dbc,staID){
  return(data.frame(qStaLoc(dbc,staID)))
}
qStaCarea <- function(dbc,staID){
  qSta <- dbGetQuery(dbc, paste0('select * from STATIONS where STATION_NUMBER = "',staID,'"'))
  return(qSta$DRAINAGE_AREA_GROSS)
}
qStaAgg <- function(LOC_ID) { LOC_ID }


###########################################################################################
## HYDAT temporal Query
###########################################################################################
qTemporal <- function(dbc,staID){
  qFlow <- dbGetQuery(dbc, paste0('select * from DLY_FLOWS where STATION_NUMBER = "',staID,'"'))
  # qFlow <- dbGetQuery(dbc, 'select * from DLY_FLOWS where STATION_NUMBER = "02HB002"')
  # print(qFlow)
  DTb <- zoo::as.Date(paste0(as.numeric(qFlow[1,2]),'-',as.numeric(qFlow[1,3]),'-01'))
  DTe <- zoo::as.Date(paste0(as.numeric(tail(qFlow[2],1)),'-',as.numeric(tail(qFlow[3],1)),'-01'))
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
  
  Date <- zoo::as.Date(Date)
  # anyDuplicated(Date)
  Flow <- round(Flow,5)
  Flag <- as.character(Flag)
  
  Flag[is.na(Flag)] <- ""
  Flag[Flag == "B"] <- "ice_conditions"
  Flag[Flag == "E"] <- "estimate"
  Flag[Flag == "A"] <- "partial"
  Flag[Flag == "D"] <- "dry_conditions"
  Flag[Flag == "S"] <- "samples_collected_this_day"
  Flag[Flag == "R"] <- "realtime_uncorrected"

  hyd <- data.frame(Date,Flow,Flag)
  hyd <- hyd[!is.na(hyd$Date),]
  hyd <- hyd[!is.na(hyd$Flow),]
  
  return(hyd)
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




###########################################################################################
## Dummies
###########################################################################################
get.supplimental <- function(info=NULL) NULL



###########################################################################################
## Query
###########################################################################################
idbc <- dbcnxn('dat/Hydat.sqlite3')
ldbc <- idbc
