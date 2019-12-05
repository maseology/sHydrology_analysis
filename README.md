# sHydrology Analysis
A Shiny-Leaflet interface to a stream flow database and companion to [sHydrology (map)](https://github.com/maseology/sHydrology).

Currently built to view WSC HYDAT (sqlite3 format) stream flow data [click here](http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/).

Further details can be read in [sHydrologyUM.pdf](/doc/sHydrologyUM.pdf). *(to be updated)*

### Current functionality (version 1.2.4):
 * View entire stream flow timeseries
 * Dynamic hydrograph zooming:
	 * drag-and-click zoom
	 * double-click to full extent
	 * optionally use date picker
 * Perform as suite of hydrograph separation algorithms (14 in total, see below)
	 * display min/max range (green band) and median separated baseflow (dotted line)
 * Perform automatic hydrograph dis-aggregation to isolate rising/falling limbs, and stream flow recession  
 * Perform flow frequency & flow regime analyses
 * Automatic recession coefficient computation
 * E-Flow/flow regime analysis tools
 * View data as a table, and export data as *.csv 

### Screenshot:
![Screenshot](/images/screenshot.png)

## Functionality
### Required R-dependent packages: 
 * shiny
 * shinyjs
 * markdown
 * jsonlite
 * ggplot2
 * dygraphs
 * RSQLite
 * zoo
 * xts
 * plyr
 * date
 * lmomco
 * scales


### Automatic recession coefficient computation:
The recession coefficient (![recession coefficient](/images/eq_k.png); Linsley et.al., 1975) is computed automatically using an iterative procedure whereby the recession curve is positioned to envelope the log-transformed discharge data versus subsequent discharge, on the condition that the former exceeds the latter.

The recession coefficient *k* is the inverse of the slope of the computed recession curve. The resulting fit can be viewed on the *Plots* tab and can be manually inputted from the *Settings* tab.

The recession coefficient is required for many of the following hydrograph analyses, and is a common input parameter to many hydrologic models.

The recession scatter plot is used to visualize the results of the automatic recession coefficient computation. The recession curve can be viewed and adjusted by manually changing the recession coefficient in the *parameters: recession coefficient* tab.

### Hydrograph separation methods (found in *\pkg\hydrograph_separation.R*):
"Baseflow" is separated from the hydrographs using 14 automatic procedures listed below. Standard baseflow model parameters (as documented in the literature) are also listed where applicable. The user may alter these parameters from the *Settings* tab.

From the *Plots* tab, computed baseflow is summarized on a monthly basis in the form of box-whisker plots. The distribution plotted here is built from the median monthly baseflow computed for every month of record using each of the 14 separation methods listed below. Where applicable, the baseflow values have bee normalized by the stream gauge's catchment area thereby providing the values in equivalent mm/month, which can be used as a first-approximation to basin-averaged groundwater recharge.

 1.	**BF.LH:** The Lyne-Hollick digital filter (Lyne and Hollick, 1979), 3-pass sweep with *α=0.925* as discussed in Chapman (1999);
 2.	**BF.CM:** The Chapman-Maxwell digital filter (Chapman and Maxwell, 1996), using automatically computed recession coefficient (*k*);
 3.	**BF.BE:** The Boughton-Eckhardt digital filter (Boughton, 1993; Eckhardt, 2005) with computed *k* and *BFImax=0.8*;
 4.	**BF.JH:** The Jakeman-Hornberger digital filter (Jakeman and Hornberger, 1993) based on their IHACRES model with *C=0.3* and *α=-0.8*;
 5.	**BF.Cl:** The 'Clarifica' method of Clarifica Inc. (2002);
 6.	**BF.UKn:** The UK Institute of Hydrology (or Wallingford) method (Institute of Hydrology, 1980), sweeping minimum of Piggott et.al. (2005);
 7.	**BF.UKx:** The UK Institute of Hydrology/Wallingford method (Institute of Hydrology, 1980), sweeping maximum of Piggott et.al. (2005);
 8.	**BF.UKm:** The UK Institute of Hydrology/Wallingford method (Institute of Hydrology, 1980), sweeping median;
 9.	**BF.HYSEP.FI:** The HYSEP fixed-interval method (Sloto and Crouse, 1996), with known catchment area;
 10.	**BF.HYSEP.SI:** The HYSEP sliding-interval method (Sloto and Crouse, 1996), with known catchment area;
 11.	**BF.HYSEP.LM:** The HYSEP local minima method (Sloto and Crouse, 1996), with known catchment area;
 12.	**BF.PART1:** The PART method (Rutledge, 1998), with known catchment area, pass 1 of 3 antecedent recession requirement;
 13.	**BF.PART2:** The PART method (Rutledge, 1998), with known catchment area, pass 2 of 3 antecedent recession requirement;
 14.	**BF.PART3:** The PART method (Rutledge, 1998), with known catchment area, pass 3 of 3 antecedent recession requirement.


### Hydrograph summary plots:
##### Annual trend
Provides the long-term (calendar-year) annual volumes of total flow and separated baseflow.

##### Daily average hydrograph
After applying a 5-day rolling average to the hydrograph, both total flow and baseflow are averaged on a daily basis, to illustrate the seasonality of the annual hydrograph.

##### Monthly baseflow regime
Computed baseflow is summarized on a monthly basis in the form of box-whisker plots. The distribution plotted here is built from the median monthly baseflow computed for every month of record using each of the 14 separation methods listed below.

Boxplots and Baseflow index (BFI: the ratio of baseflow to total flow) are computed using the 14 hydrograph separation methods listed above. Boxpots follow the method of McGill et.al. (1978): box represents the 25% to 75% quantile, while the centre line represents median (50% quantile). Whiskers represent the observation less than or equal to the box extents ±1.5 * IQR (inter-quartile range).

Monthly BFIs given by the monthly medians of calculated baseflow (from 14 hydrograph separation methods) and are bounded by the 95% confidence interval. 

### Peak flow frequency
Peak flow frequency curves were modified (with gratitude) from [headwateranalytics.com](http://www.headwateranalytics.com/blog/flood-frequency-analysis-in-r) *(accessed December, 2016)*.

The method allows for the use of 5 distributions: Log-Pearson type 3 *(default)*, Weibull, Gumbel, Generalized Extreme Value (GEV), and the three-parameter lognormal models. (The user may change the distribution model in the *Settings* tab.)

90% confidence intervals are then plotted based in the bootstrap technique from 2,500 samples. 

### Low flow frequency
*to do*

### Recession scatter plot
The recession scatter plot is used to visualize the results of the automatic recession coefficient computation. The recession curve can be adjusted by manually changing the recession coefficient in the *Settings* tab.

### Hydrograph parsing

This algorithm is used to parse the hydrograph into three main constituents:

1.	The rising limb (qtyp code 4) – the rapid increase in discharge following a storm/melt event;
2.	The falling limb (qtyp code 1) – the rapid decrease in discharge following the rising limb; and,
3.	Streamflow recession (qtyp code 2) – the gradual decline in discharge as the watershed drains.

Event volumes are calculated using an algorithm that locates the onset of a rising limb and projects streamflow recession as if the event had never occurred. This projected streamflow, termed "underlying flow" by Reed et.al. (1975), is subtracted from the total observed flow to approximate the runoff volume associated with the event as indicated by the hydrograph. The calculation of event volumes, in effect, "discretizes" the continuous hydrograph such that it can be better compared with measured (i.e., rainfall/smowmelt) event volumes.

![from etal (1975)](md/images/Reed1_small.png)


## Instructions

As coded, *sHydrology Analysis* is built to view the Water Survey of Canada (WSC) **HY**drological **DAT**abase (HYDAT) which can be downloaded [here](https://www.ec.gc.ca/rhc-wsc/default.asp?lang=En&n=9018B5EC-1).

Download and extract the SQLite format of the database typically compressed as *'Hydat_sqlite3_YYYYMMDD.zip'*, where *'YYYYMMDD'* is the date of release. Extract the SQLite file *'Hydat.sqlite3'* and place database anywhere on your local machine.

Using [RStudio](https://https://www.rstudio.com/), install the required packages (see above), and insert the path of the database has to be placed on *Line 15*, and the station name on *Line 14* of the main app file: *app.R*. 

Run *app.R* externally such that the app will open on your default web browser. (The app must be run externally in order to extract *.csv files.)

The *'Hydat.sqlite3'* file is roughly 1GB in size and thus cannot be hosted on GitHub.


## Current version: 1.2.4
**Task list:**

 - [x] Build main Leaflet/Shiny interface
 - [x] Write hydrograph separation routines
 - [ ] Add user-definable parameter adjustment
 - [x] Add flow summary section
 - [x] Write ecological/environment flow (E-Flow) statistics
 - [x] Flow duration curve/return periods
 - [x] Peak flow frequency/return periods
 - [ ] Tests for stationarity (Mann-Kendall, double-mass, etc.)
 - [x] Low flow frequency/return period analysis
 - [ ] Drought indices (i.e., MDSI)
 - [ ] Incorporation of catchment precipitation
 - [x] Hydrograph parsing (rising limb, falling limb, baseflow recession)
 - [x] Continuous to discrete hydrograph translation

### License

sHydrology hosted on GitHub is released under the MIT license.

### Contributors

Mason Marchidon P.Eng M.ASc, Hydrologist for the [Oak Ridges Moraine Groundwater Program](http://oakridgeswater.ca/)

### Release notes

**version 1.2.4 - 2019-12-05**

general improvements
added Indicators of Hydrologic Alteration (IHA) *(modified from https://rdrr.io/rforge/IHA/)*
added first-order (inverse) hyperbolic stream flow recession coefficient computation
added capability to ingest precipitation *(not available in HYDAT mode)*

**version 1.2.1 - 2018-11-07**

bug fix: axis labelling
reorganized code for better HYDAT integration
added description to stream flow recession coefficient
fixed stream flow recession coefficient button actions
fixed hydrograph parsing bugs
updated about page

**version 1.2 - 2018-05-15**

code reorganization

**version 1.1 - 2018-05-04**

1. general tab reorganization
2. using optimized APIs for quicker data access
3. added BFI to cumulative plots
4. bug fixes

**version 1.0.1 - 2018-01-16**

fixed bug where contributing area = 0 cause plot failure

**version 1.0 - 2018-01-12**

initial release

## References

Boughton, W.C., 1993. A hydrograph-based model for estimating the water yield of ungauged catchments. Hydrology and Water Resources Symposium, Institution of Engineers Australia, Newcastle: 317-324.

Chapman, T.G. and A.I. Maxwell, 1996. Baseflow separation - comparison of numerical methods with tracer experiments.Institute Engineers Australia National Conference. Publ. 96/05, 539-545.

Chapman T.G., 1999. A comparison of algorithms for stream flow recession and baseflow separation. Hydrological Processes 13: 710-714.

Clarifica Inc., 2002. Water Budget in Urbanizing Watersheds: Duffins Creek Watershed. Report prepared for the Toronto and Region Conservation Authority.

Eckhardt, K., 2005. How to construct recursive digital filters forbaseflow separation. Hydrological Processes 19, 507-515.

Institute of Hydrology, 1980. Low Flow Studies report. Wallingford, UK.

Jakeman, A.J. and Hornberger G.M., 1993. How much complexity is warranted in a rainfall-runoff model? Water Resources Research 29: 2637-2649.

Linsley, R.K., M.A. Kohler, J.L.H. Paulhus, 1975. Hydrology for Engineers 2nd ed. McGraw-Hill. 482pp.

Lyne, V. and M. Hollick, 1979. Stochastic time-variable rainfall-runoff modelling. Hydrology and Water Resources Symposium, Institution of Engineers Australia, Perth: 89-92.

McGill, R., Tukey, J. W. and Larsen, W. A. (1978) Variations of box plots. The American Statistician 32, 12-16.

Piggott, A.R., S. Moin, C. Southam, 2005. A revised approach to the UKIH method for the calculation of baseflow. Hydrological Sciences Journal 50(5): 911-920.

Reed, D.W., P. Johnson, J.M. Firth, 1975. A Non-Linear Rainfall-Runoff Model, Providing for Variable Lag Time. Journal of Hydrology 25: 295–305.

Rutledge, A.T., 1998. Computer Programs for Describing the Recession of Ground-Water Discharge and for Estimating Mean Ground-Water Recharge and Discharge from Streamflow Records-Update, Water-Resources Investigation Report 98-4148.

Sloto, R.A. and M.Y. Crouse, 1996. HYSEP: A Computer Program for Streamflow Hydrograph Separation and Analysis U.S. Geological Survey Water-Resources Investigations Report 96-4040.