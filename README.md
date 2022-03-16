# GiD + OpenSees Thermo-mechanical Interface
*Department of Building Environment and Energy Engineering, Faculty of Construction and Environment, The Hong Kong Polytechnic University, China*

**Development team**

- M.A. Orabi, PhD, MSc (DIC)

**Special thanks**

- T. Yarlagadda, M.Tech (IITR)
, who came up with the idea to extend the interface in the first place, and who helped me do it myself. 


**To cite this piece of software**

Orabi, M. A., Khan, A. A., Jiang, L., Yarlagadda, T., Torero, J., and Usmani, A. (2022). “Integrated nonlinear structural simulation of composite buildings in fire.” *Engineering Structures*, 252. https://10.1016/j.engstruct.2021.113593.

*(c) 2022*

### INSTALLATION INFORMATION

---
- Download and install a compatible version of GiD (i.e. 15.0.2 or later) from https://www.gidhome.com/
- Download and install tcl, making sure that the environmental variable is created during the installation by ticking the corresponding box: https://www.activestate.com/products/tcl/
- Download the latest release of OpenSees for Fire that is compatible with GiD from: https://github.com/Anwar8/MyOpenSees/releases
- Download and install the original GiD OpenSees interface making sure to select the path for OpenSees.exe that you chose earlier: https://github.com/rclab-auth/gidopensees
- Copy all the files which you downloaded from this repository and replace the files in your GiD problem type which can typically be found in: C:\Program Files\GiD\GiD 15.0.1\problemtypes\OpenSees.gid
---

### KNOWN ISSUES AND LIMITATIONS

---
- When opening an old meshed project and trying to write a tcl OpenSees input it may be necessary to call the commands: `-np- cd $OpenSees::OpenSeesProblemTypePath/exe`, then `-np- source hello.tcl` followed by `-np- Transform::PopulateTagsArray` 
- Currently, the interface is only compatible with 3D analysis. Make sure Z is set as the vertical axis and that 3D analysis is on from the General Data window.
- The postprocessor may import old output files from a previous analysis run if these are not deleted from the project folder. This may cause the postprocessor to stop unexpectadely and fail to generate the output database. Delete previous output files when running a new analysis to prevent this issue.
- Based on Version 2.8.0 of the original GiD + OpenSees Interface so any known issues there may also present here.
---

### VERSION HISTORY
**Version 1.0.0**
- Working version compatible with the Integrated Simulation Environment
---
**Version 0.1.0 (20/11/2020)**
- This work is based on Version 2.8.0 of the original GiD + OpenSees Interface: https://github.com/rclab-auth/gidopensees
- Thermal sections: Predefined rotatable fiber I section, Layered Shell Thermal.
- Thermal elements: Displacement based beam, ShellNLDKGQ, and ShellMITC4.
- Added load per area for surfaces.
- Added linear gradient thermal load and thermal history for beam and shell elements.
- Modified interval data interface allowing for user-defined analysis time and number of steps.
- Added temperature and damage indices to the layer recorders and modified post processor to add these results to the output database.


---

**Based on the tremendous work of the original GiD + OpenSees Interface team:** https://github.com/rclab-auth/gidopensees

*Lab of R/C and Masonry Structures, School of Civil Engineering, Aristotle University of Thessaloniki, Greece*

**Development team**

- T. Kartalis-Kaounis, Dipl. Eng. AUTh, MSc
- V.K. Papanikolaou, Dipl. Eng., MSc DIC, PhD, Asst. Prof. AUTh

**Project contributors**

- F. Derveni, Dipl. Eng. AUTh
- V.K. Protopapadakis, Dipl. Eng. AUTh, MSc
- T. Papadopoulos, Dipl. Eng. AUTh, MSc
- T. Zachariadis, Dipl. Eng. AUTh, MSc

---

