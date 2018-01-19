
### sHydrology packages

library(shiny)
library(shinyjs)
library(markdown)
library(jsonlite)
library(plyr)
library(lmomco)
library(ggplot2)
library(date)
library(zoo)
library(dygraphs)
library(xts)
library(scales)


source("pkg/HYDAT_query.R")
source("pkg/hydrograph_separation.R")
source("pkg/hydrograph_parsing.R")
source("pkg/hydrograph_stats_plots.R")
source("pkg/hydrograph_info.R")
source("pkg/hydrograph_frequency_analysis.R")



#################################################################################################
####################### from: https://github.com/daattali/advanced-shiny ########################

### capture mouse-up events in shiny
jscode.mup <- '
  $(function() {
    $(document).mouseup(function(e) {
      Shiny.onInputChange("mouseup", ["up", Math.random()]);
    });
  });
'

### open page loading message
appLoad <- "
  #loading-content {
    position: absolute;
    background: #000000;
    opacity: 0.9;
    z-index: 100;
    left: 0;
    right: 0;
    height: 100%;
    text-align: center;
    color: #FFFFFF;
  }
"