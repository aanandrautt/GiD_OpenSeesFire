# GiD + OpenSees Thermo-mechanical Interface
*Department of Building Services Engineering, Faculty of Construction and Environment, The Hong Kong Polytechnic University, China*

**Development team**

- M.A. Orabi, MSc (DIC)

**Special thanks**

- T. Yarlagadda, M.Tech (IITR)
, who came up with the idea to extend the interface in the first place, and who helped me do it myself. 

*(c) 2020*

**Based on the tremendous work of the original GiD + OpenSees Interface team**

https://github.com/rclab-auth/gidopensees

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

### INSTALLATION INFORMATION

---
- Download and install a compatible version of GiD (i.e. 15.0.1 or 14.0.2) from https://www.gidhome.com/
- Download this repository, and only copy OpenSees.exe executable to a path of your choosing. Recommended: C:\Program Files\OpenSees\bin
- Download and install tcl, making sure that the environmental variable is created during the installation by ticking the corresponding box: https://www.activestate.com/products/tcl/
- Download and install the original GiD OpenSees interface making sure to select the path for OpenSees.exe that you chose earlier: https://github.com/rclab-auth/gidopensees
- Copy all the files which you downloaded from this repository EXCEPT for OpenSees.path and OpenSees.exe, and replace the files in your GiD problem type which can typically be found in: C:\Program Files\GiD\GiD 15.0.1\problemtypes\OpenSees.gid
---

### KNOWN ISSUES

---
- Works with the OpenSees for fire executable included with the download.
- The interface does not currently work with GiD 14.0.5. It works fine with GiD 15.0.1 and 14.0.2.
- Currently the interface has only been tested with 3D analysis. 2D analysis has some bugs. Make sure Z is set as the vertical axis and that 3D analysis is on from the General Data window.
- Thermo-mechanical elements, sections, and material replaced their ambient counterparts (from the original OpenSees and interface).
- If the project is actively backed up by OneDrive on a Windows system, Windows Explorer may lock the project folder which prevents GiD from performing any actions on the project files. To remedy this issue restart windows explorer from the task manager (ctrl + shift + esc).
- Make sure to delete old output files when running a new analysis to prevent the post processor from bugging out.
- Baed on Version 2.8.0 of the original GiD + OpenSees Interface so any known issues there also apply here.
---

### FIXED MINOR ISSUES

---
- Issue with local transformation detected: Sometimes horizontal transformation is being used for vertical elements which can cause failure of the analysis.

### VERSION HISTORY

---
**Version 0.1.0 (20/11/2020)**
- This work is based on Version 2.8.0 of the original GiD + OpenSees Interface: https://github.com/rclab-auth/gidopensees
- Thermal sections: Predefined rotatable fiber I section, Layered Shell Thermal.
- Thermal elements: Displacement based beam, ShellNLDKGQ, and ShellMITC4.
- Added load per area for surfaces.
- Added linear gradient thermal load and thermal history for beam and shell elements.
- Modified interval data interface allowing for user-defined analysis time and number of steps.
- Added temperature and damage indices to the layer recorders and modified post processor to add these results to the output database.
