
#######################
### JavaScript code ###
#######################


### capture mouse-up events in shiny
jscode.mup <- '
  $(function() {
    $(document).mouseup(function(e) {
      Shiny.onInputChange("mouseup", ["up", Math.random()]);
    });
  });'


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
  }"