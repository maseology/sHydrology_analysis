
########################################################
# monthly bar chart
########################################################

flow_monthly_bar_build <- function(hyd,carea=NULL,DTrng=NULL){
  hyd$mnt <- format(hyd$Date, "%b")
  hyd$mnt <- as.factor(hyd$mnt)
  if(!is.null(carea)) hyd$Flow <- hyd$Flow * 2592/carea # mm/30 days
  
  if(is.null(DTrng)){
    p <- ggplot(hyd, aes(x = reorder(mnt, montho(Date)), y = Flow)) +
      stat_summary(fun="mean", geom="bar")
  }else{
    hyd2 <- subset(hyd, Date>=min(DTrng) & Date<=max(DTrng))
    p <- ggplot(hyd2, aes(x = reorder(mnt, montho(Date)), y = Flow)) +
      stat_summary(fun="mean", geom="bar")    
  }
  
  return(ggplot_build(p)$data[[1]])
}

flow_monthly_bar <- function(pg1,pg2=NULL){
  if(is.null(pg2)){
    p <- ggplot() +
      theme_bw() +
      geom_bar(data=pg1, aes(x,y), stat='identity')     
  }else{
    pg1$name <- "complete data range"
    pg2$name <- "selected data range"
    d <- rbind(pg1, pg2)
    p <- ggplot(d, aes(x, y, fill = name)) +
      theme_bw() + theme(legend.position=c(0.97,0.97), legend.justification=c(1,1), legend.title=element_blank()) +
      geom_bar(position = "dodge", stat='identity') +
      scale_fill_manual(values=c("selected data range"="#ffa552", "complete data range"="#001a7f"))
  }
  
  return(
    p + scale_x_discrete(limits=c('Oct','Nov','Dec','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep'), expand=c(0.01,0.01)) +
      labs(y = "Discharge (mm/month)", x=NULL, title='Monthly Discharge')
  )
}

flow_monthly_bar2 <- function(hyd,carea,DTrng=NULL){
  if(is.null(DTrng)){
    flow_monthly_bar(flow_monthly_bar_build(hyd,carea))
  }else{
    flow_monthly_bar(flow_monthly_bar_build(hyd,carea),flow_monthly_bar_build(hyd,carea,DTrng))
  }
}