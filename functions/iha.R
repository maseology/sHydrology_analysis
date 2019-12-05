##################################################
#### Indicators of Hydrologic Alteration (IHA)
#### modified from https://rdrr.io/rforge/IHA/
#### accessed 2019-02-21
#### Richter, B.D., J.V. Baumgertner, J. Powell, D.P. Braun, 1996. A Method for Assessing Hydrologic Alteration within Ecosystems. Conservation Biology 10(4): 1163-1174.
##################################################
# GROUP 1: Magnitude of monthly water conditions
mean.cv <- function(x) {
  mean <- mean(x,na.=TRUE)
  cv <- sd(x,na.=TRUE)/abs(mean)
  c(mean = mean, cv = cv)
}
water.year <- function(x){
  yr <- year(x)
  ifelse(lubridate::month(x) > 9, yr + 1, yr)
}
water.month <- function(x, abbr=FALSE){
  x <- c(4:12, 1:3)[lubridate::month(x)]
  if (abbr) {
    labels <- c("Oct", "Nov", "Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep")
  } else {
    labels <- c("October", "November", "December", "January", "February", "March","April", "May", "June", "July", "August", "September") 
  }
  ordered(x, levels = 1:12, labels = labels)
}
group1 <- function (x, FUN=median, abbr=FALSE) {
  stopifnot(is.zoo(x))
  idx <- index(x)
  yr <- water.year(idx)
  mo <- water.month(idx, abbr)
  res <- tapply(coredata(x), list(mo, yr), FUN)
  # res <- tapply(coredata(x), mo, FUN)
  return(t(res))
}

# GROUP 2: Magnitude and duration of annual extreme weather conditions
runmean.iha <- function(x, year = NULL, mimic.tnc = F){
  window <- c(1, 3, 7, 30, 90)
  vrunmean <- Vectorize(runmean, vectorize.args = 'k')
  if (mimic.tnc){ # should the function perform the calculation like the TNC IHA software (years be split before the running mean is calculated)
    sx <- split(coredata(x), year)
    rollx <- lapply(sx, vrunmean, k = window, alg = 'fast', endrule = 'NA')
    rollx <- do.call('rbind', rollx)
  } else {
    rollx <- vrunmean(coredata(x), k = window, alg = 'fast', endrule = 'NA')
  }
  colnames(rollx) <- sprintf('w%s', window)
  return(rollx)
}
group2Funs <- function(x){
  rng <- as.numeric(apply(x, 2, range, na.rm=T))
  baseindex <- min(x[,3], na.rm = T) / mean(x[,1], na.rm = T)
  zeros <- length(which(x[,1] == 0))
  ans <- c(rng, zeros, baseindex)
  nms <- sprintf(c('%1$s Day Min', '%1$s Day Max'), rep(c(1, 3, 7, 30, 90), each=2))
  names(ans) <- c(nms, 'Zero flow days', 'Base index')
  ans
}
group2 <- function(x, mimic.tnc = T, ...){
  stopifnot(is.zoo(x))
  yr <- water.year(index(x))
  rollx <- runmean.iha(x, year = yr, mimic.tnc = mimic.tnc)
  xd <- cbind(year = yr, as.data.frame(rollx))
  res <- ddply(xd, .(year), function(x) group2Funs(x[,-1]), ...)
  return(res)
}

# GROUP 3: Timing of Annual Extream Water conditions
yday2 <- function(x){ # This function does the same as yday from the lubridate package but, does it like TNC's version of the IHA software where they count days as if every year was leap year; every year has 366 days.
  is.leap.year <- leap_year(x)
  is.janfeb <- month(x) < 3L
  ans <- yday(x)
  ans <- ifelse(!is.janfeb & !is.leap.year, ans + 1, ans)
  ans
}
which.min.zoo <- function(x) {
  index(x)[which.min(coredata(x))]
}
which.max.zoo <- function(x){
  index(x)[which.max(coredata(x))]
}
which.range.zoo <- function(x){
  c(which.min.zoo(x), which.max.zoo(x))
}
group3 <- function (x, mimic.tnc = F){
  ihaRange <- function(x, mimic.tnc){
    if (mimic.tnc){ # should the function perform the calculation like the TNC IHA software
      return(yday2(which.range.zoo(x)))
    } else {
      return(yday(c(which.range.zoo(x))))
    }
  }
  stopifnot(is.zoo(x))
  yr <- water.year(index(x))
  sx <- split(x, yr)
  res <- sapply(sx, ihaRange, mimic.tnc = mimic.tnc)
  dimnames(res)[[1]] <- c("Min", "Max")
  return(t(res))
}

# GROUP 4: Frequency and Duration of High/Low Pulses
pulses <- function(x, q){
  runs <- findInterval(x, q, rightmost.closed = T)
  runs.length <- as.data.frame(unclass(rle(runs)))
  runs.length$values <- as.factor(c("low", "med", "high")[runs.length$values + 1])
  return(runs.length)
}
pulse.numbers <- function (x) {
  summary(x)[c("low", "high")]
}
pulse.location <- function (x, XFUN = median) {
  tapply(x$lengths, x$values, FUN = XFUN)[c("low", "high")]
}
rle.start <- function (x){
  pl <- cumsum(c(1, x$length))
  start <- pl[-length(pl)]
  return(start)
}
group4 <- function(x, thresholds = NULL){
  stopifnot(is.zoo(x))
  if (is.null(thresholds)){
    thresholds <- quantile(coredata(x), probs = c(0.25, 0.75))
  }
  stopifnot(identical(length(thresholds), 2L))
  p <- pulses(coredata(x), thresholds)
  st.date <- index(x)[rle.start(p)]
  st.date.wy <- water.year(st.date)
  numbers <- sapply(split(p$values, st.date.wy), pulse.numbers)
  ldp <- split(as.data.frame(p), st.date.wy)
  lengths <- sapply(ldp, FUN = pulse.location)
  res <- cbind(number = t(numbers), length = t(lengths))
  colnames(res) <- c('Low pulse number', 'High pulse number', 'Low pulse length', 'High pulse length')
  return(res[, c(1,3,2,4), drop = F])
}

# GROUP 5: Rate and frequency of change in conditions
meandiff <- function (x, FUN = median, na.rm = T) {
  d <- diff(x)
  ind <- d > 0
  c(FUN(d[d > 0], na.rm = na.rm), FUN(d[d < 0], na.rm = na.rm), length(monotonic.segments(d)$values) - 1)
}
monotonic.segments <- function (x, diff = T) {
  if (!diff) 
    x <- diff(x)
  f <- rep(1, length(x))
  f[x > 0] <- 2
  f[x < 0] <- 0
  f.runs <- rle(f)
  i <- which(f.runs$values == 1)
  if (identical(i[1], as.integer(1))) {
    f.runs$values[1] <- f.runs$values[2]
    i <- i[-1]
  }
  if (length(i) > 0) 
    f.runs$values[i] <- f.runs$values[i - 1]
  f <- inverse.rle(f.runs)
  f.runs <- rle(f)
  return(f.runs)
}
group5 <- function (x){
  yr <- water.year(index(x))
  sx <- split(as.numeric(x), yr)
  res <- sapply(sx, FUN = meandiff)
  dimnames(res)[[1]] <- c("Rise rate", "Fall rate", "Reversals")
  return(t(res))
}