##########################################################
#################### YCDB querying ####################### 
##########################################################
# By M. Marchildon
#
# Mar 23, 2018
##########################################################


###########################################################################################
## API addresses
###########################################################################################
ldbc <- 'https://camcfunctions.azurewebsites.net/api/loc_sw/'
idbc <- 'https://camcfunctions.azurewebsites.net/api/int_sw/'


###########################################################################################
## collect locations
###########################################################################################
qStaLoc <- function(API){
  tblSta <- fromJSON(API)
  # colnames(tblSta)[2] <- "sID"    # INT_ID (IID)
  # colnames(tblSta)[3] <- "sName"  # LOC_NAME (NAM1)
  # colnames(tblSta)[4] <- "sName2" # LOC_NAME_ALT1 (NAM2)
  return(tblSta)
}

###########################################################################################
## collect location info
###########################################################################################
qStaCarea <- function(API,LOC_ID){
  t1 <- qStaLoc(API)
  return(t1[t1$LID==LOC_ID,]$DA)
}
qStaInfo <- function(API,LOC_ID){
  t1 <- qStaLoc(API)
  return(t1[t1$LID==LOC_ID,])
}


###########################################################################################
## HYDAT temporal Query
###########################################################################################
qTemporal <- function(API,INT_ID){
  qFlow <- fromJSON(paste0(API,INT_ID))
  Flow <- as.numeric(qFlow$Flow)
  Flag <- as.character(qFlow$Flag)
  Flag[is.na(Flag)] <- ""
  Flag[Flag == 24] <- "ice_conditions"
  Flag[Flag == 78] <- "estimate"
  Flag[Flag == 47] <- "partial"
  Flag[Flag == 34] <- "dry_conditions"
  Flag[Flag == 113] <- "revised"
  Flag[Flag == 114] <- "realtime_uncorrected"
  
  Date <- zoo::as.Date(qFlow$Date)
  # hyd <- data.frame(Date,Flow,Flag)
  # hyd <- hyd[!is.na(hyd$Date),]
  # hyd <- hyd[!is.na(hyd$Flow),]
  # return(hyd)
  return(data.frame(Date,Flow,Flag))
}

qTemporal_byLOC_ID <- function(lAPI,iAPI,LOC_ID){
  t1 <- qStaLoc(lAPI)
  return(qTemporal(iAPI,t1[t1$LID==LOC_ID,]$IID))
}


###########################################################################################
## load temporal Query as .csv
###########################################################################################
qTemporal_csv <- function(fp) {
  df <- read.csv(fp)
  Flow <- as.numeric(df$Flow)
  Flag <- as.character(df$Flag)
  Flag[is.na(Flag)] <- ""
  Flag[Flag == "B"] <- "ice_conditions"
  Flag[Flag == "E"] <- "estimate"
  Flag[Flag == "A"] <- "partial"
  Flag[Flag == "D"] <- "dry_conditions"
  Flag[Flag == "R"] <- "revised"
  Flag[Flag == "raw"] <- "realtime_uncorrected"
  
  Date <- zoo::as.Date(df$Date)
  return(data.frame(Date,Flow,Flag))
} 