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

### KNOWN ISSUES

---
- Requires the OpenSees for Fire executable from: http://openseesforfire.github.io/download.html
- The interface does not currently work with GiD 14.0.5. It works fine with GiD 15.0.1 and 14.0.2.
- Currently the interface has only been tested with 3D analysis. 2D analysis has some bugs. Make sure Z is set as the vertical axis and that 3D analysis is on from the General Data window.
- Thermo-mechanical elements, sections, and material replaced their ambient counterparts (from the original OpenSees and interface).
- If the project is actively backed up by OneDrive on a Windows system, Windows Explorer may lock the project folder which prevents GiD from performing any actions on the project files. To remedy this issue restart windows explorer from the task manager (ctrl + shift + esc).
- Make sure to delete old output files when running a new analysis to prevent the post processor from bugging out.
- Baed on Version 2.8.0 of the original GiD + OpenSees Interface so any known issues there also apply here.
---

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
