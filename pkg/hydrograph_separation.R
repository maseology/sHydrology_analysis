##########################################################
############## Hydrograph separation ##################### 
##########################################################
# By M. Marchildon
#
# Dec 15, 2017
##########################################################




########################################################
# recession days
# time (in days) after peak discharge from which quick flow ceases and total flow is entirely slow flow
# ref: Linsley, R.K., M.A. Kohler, J.L.H. Paulhus, 1975. Hydrology for Engineers 2nd ed. McGraw-Hill. 482pp.
########################################################
Ndays <- function(cArea_km2){
  if (is.null(cArea_km2)){return(1)}else if(cArea_km2==0){return(1)}else{return(0.827*cArea_km2^0.2)}
}


########################################################
# Hydrograph separation
########################################################
baseflow_range <- function(hyd, cArea_km2=NULL, k=NULL, p=NULL, updateProgress=NULL){
  Q <- hyd[,2]
  
  Qcoll <- data.frame(Date=hyd[,1],Flow=Q,Flag=hyd[,3],BF.min=rep(NA,nrow(hyd)),BF.med=rep(NA,nrow(hyd)),BF.max=rep(NA,nrow(hyd)))
  if (is.null(p)){p <- list(LHa=0.925, LHp=3, BFIx=0.8, JHC=0.3)}
  
  if (is.function(updateProgress)){updateProgress(detail = 'computing Lyne-Hollick..')}
  Qcoll$BF.LH <- digital_filter(Q,p$LHa,'lyne-hollick',nPasses=p$LHp)
  if (is.function(updateProgress)){updateProgress(detail = 'computing Chapman-Maxwell..')}
  Qcoll$BF.CM <- digital_filter(Q,k,'chapman-maxwell')
  if (is.function(updateProgress)){updateProgress(detail = 'computing Boughton-Eckhardt..')}
  Qcoll$BF.BE <- digital_filter(Q,k,'boughton-eckhardt',param=p$BFIx)
  if (is.function(updateProgress)){updateProgress(detail = 'computing Jakeman-Hornberger..')}
  Qcoll$BF.JH <- digital_filter(Q,k,'jakeman-hornberger',param=p$JHC)
  if (is.function(updateProgress)){updateProgress(detail = 'computing Clarifica..')}
  Qcoll$BF.Cl <- Clarifica(Q)
  if (is.function(updateProgress)){updateProgress(detail = 'computing UKIH..')}
  Qcoll$BF.UKn <- UKIH(Q,'sweepingmin')
  Qcoll$BF.UKm <- UKIH(Q,'sweepingmedian')
  Qcoll$BF.UKx <- UKIH(Q,'sweepingmax')
  if (is.function(updateProgress)){updateProgress(detail = 'computing HYSEP..')}
  Qcoll$BF.HYSEP.FI <- HYSEP(Q,'FixedInterval',cArea_km2)
  Qcoll$BF.HYSEP.SI <- HYSEP(Q,'SlidingInterval',cArea_km2)
  Qcoll$BF.HYSEP.LM <- HYSEP(Q,'LocalMinimum',cArea_km2)
  if (is.function(updateProgress)){updateProgress(detail = 'computing PART..')}
  Qcoll$BF.PART1 <- PART(Q,cArea_km2,1)
  Qcoll$BF.PART2 <- PART(Q,cArea_km2,2)
  Qcoll$BF.PART3 <- PART(Q,cArea_km2,3)
  
  if (is.function(updateProgress)){updateProgress(detail = 'computing statistics..')}
  Qcoll[,7:20] <- apply(Qcoll[,7:20], 2, function(x) round(x,3))
  
  # summarize
  Qcoll$BF.min <- apply(Qcoll[,7:20], 1, function(x) if(all(is.na(x))){NA}else{min(x, na.rm = TRUE)})
  Qcoll$BF.med <- apply(Qcoll[,7:20], 1, function(x) if(all(is.na(x))){NA}else{median(x, na.rm = TRUE)})
  Qcoll$BF.max <- apply(Qcoll[,7:20], 1, function(x) if(all(is.na(x))){NA}else{max(x, na.rm = TRUE)})
  
  return(Qcoll)
}



########################################################
# digital filter methods of automatic baseflow separaion
########################################################
digital_filter <- function(Q, k=NULL, method = "Chapman-Maxwell", nPasses = 1, param=NULL){
  # c("lyne-hollick","chapman","chapman-maxwell","boughton-eckhardt","jakeman-hornberger","tularam-ilahee")
  method <- tolower(method)
  if (is.null(k)){k <- recession_coef(Q)}
  
  if (method=="lyne-hollick"){
    # Lyne, V. and M. Hollick, 1979. Stochastic time-variable rainfall-runoff modelling. Hydrology and Water Resources Symposium, Institution of Engineers Australia, Perth: 89-92.
    #k <- 0.925 # Ranges from 0.9 to 0.95 (Nathan and McMahon, 1990).  
    #nPasses = 3 # Commonly used (Chapman, 1999)
    a <- k
    b <- (1-k)/2
    c <- 1.0*b
  } else
  
  if (method=="chapman"){
    # Chapman, T.G., 1991. Comment on the evaluation of automated techniques for base flow and recession analyses, by R.J. Nathan and T.A. McMahon. Water Resource Research 27(7): 1783-1784
    a <- (3*k-1)/(3-k)
    b <- (1-k)/(3-k)
    c <- 1.0*b
  } else
  
  if (method=="chapman-maxwell"){
    # Chapman, T.G. and A.I. Maxwell, 1996. Baseflow separation - comparison of numerical methods with tracer experiments.Institute Engineers Australia National Conference. Publ. 96/05, 539-545.
    a <- k/(2-k)
    b <- (1-k)/(2-k)
    c <- 0
  } else
    
  if (method=="boughton-eckhardt"){
    # Boughton, W.C., 1993. A hydrograph-based model for estimating the water yield of ungauged catchments. Hydrology and Water Resources Symposium, Institution of Engineers Australia, Newcastle: 317-324.
    # Eckhardt, K., 2005. How to construct recursive digital filters forbaseflow separation. Hydrological Processes 19, 507-515.
    BFImax <- param #0.8
    BC <- (1-k)*BFImax/(1-BFImax)
    a <- k/(1+BC)
    b <- BC/(1+BC)
    c <- 0
    rm(BFImax); rm(BC)
  } else
  
  if (method=="jakeman-hornberger"){
    # IHACRES
    # Jakeman, A.J. and Hornberger G.M., 1993. How much complexity is warranted in a rainfall-runoff model? Water Resources Research 29: 2637-2649.
    JHC <- param #0.3
    JHalpha <- -exp(-1/k) # see: Jakeman and Hornberger (1993), eq.7 - assuming daily timestep.
    a <- k/(1+JHC)
    b <- JHC/(1+JHC)
    c <- JHalpha*b
    rm(JHC); rm(JHalpha)
  } else
    
  if (method=="tularam-ilahee"){
    # Tularam, A.G., Ilahee, M., 2008. Exponential Smoothing Method of Base Flow Separation and its Impact on Continuous Loss Estimates. American Journal of Environmental Sciences 4(2):136-144.
    a <- k
    b <- 1-a
    c <- 0
  }else{
    stop(
      sprintf('Digital filter \'%s\' not recognized', method))
  }
  
  return(digital_filter_compute(Q,a,b,c,nPasses))
}
# Main algorithm
digital_filter_compute <- function(Q,a,b,c,nPasses){
  f2 <- Q
  for(i in 1:nPasses){
    if (i > 1){f2 <- rev(f2)}
    f1 <- stats::filter(f2,c(b,c),method="convolution",sides=1)
    f2 <- stats::filter(na.locf(f1, na.rm = FALSE, fromLast = TRUE),a,method="recursive")
  }
  if (nPasses %% 2 == 0){f2 <- rev(f2)}
  f2 <- ifelse(f2 > Q, Q, f2)
  f2 <- ifelse(f2 < 0, NA, f2)
  return(as.numeric(f2))
}


########################################################
# UKIH/Wallingford (smoothed minima) technique
########################################################
UKIH <- function(Q, method, BlockSizeDays=5){
  # Institute of Hydrology, 1980. Low Flow Studies report. Wallingford, UK.
  # Piggott, A.R., S. Moin, C. Southam, 2005. A revised approach to the UKIH method for the calculation of baseflow. Hydrological Sciences Journal 50(5): 911-920.
  # method <- c("SweepingMin","SweepingMax","SweepingMean","SweepingMedian","FromFirstPointOfOrigin")
  
  chkP <- 0.9 # UKIH method default = 0.9 See Piggot et al., 2005
  method <- tolower(method)
  N <- BlockSizeDays
  
  col = paste0(rep("b",N),seq(1, N))
  Qout <- data.frame(id=seq(1:length(Q)))
  
  for(k in 1:N){ # calculating for every segmentation as recommended by Piggot et al., 2005
    BF <- rollapply(Q[k:length(Q)], width=N, min, by=N) # Find N-day block min
    BF <- rollapply(BF, 3, function(x) if(!any(is.na(x)) & chkP*x[2]<=min(x[1],x[3])){x[2]}else{NA}, fill=NA) # filter out turning points
    BF <- c(rep(NA,k-1),rep(BF,each=N,len=length(Q)-k+1)) # build complete dataset
    BF[BF!=Q] <- NA
    BF <- na.fill(BF,"extend")
    Qout[,paste(col[k])] <- ifelse(BF > Q, Q, BF)
  }
  Qout = Qout[,2:(N+1)] # trim first column
  
  if(method=="sweepingmin"){
    return(apply(Qout, 1, min)) #, na.rm = TRUE
  } else
  if(method=="sweepingmax"){
    return(apply(Qout, 1, max))
  } else
  if(method=="sweepingmean"){
    return(apply(Qout, 1, mean))
  } else
  if(method=="sweepingmedian"){
    return(apply(Qout, 1, median))
  } else
  if(method=="fromfirstpointoforigin"){
    return(Qout[,1])
  } else
  if(method=="all"){
    return(Qout)
  }else{
    stop(
      sprintf('UKIH method \'%s\' not recognized', method))
  }
}


########################################################
# HYSEP technique
########################################################
HYSEP <- function(Q, method, cArea_km2=NULL){
  # Sloto, R.A. and M.Y. Crouse, 1996. HYSEP: A Computer Program for Streamflow Hydrograph Separation and Analysis U.S. Geological Survey Water-Resources Investigations Report 96-4040.
  # method <- c("FixedInterval","SlidingInterval","LocalMinimum")
  
  if (is.null(cArea_km2)){N<-5}else{N <- max(min(as.integer(round(2*Ndays(cArea_km2),0)),11),3)} # N = 2N* in Sloto and Crouse (1996)
  method <- tolower(method) 
  
  if(method=="fixedinterval"){
    return(na.locf(rollapply(Q, width=N, min, by=N, fill=NA, align='left'), na.rm = FALSE)) 
  } else
  if(method=="slidinginterval"){
    BF <- rollapply(Q, width=N, min, fill="extend")
    return(ifelse(BF > Q, Q, BF))
  } else
  if(method=="localminimum"){
    BF <- rollapply(Q, width=N, min, fill=NA)
    BF[BF!=Q] <- NA
    BF <- na.fill(BF,"extend")
    return(ifelse(BF > Q, Q, BF))
  }else{
    stop(
      sprintf('HYSEP method \'%s\' not recognized', method))
  }
}


########################################################
# PART technique
########################################################
PART <- function(Q, cArea_km2=NULL, anterec=1){
  # Rutledge, A.T., 1998. Computer Programs for Describing the Recession of Ground-Water Discharge and for Estimating Mean Ground-Water Recharge and Discharge from Streamflow Records-Update, Water-Resources Investigation Report 98-4148.
  # designed for daily streamflow, translated from the part.f source code (3-pass antecedent recession requirement seems only to be used when reporting mean/long-term baseflow)
  # LogDeclineThresh = 0.1 ' default value as per the document listed above 
  
  if (is.null(cArea_km2)){N<-3}else{N <- ceiling(Ndays(cArea_km2))}
  N <- N + anterec - 1 # in Rutledge (1998), the 'antecedent requirement' ranged 1 to 3, and is provided in 3 separate BF estimates, never given together
  lgt <- 0.1
  
  BF <- rollapply(Q, width=list(-N:0), function(x) if(!any(is.na(x)) & all(x==cummin(x))){x[N+1]}else{NA}, fill=NA, align='right')
  BF <- rollapply(BF, width=2, function(x) if(!any(is.na(x)) & all(cummin(x)>0) & log10(x[1])-log10(x[2])>lgt){NA}else{x[1]}, fill=NA, align='left')
  BF <- log10(BF)
  BF <- na.fill(BF,"extend")
  BF <- 10^BF
  return(ifelse(BF > Q, Q, BF))
}


########################################################
# Clarifica
########################################################
Clarifica <- function(Q){
  # the Clarifica technique (a.k.a. Graham method); named in (Clarifica, 2002) as a "forward and backward-step averaging approach."
  # ref: Clarifica Inc., 2002. Water Budget in Urbanizing Watersheds: Duffins Creek Watershed. Report prepared for the Toronto and Region Conservation Authority.
  # Clarifica method baseflow, 5-day avg running, 6-day min running
  
  # 6-day running minimum discharge
  BF <- rollapply(Q, width=6, min, by=1, fill=NA, align='right')
  
  # 5-day running average (3 days previous, 1 day ahead)
  BF <- rollapply(BF, width=list(1:-3), mean, by=1, fill=NA, align='right')
  
  return(ifelse(BF > Q, Q, BF))
}



