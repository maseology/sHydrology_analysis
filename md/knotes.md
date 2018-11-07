#### Automated stream flow recession coefficient computation:

The stream flow recession coefficient (k), describes the withdrawal of water from storage within the watershed (Linsley et.al., 1975).  The recession coefficient is a means of determining the amount baseflow recedes after a given period of time:

<center>![equation](http://www.sciweavers.org/tex2img.php?eq=b_t%3Dkb_%7Bt-1%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)</center>

where *b<sub>t−1</sub>* represents the stream flow calculated at one time step prior to *b<sub>t</sub>*. (Note, this assumes that total flow measurements are reported at equal time intervals, when unequal intervals are used, *k∆t* must be used, where *∆t* is the time interval between successive *b* calculations relative to the time step *k* was calculated at.)

By plotting *b<sub>t−1</sub>* vs. *b<sub>t</sub>*, the recession coefficient can be determined by finding a linear function (that crosses the origin) such that *k* is equivalent to the function's slope. The linear function must envelope the scatter where *b<sub>t−1</sub>*/*b<sub>t</sub>* approaches 1.0. The reasoning here is that where the difference between *b<sub>t−1</sub>* and *b<sub>t</sub>* is minimized, then those stream flow values are most-likely solely composed of baseflow, i.e., *"the withdrawal of water from storage within the watershed"* (Linsley et.al., 1975). Where *b<sub>t−1</sub>*/*b<sub>t</sub>* < 1.0, it is assumed that stream flow has a larger runoff component, and thus cannot be considered entirely as "baseflow". 

The recession coefficient is computed automatically using an iterative procedure whereby the recession curve is positioned to envelope the log-transformed discharge data versus subsequent discharge, on the condition that the former exceeds the latter.

##### Note:

By updating the plot to a user-defined stream flow recession coefficient, all *k*-dependent calculations used on the sHydrology web app will be affected; otherwise the automated recession coefficient is used by default.

#### References

Linsley, R.K., M.A. Kohler, J.L.H. Paulhus, 1975. Hydrology for Engineers 2 nd ed. McGraw-Hill. 482pp.
