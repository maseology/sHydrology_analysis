

# modified from https://stackoverflow.com/questions/8758646/piecewise-regression-with-r-plotting-the-segments


piecewise.regression.line <- function(dati) {
  out.lm <- lm(y ~ x, data = dati)
  o <- segmented(out.lm, seg.Z = ~x, control = seg.control(display = FALSE))
  dato = data.frame(x = out.lm$model$x, y = broken.line(o)$fit)
  
  dfo <- data.frame(d=as.Date(dato$x),v=dato$y)
  brkrow <- dfo[dfo$d == as.character(as.Date(o$psi[[2]])),]
  brko <- list(x=brkrow$d,y=brkrow$v)
  return( list( df=dfo, brk=brko) )
}