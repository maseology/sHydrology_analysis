

output$qaqc.cnt <- renderTable({
  if (!is.null(sta$hyd)) group1(read.zoo(sta$hyd[,1:2]),length,TRUE)
},
rownames = TRUE
)

output$qaqc.avg <- renderTable({
  if (!is.null(sta$hyd)) group1(read.zoo(sta$hyd[,1:2]),mean,TRUE)
  },
  rownames = TRUE
)
