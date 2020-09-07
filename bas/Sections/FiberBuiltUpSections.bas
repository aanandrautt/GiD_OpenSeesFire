*set var FiberTag=SectionID
*set var dummy=tcl(Fire::ActivateThermalcheck FiberBuiltUpSections *MatProp(Activate_Thermal,int) *ElemsMatProp(Element_type:) *ElemsNum)
*if(dummy==1)
*MessageBox
*endif
*#	Added By Tejeswar Yarlagadda------------Built Up Sections and Add Thermal Analysis----------------------------------------------------------------------------------/////////////////////////////////////////////////
*#--------------------------------------------------------------------3D--------------------------------------------------------------------
*#--------------------------------------------------------------------3D--------------------------------------------------------------------
*#--------------------------------------------------------------------3D--------------------------------------------------------------------
*if(ndime==3)
*#-------------------------Materials-----------------------------------------/////////////////////////////////////////////////
*set var sectionmaterial=tcl(FindMaterialNumber *MatProp(Section_Type_Material:) *DomainNum)
*set var MaterialExists=tcl(CheckUsedMaterials *sectionmaterial)
*if(MaterialExists==-1)
*loop materials *NotUsed
*set var MaterialID=tcl(FindMaterialNumber *Matprop(0) *DomainNum)
*if(sectionmaterial==MaterialID)
*if(strcmp(MatProp(Material:),"Steel01")==0)
*include ..\Materials\Uniaxial\Steel01.bas
*elseif(strcmp(MatProp(Material:),"Steel02")==0)
*include ..\Materials\Uniaxial\Steel02.bas
*elseif(strcmp(MatProp(Material:),"RambergOsgoodSteel")==0)
*include ..\Materials\Uniaxial\RambergOsgoodSteel.bas
*elseif(strcmp(MatProp(Material:),"Hysteretic")==0)
*include ..\Materials\Uniaxial\Hysteretic.bas
*elseif(strcmp(MatProp(Material:),"MinMax")==0)
*include ..\Materials\Uniaxial\MinMax.bas
*else
*MessageBox Error: Unsupported Built Up Section material for Fiber Section
*endif
*set var dummy=tcl(AddUsedMaterials *sectionmaterial)
*break
*endif
*end materials
*endif
*#-------------------------END Materials-------------------------------------/////////////////////////////////////////////////

*#-------------------------Fiber Sections------------------------------------/////////////////////////////////////////////////
*#-------------------------Plate section--------------------------/////////////////////////////////////////////////
*if(strcmp(MatProp(Section_Type),"Plate")==0)
#-------------------------Plate section--------------------------
*set var ycoordinate=MatProp(la,real)
*set var zcoordinate=MatProp(lb,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2)
*MessageBox Error: Please use at least two number of fibers in each direction of Plate section
*else
*set var yfibers=MatProp(Fibers_along_la,int)
*set var zfibers=MatProp(Fibers_along_lb,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *yfibers *zfibers 0 0 *ycoordinate *zcoordinate
}
*#-------------------------END Plate section----------------------/////////////////////////////////////////////////

*#-------------------------Angle sections-------------------------/////////////////////////////////////////////////
*elseif(strcmp(MatProp(Section_Type),"Angle")==0)
*#-------------------------L section------------------------------/////////////////////////////////////////////////
*if(strcmp(MatProp(Make_Section:),"L")==0)
#-------------------------L section------------------------------
*set var ycoordinate=MatProp(la,real)
*set var zcoordinate=MatProp(lb,real)
*set var ytcoordinate=MatProp(ta,real)
*set var ztcoordinate=MatProp(tb,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2||MatProp(Fibers_along_ta,int)<2||MatProp(Fibers_along_tb,int)<2)
*MessageBox Error: Please use at least two number of fibers along each leg and thickness in L section
*else
*set var yfibers=MatProp(Fibers_along_la,int)
*set var zfibers=MatProp(Fibers_along_lb,int)
*set var ytfibers=MatProp(Fibers_along_ta,int)
*set var ztfibers=MatProp(Fibers_along_tb,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
#Angle Side a
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *yfibers *ztfibers *ytcoordinate 0 *operation(ycoordinate+ytcoordinate) *ztcoordinate

#Angle Side b
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *zfibers 0 *ztcoordinate *ytcoordinate *operation(zcoordinate+ztcoordinate)

#Angle Common Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *ztfibers 0 0 *ytcoordinate *ztcoordinate
}
*#-------------------------END L section--------------------------/////////////////////////////////////////////////

*#-------------------------T section------------------------------/////////////////////////////////////////////////
*elseif(strcmp(MatProp(Make_Section:),"T")==0)
#-------------------------T section------------------------------
*set var ycoordinate=MatProp(la,real)
*set var zcoordinate=MatProp(lb,real)
*set var ytcoordinate=MatProp(ta,real)
*set var ztcoordinate=MatProp(tb,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2||MatProp(Fibers_along_ta,int)<2||MatProp(Fibers_along_tb,int)<2)
*MessageBox Error: Please use at least two number of fibers along each leg and thickness in T section
*else
*set var yfibers=MatProp(Fibers_along_la,int)
*set var zfibers=MatProp(Fibers_along_lb,int)
*set var ytfibers=MatProp(Fibers_along_ta,int)
*set var ztfibers=MatProp(Fibers_along_tb,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
#Web
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*ytfibers) *zfibers *operation(-ytcoordinate) 0 *ytcoordinate *zcoordinate

#Flange Left
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *yfibers *ztfibers *operation(-(ycoordinate+ytcoordinate)) *zcoordinate *operation(-ytcoordinate) *operation(zcoordinate+ztcoordinate)

#Flange Right
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *yfibers *ztfibers *ytcoordinate *zcoordinate *operation(ycoordinate+ytcoordinate) *operation(zcoordinate+ztcoordinate)

#Common Web&Flange Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*ytfibers) *ztfibers *operation(-ytcoordinate) *zcoordinate *ytcoordinate *operation(zcoordinate+ztcoordinate)
}
*#-------------------------END T section--------------------------/////////////////////////////////////////////////

*#-------------------------Inverted T section---------------------/////////////////////////////////////////////////
*elseif(strcmp(MatProp(Make_Section:),"IT")==0)
#-------------------------Inverted T section----------------------
*set var ycoordinate=MatProp(la,real)
*set var zcoordinate=MatProp(lb,real)
*set var ytcoordinate=MatProp(ta,real)
*set var ztcoordinate=MatProp(tb,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2||MatProp(Fibers_along_ta,int)<2||MatProp(Fibers_along_tb,int)<2)
*MessageBox Error: Please use at least two number of fibers along each leg and thickness in Inverted T section
*else
*set var yfibers=MatProp(Fibers_along_la,int)
*set var zfibers=MatProp(Fibers_along_lb,int)
*set var ytfibers=MatProp(Fibers_along_ta,int)
*set var ztfibers=MatProp(Fibers_along_tb,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
#Web
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*ytfibers) *zfibers *operation(-ytcoordinate) *ztcoordinate *ytcoordinate *operation(zcoordinate+ztcoordinate)

#Flange Left
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *yfibers *ztfibers *operation(-(ycoordinate+ytcoordinate)) 0 *operation(-ytcoordinate) *ztcoordinate

#Flange Right
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *yfibers *ztfibers *ytcoordinate 0 *operation(ycoordinate+ytcoordinate) *ztcoordinate

#Common Web&Flange Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*ytfibers) *ztfibers *operation(-ytcoordinate) 0 *ytcoordinate *ztcoordinate
}
*#-------------------------END Inverted T section-----------------/////////////////////////////////////////////////

*#-------------------------Plus section---------------------------/////////////////////////////////////////////////
*elseif(strcmp(MatProp(Make_Section:),"Plus")==0)
#-------------------------Plus section----------------------------
*set var ycoordinate=MatProp(la,real)
*set var zcoordinate=MatProp(lb,real)
*set var ytcoordinate=MatProp(ta,real)
*set var ztcoordinate=MatProp(tb,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2||MatProp(Fibers_along_ta,int)<2||MatProp(Fibers_along_tb,int)<2)
*MessageBox Error: Please use at least two number of fibers along each leg and thickness in Plus section
*else
*set var yfibers=MatProp(Fibers_along_la,int)
*set var zfibers=MatProp(Fibers_along_lb,int)
*set var ytfibers=MatProp(Fibers_along_ta,int)
*set var ztfibers=MatProp(Fibers_along_tb,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
#Down Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*ytfibers) *zfibers *operation(-ytcoordinate) *operation(-(zcoordinate+ztcoordinate)) *ytcoordinate *operation(-ztcoordinate)

#Up Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*ytfibers) *zfibers *operation(-ytcoordinate) *ztcoordinate *ytcoordinate *operation(zcoordinate+ztcoordinate)

#Left Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *yfibers *operation(2*ztfibers) *operation(-(ycoordinate+ytcoordinate)) *operation(-ztcoordinate) *operation(-ytcoordinate) *ztcoordinate

#Right Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *yfibers *operation(2*ztfibers) *ytcoordinate *operation(-ztcoordinate) *operation(ycoordinate+ytcoordinate) *ztcoordinate

#Common Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*ytfibers) *operation(2*ztfibers) *operation(-ytcoordinate) *operation(-ztcoordinate) *ytcoordinate *ztcoordinate
}
*#-------------------------END Plus section-----------------------/////////////////////////////////////////////////
*endif
*#-------------------------END Angle sections---------------------/////////////////////////////////////////////////

*#-------------------------Channel section------------------------/////////////////////////////////////////////////
*elseif(strcmp(MatProp(Section_Type),"Channel")==0)
*#-------------------------C section------------------------------/////////////////////////////////////////////////
*if(strcmp(MatProp(Make_Section:_),"C")==0)
#-------------------------C section-------------------------------
*set var ycoordinate=operation(MatProp(la,real)/2)
*set var zcoordinate=MatProp(lb,real)
*set var ytcoordinate=MatProp(ta,real)
*set var ztcoordinate=MatProp(tb,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2||MatProp(Fibers_along_ta,int)<2||MatProp(Fibers_along_tb,int)<2)
*MessageBox Error: Please use at least two number of fibers along each leg and thickness in C section
*else
*set var yfibers=MatProp(Fibers_along_la,int)
*set var zfibers=MatProp(Fibers_along_lb,int)
*set var ytfibers=MatProp(Fibers_along_ta,int)
*set var ztfibers=MatProp(Fibers_along_tb,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
#Left Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *zfibers *operation(-(ycoordinate+ytcoordinate)) *ztcoordinate *operation(-ycoordinate) *operation(zcoordinate+ztcoordinate)

#Right Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *zfibers *ycoordinate *ztcoordinate *operation(ycoordinate+ytcoordinate) *operation(zcoordinate+ztcoordinate)

#Flange
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *yfibers *ztfibers *operation(-ycoordinate) 0 *ycoordinate *ztcoordinate

#Left Common Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *ztfibers *operation(-(ycoordinate+ytcoordinate)) 0 *operation(-ycoordinate) *ztcoordinate

#Right Common Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *ztfibers *ycoordinate 0 *operation(ycoordinate+ytcoordinate) *ztcoordinate
}
*#-------------------------END C section--------------------------/////////////////////////////////////////////////

*#-------------------------I section------------------------------/////////////////////////////////////////////////
*elseif(strcmp(MatProp(Make_Section:_),"I")==0)
#-------------------------I section-------------------------------
*set var ycoordinate=MatProp(lb,real)
*set var zcoordinate=operation(MatProp(la,real)/2)
*set var ytcoordinate=MatProp(tb,real)
*set var ztcoordinate=MatProp(ta,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2||MatProp(Fibers_along_ta,int)<2||MatProp(Fibers_along_tb,int)<2)
*MessageBox Error: Please use at least two number of fibers along each leg and thickness in I section
*else
*set var yfibers=MatProp(Fibers_along_lb,int)
*set var zfibers=MatProp(Fibers_along_la,int)
*set var ytfibers=MatProp(Fibers_along_tb,int)
*set var ztfibers=MatProp(Fibers_along_ta,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
#Web
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*ytfibers) *zfibers *operation(-ytcoordinate) *operation(-zcoordinate) *operation(ytcoordinate) *zcoordinate

#Bottom Flange Left
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *yfibers *ztfibers *operation(-(ycoordinate+ytcoordinate)) *operation(-(zcoordinate+ztcoordinate)) *operation(-ytcoordinate) *operation(-zcoordinate)

#Bottom Flange Right
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *yfibers *ztfibers *ytcoordinate *operation(-(zcoordinate+ztcoordinate)) *operation(ycoordinate+ytcoordinate) *operation(-zcoordinate)

#Top Flange Left
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *yfibers *ztfibers *operation(-(ycoordinate+ytcoordinate)) *zcoordinate *operation(-ytcoordinate) *operation(zcoordinate+ztcoordinate)

#Top Flange Right
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *yfibers *ztfibers *ytcoordinate *zcoordinate *operation(ycoordinate+ytcoordinate) *operation(zcoordinate+ztcoordinate)

#Bottom Common Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*ytfibers) *ztfibers *operation(-ytcoordinate) *operation(-(zcoordinate+ztcoordinate)) *ytcoordinate *operation(-zcoordinate)

#Top Common Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*ytfibers) *ztfibers *operation(-ytcoordinate) *zcoordinate *ytcoordinate *operation(zcoordinate+ztcoordinate)
}
*#-------------------------END I section--------------------------/////////////////////////////////////////////////

*#-------------------------H section------------------------------/////////////////////////////////////////////////
*elseif(strcmp(MatProp(Make_Section:_),"H")==0)
#-------------------------H section-------------------------------
*set var ycoordinate=operation(MatProp(la,real)/2)
*set var zcoordinate=MatProp(lb,real)
*set var ytcoordinate=MatProp(ta,real)
*set var ztcoordinate=MatProp(tb,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2||MatProp(Fibers_along_ta,int)<2||MatProp(Fibers_along_tb,int)<2)
*MessageBox Error: Please use at least two number of fibers along each leg and thickness in H section
*else
*set var yfibers=MatProp(Fibers_along_la,int)
*set var zfibers=MatProp(Fibers_along_lb,int)
*set var ytfibers=MatProp(Fibers_along_ta,int)
*set var ztfibers=MatProp(Fibers_along_tb,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
#Down Left Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *zfibers *operation(-(ycoordinate+ytcoordinate)) *operation(-(zcoordinate+ztcoordinate)) *operation(-ycoordinate) *operation(-ztcoordinate)

#Dowm Right Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *zfibers *ycoordinate *operation(-(zcoordinate+ztcoordinate)) *operation(ycoordinate+ytcoordinate) *operation(-ztcoordinate)

#Up Left Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *zfibers *operation(-(ycoordinate+ytcoordinate)) *ztcoordinate *operation(-ycoordinate) *operation(zcoordinate+ztcoordinate)

#Up Right Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *zfibers *ycoordinate *ztcoordinate *operation(ycoordinate+ytcoordinate) *operation(zcoordinate+ztcoordinate)

#Flange
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *yfibers *operation(2*ztfibers) *operation(-ycoordinate) *operation(-ztcoordinate) *ycoordinate *ztcoordinate

#Left Common Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *operation(2*ztfibers) *operation(-(ycoordinate+ytcoordinate)) *operation(-ztcoordinate) *operation(-ycoordinate) *ztcoordinate

#Right Common Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *operation(2*ztfibers) *ycoordinate *operation(-ztcoordinate) *operation(ycoordinate+ytcoordinate) *ztcoordinate
}
*#-------------------------END H section--------------------------/////////////////////////////////////////////////

*#-------------------------Box section----------------------------/////////////////////////////////////////////////
*elseif(strcmp(MatProp(Make_Section:_),"Box")==0)
#-------------------------Box section-----------------------------
*set var ycoordinate=operation(MatProp(la,real)/2)
*set var zcoordinate=MatProp(lb,real)
*set var ytcoordinate=MatProp(ta,real)
*set var ztcoordinate=MatProp(tb,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2||MatProp(Fibers_along_ta,int)<2||MatProp(Fibers_along_tb,int)<2)
*MessageBox Error: Please use at least two number of fibers along each leg and thickness in Box section
*else
*set var yfibers=MatProp(Fibers_along_la,int)
*set var zfibers=MatProp(Fibers_along_lb,int)
*set var ytfibers=MatProp(Fibers_along_ta,int)
*set var ztfibers=MatProp(Fibers_along_tb,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
#Left Square of Box
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *operation(2*zfibers) *operation(-(ycoordinate+ytcoordinate)) *operation(-zcoordinate) *operation(-ycoordinate) *zcoordinate

#Right Square of Box
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *operation(2*zfibers) *ycoordinate *operation(-zcoordinate) *operation(ycoordinate+ytcoordinate) *ztcoordinate

#Down Square of Box
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *yfibers *ztfibers *operation(-ycoordinate)) *operation(-(zcoordinate+ztcoordinate)) *ycoordinate *operation(-zcoordinate)

#Up Square of Box
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *yfibers *ztfibers *operation(-ycoordinate)) *zcoordinate *ycoordinate *operation(zcoordinate+ztcoordinate)

#Left Down Corner
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *ztfibers *operation(-(ycoordinate+ytcoordinate)) *operation(-(zcoordinate+ztcoordinate)) *operation(-ycoordinate) *operation(-zcoordinate)

#Right Down Corner
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *ztfibers *ycoordinate *operation(-(zcoordinate+ztcoordinate)) *operation(ycoordinate+ytcoordinate) *operation(-zcoordinate)

#Left Up Corner
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *ztfibers *operation(-(ycoordinate+ytcoordinate)) *zcoordinate *operation(-ycoordinate) *operation(zcoordinate+ztcoordinate)

#Right Up Corner
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ytfibers *ztfibers *ycoordinate *zcoordinate *operation(ycoordinate+ytcoordinate) *operation(zcoordinate+ztcoordinate)
}
*#-------------------------END Box section------------------------/////////////////////////////////////////////////
*endif
*#-------------------------END Channel sections-------------------/////////////////////////////////////////////////
*endif
*#-------------------------END Fiber Sections--------------------------------/////////////////////////////////////////////////
*#endif
*#--------------------------------------------------------------------END 3D----------------------------------------------------------------/////////////////////////////////////////////////
*#--------------------------------------------------------------------END 3D----------------------------------------------------------------/////////////////////////////////////////////////
*#--------------------------------------------------------------------END 3D----------------------------------------------------------------/////////////////////////////////////////////////

*#--------------------------------------------------------------------2D--------------------------------------------------------------------
*#--------------------------------------------------------------------2D--------------------------------------------------------------------
*#--------------------------------------------------------------------2D--------------------------------------------------------------------
*elseif(ndime==2)
*#-------------------------Materials-----------------------------------------/////////////////////////////////////////////////
*set var sectionmaterial=tcl(FindMaterialNumber *MatProp(Section_Type_Material:) *DomainNum)
*set var MaterialExists=tcl(CheckUsedMaterials *sectionmaterial)
*if(MaterialExists==-1)
*loop materials *NotUsed
*set var MaterialID=tcl(FindMaterialNumber *Matprop(0) *DomainNum)
*if(sectionmaterial==MaterialID)
*if(strcmp(MatProp(Material:),"Steel01")==0)
*include ..\Materials\Uniaxial\Steel01.bas
*elseif(strcmp(MatProp(Material:),"Steel02")==0)
*include ..\Materials\Uniaxial\Steel02.bas
*elseif(strcmp(MatProp(Material:),"RambergOsgoodSteel")==0)
*include ..\Materials\Uniaxial\RambergOsgoodSteel.bas
*elseif(strcmp(MatProp(Material:),"Hysteretic")==0)
*include ..\Materials\Uniaxial\Hysteretic.bas
*elseif(strcmp(MatProp(Material:),"MinMax")==0)
*include ..\Materials\Uniaxial\MinMax.bas
*else
*MessageBox Error: Unsupported Built Up Section material for Fiber Section
*endif
*set var dummy=tcl(AddUsedMaterials *sectionmaterial)
*break
*endif
*end materials
*endif
*#-------------------------END Materials-------------------------------------/////////////////////////////////////////////////

*#-------------------------Fiber Sections------------------------------------/////////////////////////////////////////////////
*#-------------------------Plate section--------------------------/////////////////////////////////////////////////
*if(strcmp(MatProp(Section_Type),"Plate")==0)
#-------------------------Plate section--------------------------
*set var ycoordinate=MatProp(la,real)
*set var zcoordinate=MatProp(lb,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2)
*MessageBox Error: Please use at least two number of fibers in each direction of Plate section
*else
*set var yfibers=MatProp(Fibers_along_la,int)
*set var zfibers=MatProp(Fibers_along_lb,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *zfibers *yfibers 0 0 *zcoordinate *ycoordinate
}
*#-------------------------END Plate section----------------------/////////////////////////////////////////////////

*#-------------------------Angle sections-------------------------/////////////////////////////////////////////////
*elseif(strcmp(MatProp(Section_Type),"Angle")==0)
*#-------------------------L section------------------------------/////////////////////////////////////////////////
*if(strcmp(MatProp(Make_Section:),"L")==0)
#-------------------------L section------------------------------
*set var ycoordinate=MatProp(la,real)
*set var zcoordinate=MatProp(lb,real)
*set var ytcoordinate=MatProp(ta,real)
*set var ztcoordinate=MatProp(tb,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2||MatProp(Fibers_along_ta,int)<2||MatProp(Fibers_along_tb,int)<2)
*MessageBox Error: Please use at least two number of fibers along each leg and thickness in L section
*else
*set var yfibers=MatProp(Fibers_along_la,int)
*set var zfibers=MatProp(Fibers_along_lb,int)
*set var ytfibers=MatProp(Fibers_along_ta,int)
*set var ztfibers=MatProp(Fibers_along_tb,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
#Angle Side a
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *yfibers 0 *ytcoordinate *ztcoordinate *operation(ycoordinate+ytcoordinate)

#Angle Side b
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *zfibers *ytfibers *ztcoordinate 0 *operation(zcoordinate+ztcoordinate) *ytcoordinate

#Angle Common Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *ytfibers 0 0 *ztcoordinate *ytcoordinate
}
*#-------------------------END L section--------------------------/////////////////////////////////////////////////

*#-------------------------T section------------------------------/////////////////////////////////////////////////
*elseif(strcmp(MatProp(Make_Section:),"T")==0)
#-------------------------T section------------------------------
*set var ycoordinate=MatProp(la,real)
*set var zcoordinate=MatProp(lb,real)
*set var ytcoordinate=MatProp(ta,real)
*set var ztcoordinate=MatProp(tb,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2||MatProp(Fibers_along_ta,int)<2||MatProp(Fibers_along_tb,int)<2)
*MessageBox Error: Please use at least two number of fibers along each leg and thickness in T section
*else
*set var yfibers=MatProp(Fibers_along_la,int)
*set var zfibers=MatProp(Fibers_along_lb,int)
*set var ytfibers=MatProp(Fibers_along_ta,int)
*set var ztfibers=MatProp(Fibers_along_tb,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
#Web
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *zfibers *operation(2*ytfibers) 0 *operation(-ytcoordinate) *zcoordinate *ytcoordinate

#Flange Left
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *yfibers *zcoordinate *operation(-(ycoordinate+ytcoordinate)) *operation(zcoordinate+ztcoordinate) *operation(-ytcoordinate)

#Flange Right
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *yfibers *zcoordinate *ytcoordinate *operation(zcoordinate+ztcoordinate) *operation(ycoordinate+ytcoordinate)

#Common Web&Flange Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *operation(2*ytfibers) *zcoordinate *operation(-ytcoordinate) *operation(zcoordinate+ztcoordinate) *ytcoordinate
}
*#-------------------------END T section--------------------------/////////////////////////////////////////////////

*#-------------------------Inverted T section---------------------/////////////////////////////////////////////////
*elseif(strcmp(MatProp(Make_Section:),"IT")==0)
#-------------------------Inverted T section----------------------
*set var ycoordinate=MatProp(la,real)
*set var zcoordinate=MatProp(lb,real)
*set var ytcoordinate=MatProp(ta,real)
*set var ztcoordinate=MatProp(tb,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2||MatProp(Fibers_along_ta,int)<2||MatProp(Fibers_along_tb,int)<2)
*MessageBox Error: Please use at least two number of fibers along each leg and thickness in Inverted T section
*else
*set var yfibers=MatProp(Fibers_along_la,int)
*set var zfibers=MatProp(Fibers_along_lb,int)
*set var ytfibers=MatProp(Fibers_along_ta,int)
*set var ztfibers=MatProp(Fibers_along_tb,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
#Web
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *zfibers *operation(2*ytfibers) *ztcoordinate *operation(-ytcoordinate) *operation(zcoordinate+ztcoordinate) *ytcoordinate

#Flange Left
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *yfibers 0 *operation(-(ycoordinate+ytcoordinate)) *ztcoordinate *operation(-ytcoordinate)

#Flange Right
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *yfibers 0 *ytcoordinate *ztcoordinate *operation(ycoordinate+ytcoordinate)

#Common Web&Flange Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *operation(2*ytfibers) 0 *operation(-ytcoordinate) *ztcoordinate *ytcoordinate
}
*#-------------------------END Inverted T section-----------------/////////////////////////////////////////////////

*#-------------------------Plus section---------------------------/////////////////////////////////////////////////
*elseif(strcmp(MatProp(Make_Section:),"Plus")==0)
#-------------------------Plus section----------------------------
*set var ycoordinate=MatProp(la,real)
*set var zcoordinate=MatProp(lb,real)
*set var ytcoordinate=MatProp(ta,real)
*set var ztcoordinate=MatProp(tb,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2||MatProp(Fibers_along_ta,int)<2||MatProp(Fibers_along_tb,int)<2)
*MessageBox Error: Please use at least two number of fibers along each leg and thickness in Plus section
*else
*set var yfibers=MatProp(Fibers_along_la,int)
*set var zfibers=MatProp(Fibers_along_lb,int)
*set var ytfibers=MatProp(Fibers_along_ta,int)
*set var ztfibers=MatProp(Fibers_along_tb,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
#Down Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *zfibers *operation(2*ytfibers) *operation(-(zcoordinate+ztcoordinate)) *operation(-ytcoordinate) *operation(-ztcoordinate) *ytcoordinate

#Up Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *zfibers *operation(2*ytfibers) *ztcoordinate *operation(-ytcoordinate) *operation(zcoordinate+ztcoordinate) *ytcoordinate

#Left Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*ztfibers) *yfibers *operation(-ztcoordinate) *operation(-(ycoordinate+ytcoordinate)) *ztcoordinate *operation(-ytcoordinate)

#Right Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*ztfibers) *yfibers *operation(-ztcoordinate) *ytcoordinate *ztcoordinate *operation(ycoordinate+ytcoordinate)

#Common Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*ztfibers) *operation(2*ytfibers) *operation(-ztcoordinate) *operation(-ytcoordinate) *ztcoordinate *ytcoordinate
}
*#-------------------------END Plus section-----------------------/////////////////////////////////////////////////
*endif
*#-------------------------END Angle sections---------------------/////////////////////////////////////////////////

*#-------------------------Channel section------------------------/////////////////////////////////////////////////
*elseif(strcmp(MatProp(Section_Type),"Channel")==0)
*#-------------------------C section------------------------------/////////////////////////////////////////////////
*if(strcmp(MatProp(Make_Section:_),"C")==0)
#-------------------------C section-------------------------------
*set var ycoordinate=operation(MatProp(la,real)/2)
*set var zcoordinate=MatProp(lb,real)
*set var ytcoordinate=MatProp(ta,real)
*set var ztcoordinate=MatProp(tb,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2||MatProp(Fibers_along_ta,int)<2||MatProp(Fibers_along_tb,int)<2)
*MessageBox Error: Please use at least two number of fibers along each leg and thickness in C section
*else
*set var yfibers=MatProp(Fibers_along_la,int)
*set var zfibers=MatProp(Fibers_along_lb,int)
*set var ytfibers=MatProp(Fibers_along_ta,int)
*set var ztfibers=MatProp(Fibers_along_tb,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
#Left Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *zfibers *ytfibers *ztcoordinate *operation(-(ycoordinate+ytcoordinate)) *operation(zcoordinate+ztcoordinate) *operation(-ycoordinate)

#Right Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *zfibers *ytfibers *ztcoordinate *ycoordinate *operation(zcoordinate+ztcoordinate) *operation(ycoordinate+ytcoordinate)

#Flange
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *yfibers 0 *operation(-ycoordinate) *ztcoordinate *ycoordinate

#Left Common Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *ytfibers 0 *operation(-(ycoordinate+ytcoordinate)) *ztcoordinate *operation(-ycoordinate)

#Right Common Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *ytfibers 0 *ycoordinate *ztcoordinate *operation(ycoordinate+ytcoordinate)
}
*#-------------------------END C section--------------------------/////////////////////////////////////////////////

*#-------------------------I section------------------------------/////////////////////////////////////////////////
*elseif(strcmp(MatProp(Make_Section:_),"I")==0)
#-------------------------I section-------------------------------
*set var ycoordinate=MatProp(lb,real)
*set var zcoordinate=operation(MatProp(la,real)/2)
*set var ytcoordinate=MatProp(tb,real)
*set var ztcoordinate=MatProp(ta,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2||MatProp(Fibers_along_ta,int)<2||MatProp(Fibers_along_tb,int)<2)
*MessageBox Error: Please use at least two number of fibers along each leg and thickness in I section
*else
*set var yfibers=MatProp(Fibers_along_lb,int)
*set var zfibers=MatProp(Fibers_along_la,int)
*set var ytfibers=MatProp(Fibers_along_tb,int)
*set var ztfibers=MatProp(Fibers_along_ta,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
#Web
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *zfibers *operation(2*ytfibers) *operation(-zcoordinate) *operation(-ytcoordinate) *zcoordinate *operation(ytcoordinate)

#Bottom Flange Left
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *yfibers *operation(-(zcoordinate+ztcoordinate)) *operation(-(ycoordinate+ytcoordinate)) *operation(-zcoordinate) *operation(-ytcoordinate)

#Bottom Flange Right
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *yfibers *operation(-(zcoordinate+ztcoordinate)) *ytcoordinate *operation(-zcoordinate) *operation(ycoordinate+ytcoordinate)

#Top Flange Left
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *yfibers *zcoordinate *operation(-(ycoordinate+ytcoordinate)) *operation(zcoordinate+ztcoordinate) *operation(-ytcoordinate)

#Top Flange Right
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *yfibers *zcoordinate *ytcoordinate *operation(zcoordinate+ztcoordinate) *operation(ycoordinate+ytcoordinate)

#Bottom Common Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *operation(2*ytfibers) *operation(-(zcoordinate+ztcoordinate)) *operation(-ytcoordinate) *operation(-zcoordinate) *ytcoordinate

#Top Common Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *operation(2*ytfibers) *zcoordinate *operation(-ytcoordinate) *operation(zcoordinate+ztcoordinate) *ytcoordinate
}
*#-------------------------END I section--------------------------/////////////////////////////////////////////////

*#-------------------------H section------------------------------/////////////////////////////////////////////////
*elseif(strcmp(MatProp(Make_Section:_),"H")==0)
#-------------------------H section-------------------------------
*set var ycoordinate=operation(MatProp(la,real)/2)
*set var zcoordinate=MatProp(lb,real)
*set var ytcoordinate=MatProp(ta,real)
*set var ztcoordinate=MatProp(tb,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2||MatProp(Fibers_along_ta,int)<2||MatProp(Fibers_along_tb,int)<2)
*MessageBox Error: Please use at least two number of fibers along each leg and thickness in H section
*else
*set var yfibers=MatProp(Fibers_along_la,int)
*set var zfibers=MatProp(Fibers_along_lb,int)
*set var ytfibers=MatProp(Fibers_along_ta,int)
*set var ztfibers=MatProp(Fibers_along_tb,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
#Down Left Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *zfibers *ytfibers *operation(-(zcoordinate+ztcoordinate)) *operation(-(ycoordinate+ytcoordinate)) *operation(-ztcoordinate) *operation(-ycoordinate)

#Dowm Right Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *zfibers *ytfibers *operation(-(zcoordinate+ztcoordinate)) *ycoordinate *operation(-ztcoordinate) *operation(ycoordinate+ytcoordinate)

#Up Left Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *zfibers *ytfibers *ztcoordinate *operation(-(ycoordinate+ytcoordinate)) *operation(zcoordinate+ztcoordinate) *operation(-ycoordinate)

#Up Right Leg
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *zfibers *ytfibers *ztcoordinate *ycoordinate *operation(zcoordinate+ztcoordinate) *operation(ycoordinate+ytcoordinate)

#Flange
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*ztfibers) *yfibers *operation(-ztcoordinate) *operation(-ycoordinate) *ztcoordinate *ycoordinate

#Left Common Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*ztfibers) *ytfibers *operation(-ztcoordinate) *operation(-(ycoordinate+ytcoordinate)) *ztcoordinate *operation(-ycoordinate)

#Right Common Thickness
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*ztfibers) *ytfibers *operation(-ztcoordinate) *ycoordinate *ztcoordinate *operation(ycoordinate+ytcoordinate)
}
*#-------------------------END H section--------------------------/////////////////////////////////////////////////

*#-------------------------Box section----------------------------/////////////////////////////////////////////////
*elseif(strcmp(MatProp(Make_Section:_),"Box")==0)
#-------------------------Box section-----------------------------
*set var ycoordinate=operation(MatProp(la,real)/2)
*set var zcoordinate=MatProp(lb,real)
*set var ytcoordinate=MatProp(ta,real)
*set var ztcoordinate=MatProp(tb,real)
*if(MatProp(Fibers_along_la,int)<2||MatProp(Fibers_along_lb,int)<2||MatProp(Fibers_along_ta,int)<2||MatProp(Fibers_along_tb,int)<2)
*MessageBox Error: Please use at least two number of fibers along each leg and thickness in Box section
*else
*set var yfibers=MatProp(Fibers_along_la,int)
*set var zfibers=MatProp(Fibers_along_lb,int)
*set var ytfibers=MatProp(Fibers_along_ta,int)
*set var ztfibers=MatProp(Fibers_along_tb,int)
*endif

*if(Matprop(Activate_Thermal,int)==0)
*format "%d"
section Fiber *FiberTag *\
*else
*format "%d"
section fiberSecThermal *FiberTag *\
*endif
*if(MatProp(Torsional_stiffness_GJ,real)!=0 && MatProp(Activate_torsional_stiffness,int)==1)
*format "%g"
-GJ *MatProp(Torsional_stiffness_GJ,real) *\
*endif
 {
#Left Square of Box
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*zfibers) *ytfibers *operation(-zcoordinate) *operation(-(ycoordinate+ytcoordinate)) *zcoordinate *operation(-ycoordinate)

#Right Square of Box
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *operation(2*zfibers) *ytfibers *operation(-zcoordinate) *ycoordinate *ztcoordinate *operation(ycoordinate+ytcoordinate)

#Down Square of Box
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *yfibers *operation(-(zcoordinate+ztcoordinate)) *operation(-ycoordinate)) *operation(-zcoordinate) *ycoordinate

#Up Square of Box
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *yfibers *zcoordinate *operation(-ycoordinate)) *operation(zcoordinate+ztcoordinate) *ycoordinate

#Left Down Corner
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *ytfibers *operation(-(zcoordinate+ztcoordinate)) *operation(-(ycoordinate+ytcoordinate)) *operation(-zcoordinate) *operation(-ycoordinate)

#Right Down Corner
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *ytfibers *operation(-(zcoordinate+ztcoordinate)) *ycoordinate *operation(-zcoordinate) *operation(ycoordinate+ytcoordinate)

#Left Up Corner
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *ytfibers *zcoordinate *operation(-(ycoordinate+ytcoordinate)) *operation(zcoordinate+ztcoordinate) *operation(-ycoordinate)

#Right Up Corner
*format "%3d%6d%6d%10.6f%10.6f%10.6f%10.6f"
patch rect *sectionmaterial *ztfibers *ytfibers *zcoordinate *ycoordinate *operation(zcoordinate+ztcoordinate) *operation(ycoordinate+ytcoordinate)
}
*#-------------------------END Box section------------------------/////////////////////////////////////////////////
*endif
*#-------------------------END Channel sections-------------------/////////////////////////////////////////////////
*endif
*#-------------------------END Fiber Sections--------------------------------/////////////////////////////////////////////////
*endif
*#--------------------------------------------------------------------END 2D----------------------------------------------------------------/////////////////////////////////////////////////
*#--------------------------------------------------------------------END 2D----------------------------------------------------------------/////////////////////////////////////////////////
*#--------------------------------------------------------------------END 2D----------------------------------------------------------------/////////////////////////////////////////////////
*#	Ended By Tejeswar Yarlagadda------------Built Up Sections and Add Thermal Analysis----------------------------------------------------------------------------------/////////////////////////////////////////////////