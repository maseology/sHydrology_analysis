

##############################################################
### Compute baseflow from 14 hydrograph separation methods
##############################################################
baseflow_range <- function(hyd, cArea_km2=NULL, k=NULL, p=NULL, updateProgress=NULL){
  Q <- hyd[,2]
  
  Qcoll <- data.frame(Date=hyd[,1],Flow=Q,Flag=hyd[,3],BF.min=rep(NA,nrow(hyd)),BF.med=rep(NA,nrow(hyd)),BF.max=rep(NA,nrow(hyd)))
  if (is.null(p)){p <- list(LHa=0.925, LHp=3, BFIx=0.8, JHC=0.3)} # defaults
  
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