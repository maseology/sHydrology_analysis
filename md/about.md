# **sHydrology**
#### *A Shiny-Leaflet interface to a stream flow database.*

#### Current functionality:
 * Select gauge from a map
	 * filter locations based on period of record
 * View entire stream flow time series
 * Dynamic hydrograph zooming:
	 * drag-and-click zoom
	 * double-click to full extent
	 * optionnally use date picker
 * Execute a suite of hydrograph separation algorithms (14 in total, see below)
	 * display min/max range (blue band) and median separated baseflow (dotted line)
 * Hydrograph dis-aggregation
 * Automatic recession coefficient computation
 * (Peak/Low) flow frequency analysis
 * In-stream flow regime analysis
 * Trend analysis
 * View data as a table, and export data as *.csv 

## Hydrograph analysis
### Automatic recession coefficient computation:
The recession coefficient (Linsley et.al., 1975) is computed automatically using an iterative procedure whereby the recession curve is positioned to envelope the log-transformed discharge data versus subsequent discharge, on the condition that the former exceeds the latter.

The recession coefficient *k* is the inverse of the slope of the computed recession curve. The resulting fit can be viewed/adjusted in the *recession coefficient* window.

The recession coefficient is required for many of the following hydrograph analyses, and is a common input parameter to many hydrologic models.


### Hydrograph separation methods:
"Baseflow" is separated from the hydrographs using 14 automatic procedures listed below. Standard baseflow model parameters (as documented in the literature) are also listed where applicable. The user may alter these parameters from the *settings: baseflow separation* window *(yet to be completed)*.

 1.	**BF.LH:** The Lyne-Hollick digital filter (Lyne and Hollick, 1979), 3-pass sweep with \\(\alpha=0.925\\) as discussed in Chapman (1999);
 2.	**BF.CM:** The Chapman-Maxwell digital filter (Chapman and Maxwell, 1996), using automatically computed recession coefficient (\\(k\\));
 3.	**BF.BE:** The Boughton-Eckhardt digital filter (Boughton, 1993; Eckhardt, 2005) with computed \\(k\\) and \\(BFI_\text{max}=0.8\\);
 4.	**BF.JH:** The Jakeman-Hornberger digital filter (Jakeman and Hornberger, 1993) based on their IHACRES model with \\(C=0.3\\) and \\(\alpha=-\exp(-1/k)\\);
 5.	**BF.Cl:** The method of Clarifica Inc. (2002);
 6.	**BF.UKn:** The UK Institute of Hydrology (or Wallingford) method (Institute of Hydrology, 1980), sweeping minimum of Piggott et.al. (2005);
 7.	**BF.UKx:** The UK Institute of Hydrology/Wallingford method (Institute of Hydrology, 1980), sweeping maximum of Piggott et.al. (2005);
 8.	**BF.UKm:** The UK Institute of Hydrology/Wallingford method (Institute of Hydrology, 1980), sweeping median;
 9.	**BF.HYSEP.FI:** The HYSEP fixed-interval method (Sloto and Crouse, 1996), with known catchment area;
 10.	**BF.HYSEP.SI:** The HYSEP sliding-interval method (Sloto and Crouse, 1996), with known catchment area;
 11.	**BF.HYSEP.LM:** The HYSEP local minima method (Sloto and Crouse, 1996), with known catchment area;
 12.	**BF.PART1:** The PART method (Rutledge, 1998), with known catchment area, pass 1 of 3 antecedent recession requirement;
 13.	**BF.PART2:** The PART method (Rutledge, 1998), with known catchment area, pass 2 of 3 antecedent recession requirement;
 14.	**BF.PART3:** The PART method (Rutledge, 1998), with known catchment area, pass 3 of 3 antecedent recession requirement.

On the *Long-term trend analysis: monthly baseflow* window, computed baseflow is summarized on a monthly basis in the form of box-whisker plots. The distribution plotted here is built from the median monthly baseflow computed for every month of record using each of the 14 separation methods listed below. Where applicable, the baseflow values have bee normalized by the stream gauge's catchment area thereby providing the values in equivalent mm/month, which can be used as a first-approximation to basin-averaged groundwater recharge.

## Hydrograph summary plots:
#### Annual flow summary
Provides the long-term (calendar-year) annual volumes and deviations of total flow and separated baseflow.

#### Daily average hydrograph
After applying a 5-day rolling average to the hydrograph, both total flow and baseflow are averaged on a daily basis, to illustrate the seasonality of the annual hydrograph *(deprecated)*.

#### Monthly baseflow
Computed baseflow is summarized on a monthly basis in the form of box-whisker plots. The distribution plotted here is built from the median monthly baseflow computed for every month of record using each of the 14 separation methods listed above.

#### Cumulative discharge and BFI
Total and baseflow discharge is accumulated and compared to the long-term trend; this can help identify periods in time where the flow regime has evidently been altered.

A rolling-average Baseflow Index (BFI) plot has been added to further identify changes to the flow regime.

Both plots will automatically be refreshed depending on the time range selected on the hydrograph to the left; this allow quick insight into how the flow regime compares over different time periods.  

## Hydrograph statistical analysis:
#### Peak flow frequency
Peak flow frequency curves were modified (with gratitude) from [headwateranalytics.com](http://www.headwateranalytics.com/blog/flood-frequency-analysis-in-r) *(accessed December, 2016)*.

The method allows for the use of 5 distributions: Log-Pearson type 3 *(default)*, Weibull, Gumbel, Generalized Extreme Value (GEV), and the three-parameter lognormal models. (The user may change the distribution and refresh the plots.)

By default, 90% confidence intervals are then plotted based in the bootstrap technique from 10,000 samples assuming a Log-Pearson III distribution. 

#### Low flow frequency
Using the same procedure as above, 3 low flow frequency plots are provided base on the mean annual minimum (MAM) over *n* consecutive days:

1.	1-day MAM (i.e., the annual extreme minimum)
2.	7-day MAM
3.	30-day MAM

Like before, the user may change the distribution and refresh the plots.

#### Hydrologic flow regime

**IHA**

The Indicators of Hydrologic Alteration (Richter et.al., 1996) has been included and allows the user to dynamically compare IHA statistics between two time periods using the hydrograph view-pane. 

The calculation of IHA statistics is accomplished using the R-IAH package written by Jason Law and is found here: https://rdrr.io/rforge/IHA/ *(accessed February, 2019)*.

**SAAS**

*to do*

#### Recession scatter plot
The recession scatter plot is used to visualize the results of the automatic recession coefficient computation. The recession curve can be viewed and adjusted by manually changing the recession coefficient in the *parameters: recession coefficient* tab.
