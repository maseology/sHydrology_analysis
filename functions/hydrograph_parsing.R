##########################################################
################ Hydrograph parsing ###################### 
##########################################################
# By M. Marchildon
#
# Nov, 2018
##########################################################



########################################################
# Hydrograph parsing
########################################################
parse_hydrograph <- function(hyd, k, abthrs=0.25, hghthrs=0.95){
  ## parameters
  qeff <- hyd$Flow - Clarifica(hyd$Flow)
  qeff[qeff<=0] <- NA
  rlt <- quantile(qeff, abthrs, na.rm = TRUE) # rising limb threshold
  qHigh <- quantile(hyd$Flow, hghthrs, na.rm = TRUE) # "high" discharge threshold
  
  ## Parse hydrograph -- qtyp code:
  # 0: unknown
  # 1: Rising_Limb
  # 2: Falling_Limb
  # 3: Baseflow_Recession
  # 4: Missing
  ##  
  
  # rising limb (1)
  hyd$qtyp <- rollapply(hyd$Flow, 2, function(x) if(any(is.na(x))){4}else{if(x[2]>x[1] && x[2]-x[1]>rlt){1}else{0}},fill=0)
  
  # baseflow recession (3)
  t1 <- rollapply(hyd$Flow, 2, function(x) if(all(x<qHigh) && abs(k*x[1]-x[2]) <= abthrs*x[2]){3}else{0},fill=0)
  hyd <- within(hyd, qtyp <- ifelse(qtyp==0,t1,qtyp))
  
  # falling limb (2)
  t1 <- rollapply(hyd$qtyp, 2, function(x) if(x[1]==1 && x[2]!=1){2}else{NA},fill=NA,align='right') # create falling limb after rising limb
  hyd <- within(hyd, qtyp <- ifelse(!is.na(t1),t1,qtyp))  
  repeat{ # let falling limb proceed through
    t1 <- rollapply(hyd$qtyp, 2, function(x) if(x[1]==2 && x[2]==0){2}else{NA},fill=NA,align='right') 
    if(all(is.na(t1))){break}
    hyd <- within(hyd, qtyp <- ifelse(!is.na(t1),t1,qtyp)) 
  }
  
  # fill-in/replace spurious flags:
  t1 <- rollapply(hyd$qtyp, width=list(-1:2), function(x) if(x[1]==3 && x[2]==1 && x[3]==2 && x[4]==3){3}else{NA},fill=NA) # 3123=3
  hyd <- within(hyd, qtyp <- ifelse(!is.na(t1),t1,qtyp))  
  t1 <- rollapply(hyd$qtyp, width=list(-1:1), function(x) if(x[1]==3 && x[2]==0 && x[3]==1){1}else{NA},fill=NA) # 301=1
  hyd <- within(hyd, qtyp <- ifelse(!is.na(t1),t1,qtyp))  
  t1 <- rollapply(hyd$qtyp, width=list(-1:1), function(x) if(x[1]==1 && x[2]!=1 && x[3]==1){1}else{NA},fill=NA) # 1*1=1
  hyd <- within(hyd, qtyp <- ifelse(!is.na(t1),t1,qtyp))
  t1 <- rollapply(hyd$qtyp, width=list(-1:1), function(x) if(x[1]==3 && x[2]!=3 && x[3]==3){3}else{NA},fill=NA) # 3*3=3
  hyd <- within(hyd, qtyp <- ifelse(!is.na(t1),t1,qtyp))
  t1 <- rollapply(hyd$qtyp, width=list(-1:1), function(x) if(x[1]==2 && x[2]!=2 && x[3]==2){2}else{NA},fill=NA) # 2*2=2
  hyd <- within(hyd, qtyp <- ifelse(!is.na(t1),t1,qtyp))
  t1 <- rollapply(hyd$qtyp, width=list(-1:1), function(x) if(x[1]==0 && x[2]==3 && x[3]==0){0}else{NA},fill=NA) # 030=0
  hyd <- within(hyd, qtyp <- ifelse(!is.na(t1),t1,qtyp))
  
  # infill unknowns with previous
  repeat{ # let falling limb proceed through
    t1 <- rollapply(hyd$qtyp, width=list(-1:1), function(x) if(x[1]!=0 && x[2]==0){x[1]}else{NA},fill=NA) # *0=*
    if(all(is.na(t1))){break}
    hyd <- within(hyd, qtyp <- ifelse(!is.na(t1),t1,qtyp)) 
  }
  
  hyd$qtyp <- as.factor(hyd$qtyp)
  
  return(hyd)
}


########################################################
# Hydrograph event volume (discretize)
########################################################
discretize_hydrograph <- function(hyd,carea,k){
  # ref: Reed Johnson Firth 1975 A Non-Linear Rainfall-Runoff Model, Providing for Variable Lag Time
  # find event beginnings
  nval <- nrow(hyd)
  q.evnt <- rep(0.0,nval)
  q.remain <- hyd$Flow
  e.beg <- rollapply(hyd$qtyp, width=list(-1:1), function(x) if(x[1]!=1 && x[2]==1){TRUE}else{FALSE},fill=FALSE,align='right')
  
  i.next = 1
  repeat{
    s <- 0.0
    i <- i.next
    isv <- i
    repeat{
      if (!is.na(q.remain[i])) s = s + q.remain[i] * 86400.0 # [m?]
      i = i+1
      if (i>nval) break
      if (e.beg[i]) break
    }
    if (i>nval) break
    i.next=i
    
    q.under = q.remain[i-1] * k # [m3/s] termed underlying flow (in Reed etal., 1975): "flow which would have been observed if the rainfall event under consideration had not occurred."
    repeat{
      if (!is.na(q.remain[i])){
        if (q.under>q.remain[i]) q.under = q.remain[i]
        q.remain[i] = q.remain[i] - q.under
      }
      s = s + q.under * 86400.0 # [m?]
      q.under = q.under * k
      i = i+1
      if (q.under < 0.01 | i>nval) break
    }
    q.evnt[isv] <- s / carea / 1000.0 # event total [mm]
  }
  # q.evnt[q.evnt==0] <- NA
  hyd$evnt <- round(q.evnt,1)
  return(hyd)
}
