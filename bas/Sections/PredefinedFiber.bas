*set var FiberTag=SectionID
*set var SelectedSteelMaterial=tcl(FindMaterialNumber *MatProp(Steel_material) *DomainNum)
*set var MaterialExists=tcl(CheckUsedMaterials *SelectedSteelMaterial)
*if(MaterialExists==-1)
*loop materials *NotUsed
*set var MaterialID=tcl(FindMaterialNumber *Matprop(0) *DomainNum)
*if(SelectedSteelMaterial==MaterialID)
*if(strcmp(MatProp(Material:),"Steel01")==0)
*include ..\Materials\Uniaxial\Steel01.bas
*elseif(strcmp(MatProp(Material:),"Steel02")==0)
*include ..\Materials\Uniaxial\Steel02.bas
*elseif(strcmp(MatProp(Material:),"ReinforcingSteel")==0)
*include ..\Materials\Uniaxial\ReinforcingSteel.bas
*elseif(strcmp(MatProp(Material:),"RambergOsgoodSteel")==0)
*include ..\Materials\Uniaxial\RambergOsgoodSteel.bas
*elseif(strcmp(MatProp(Material:),"Hysteretic")==0)
*include ..\Materials\Uniaxial\Hysteretic.bas
*elseif(strcmp(MatProp(Material:),"MinMax")==0)
*include ..\Materials\Uniaxial\MinMax.bas
*else
*MessageBox Error: Unsupported Rebar material for Fiber Section
*endif
*set var dummy=tcl(AddUsedMaterials *SelectedSteelMaterial)
*break
*endif
*end materials
*endif
*#------start: Stiffened section material-------------------------------
*if(strcmp(Matprop(Cross_section),"Stiffened_I_Section")==0 && MatProp(Plate_t,real) > 0)
*set var SelectedPlateSteelMaterial=tcl(FindMaterialNumber *MatProp(Plate_Steel_material) *DomainNum)
*set var MaterialExists=tcl(CheckUsedMaterials *SelectedPlateSteelMaterial)
*if(MaterialExists==-1)
*loop materials *NotUsed
*set var MaterialID=tcl(FindMaterialNumber *Matprop(0) *DomainNum)
*if(SelectedPlateSteelMaterial==MaterialID)
*if(strcmp(MatProp(Material:),"Steel01")==0)
*include ..\Materials\Uniaxial\Steel01.bas
*elseif(strcmp(MatProp(Material:),"Steel02")==0)
*include ..\Materials\Uniaxial\Steel02.bas
*elseif(strcmp(MatProp(Material:),"ReinforcingSteel")==0)
*include ..\Materials\Uniaxial\ReinforcingSteel.bas
*elseif(strcmp(MatProp(Material:),"RambergOsgoodSteel")==0)
*include ..\Materials\Uniaxial\RambergOsgoodSteel.bas
*elseif(strcmp(MatProp(Material:),"Hysteretic")==0)
*include ..\Materials\Uniaxial\Hysteretic.bas
*elseif(strcmp(MatProp(Material:),"MinMax")==0)
*include ..\Materials\Uniaxial\MinMax.bas
*else
*MessageBox Error: Unsupported Rebar material for Fiber Section
*endif
*set var dummy=tcl(AddUsedMaterials *SelectedPlateSteelMaterial)
*break
*endif
*end materials
*endif
*endif
*#------end: Stiffened section material-------------------------------
*#------start: Web Stiffened section material-------------------------------
*if(Matprop(Web_plate_stiffened,int)==1)
*set var SelectedWebPlateSteelMaterial=tcl(FindMaterialNumber *MatProp(Web_plate_Steel_material) *DomainNum)
*set var MaterialExists=tcl(CheckUsedMaterials *SelectedWebPlateSteelMaterial)
*if(MaterialExists==-1)
*loop materials *NotUsed
*set var MaterialID=tcl(FindMaterialNumber *Matprop(0) *DomainNum)
*if(SelectedWebPlateSteelMaterial==MaterialID)
*if(strcmp(MatProp(Material:),"Steel01")==0)
*include ..\Materials\Uniaxial\Steel01.bas
*elseif(strcmp(MatProp(Material:),"Steel02")==0)
*include ..\Materials\Uniaxial\Steel02.bas
*elseif(strcmp(MatProp(Material:),"ReinforcingSteel")==0)
*include ..\Materials\Uniaxial\ReinforcingSteel.bas
*elseif(strcmp(MatProp(Material:),"RambergOsgoodSteel")==0)
*include ..\Materials\Uniaxial\RambergOsgoodSteel.bas
*elseif(strcmp(MatProp(Material:),"Hysteretic")==0)
*include ..\Materials\Uniaxial\Hysteretic.bas
*elseif(strcmp(MatProp(Material:),"MinMax")==0)
*include ..\Materials\Uniaxial\MinMax.bas
*else
*MessageBox Error: Unsupported Rebar material for Fiber Section
*endif
*set var dummy=tcl(AddUsedMaterials *SelectedWebPlateSteelMaterial)
*break
*endif
*end materials
*endif
*endif
*#------end: Web Stiffened section material-------------------------------
*# ------------------------FIBER definition--------------------
*set var h=MatProp(Height_h,real)
*set var tw=MatProp(Web_thickness_tw,real)
*set var b=MatProp(Flange_width_b,real)
*set var tf=MatProp(Flange_thickness_tf,real)
*set var angle=MatProp(Rotation_angle,real)
*set var E=MatProp(Young_modulus,real)
*set var JG=MatProp(Torsional_stiffness,real)
*set var TSect=MatProp(T_section,int)
*set var dblSect=MatProp(Two_back_to_back_sections,int)
*set var separation=MatProp(Separation,real)
*format "%d"
section fiberSecThermal *FiberTag *\
*format "%g"
-GJ *JG *\
 {
*if(TSect==1)
*if(dblSect==1)
*if(angle==0)
*# double T sections with an angle of 0
# Bottom Section Flange
# patch rect $matTag $numSubdivIJ $numSubdivJK $yI $zI $yJ $zJ $yK $zK $yL $zL
*set var zdivision=MatProp(Flange_Z_fibers,int)
*set var ydivision=MatProp(Flange_Y_fibers,int)
*set var Iy=operation(-0.5*b)
*set var Iz=operation(-0.5*separation-tf)
*set var Jy=operation(0.5*b)
*set var Jz=operation(Iz)
*set var Ky=operation(Jy)
*set var Kz=operation(Iz+tf)
*set var Ly=operation(Iy)
*set var Lz=operation(Kz)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
# Bottom Section Web
*set var zdivision=MatProp(Web_Z_fibers,int)
*set var ydivision=MatProp(Web_Y_fibers,int)
*set var Iy=operation(-0.5*tw)
*set var Iz=operation(-0.5*separation-h)
*set var Jy=operation(0.5*tw)
*set var Jz=operation(Iz)
*set var Ky=operation(Jy)
*set var Kz=operation(Iz+h-tf)
*set var Ly=operation(Iy)
*set var Lz=operation(Kz)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
*#
# Top Section Flange
*set var zdivision=MatProp(Flange_Z_fibers,int)
*set var ydivision=MatProp(Flange_Y_fibers,int)
*set var Iy=operation(-0.5*b)
*set var Iz=operation(0.5*separation)
*set var Jy=operation(0.5*b)
*set var Jz=operation(Iz)
*set var Ky=operation(Jy)
*set var Kz=operation(Iz+tf)
*set var Ly=operation(Iy)
*set var Lz=operation(Kz)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
# Top Section Web
*set var zdivision=MatProp(Web_Z_fibers,int)
*set var ydivision=MatProp(Web_Y_fibers,int)
*set var Iy=operation(-0.5*tw)
*set var Iz=operation(0.5*separation+tf)
*set var Jy=operation(0.5*tw)
*set var Jz=operation(Iz)
*set var Ky=operation(Jy)
*set var Kz=operation(Iz+h-tf)
*set var Ly=operation(Iy)
*set var Lz=operation(Kz)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
*else
*# double T sections with an angle of 90
# Right Section Flange
# patch rect $matTag $numSubdivIJ $numSubdivJK $yI $zI $yJ $zJ $yK $zK $yL $zL
*set var zdivision=MatProp(Flange_Z_fibers,int)
*set var ydivision=MatProp(Flange_Y_fibers,int)
*set var Iy=operation(0.5*separation)
*set var Iz=operation(-0.5*b)
*set var Jy=operation(Iy+tf)
*set var Jz=operation(Iz)
*set var Ky=operation(Jy)
*set var Kz=operation(Iz+b)
*set var Ly=operation(Iy)
*set var Lz=operation(Kz)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
# Right Section Web
*set var zdivision=MatProp(Web_Z_fibers,int)
*set var ydivision=MatProp(Web_Y_fibers,int)
*set var Iy=operation(0.5*separation+tf)
*set var Iz=operation(-0.5*tw)
*set var Jy=operation(Iy+h-tf)
*set var Jz=operation(Iz)
*set var Ky=operation(Jy)
*set var Kz=operation(Iz+tw)
*set var Ly=operation(Iy)
*set var Lz=operation(Kz)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
# Left Section Flange
*set var zdivision=MatProp(Flange_Z_fibers,int)
*set var ydivision=MatProp(Flange_Y_fibers,int)
*set var Iy=operation(-0.5*separation-tf)
*set var Iz=operation(-0.5*b)
*set var Jy=operation(Iy+tf)
*set var Jz=operation(Iz)
*set var Ky=operation(Jy)
*set var Kz=operation(Iz+b)
*set var Ly=operation(Iy)
*set var Lz=operation(Kz)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
# Left Section Web
*set var zdivision=MatProp(Web_Z_fibers,int)
*set var ydivision=MatProp(Web_Y_fibers,int)
*set var Iy=operation(-0.5*separation-h)
*set var Iz=operation(-0.5*tw)
*set var Jy=operation(Iy+h-tf)
*set var Jz=operation(Iz)
*set var Ky=operation(Jy)
*set var Kz=operation(Iz+tw)
*set var Ly=operation(Iy)
*set var Lz=operation(Kz)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
*endif
*else
*if(angle==0)
# Flange
# patch rect $matTag $numSubdivIJ $numSubdivJK $yI $zI $yJ $zJ $yK $zK $yL $zL
*set var zdivision=MatProp(Flange_Z_fibers,int)
*set var ydivision=MatProp(Flange_Y_fibers,int)
*set var Iy=operation(-0.5*b)
*set var Iz=operation(0.5*h-tf)
*set var Jy=operation(0.5*b)
*set var Jz=operation(Iz)
*set var Ky=operation(Jy)
*set var Kz=operation(Iz+tf)
*set var Ly=operation(Iy)
*set var Lz=operation(Kz)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
# Web
*set var zdivision=MatProp(Web_Z_fibers,int)
*set var ydivision=MatProp(Web_Y_fibers,int)
*set var Iy=operation(-0.5*tw)
*set var Iz=operation(-0.5*h)
*set var Jy=operation(0.5*tw)
*set var Jz=operation(Iz)
*set var Ky=operation(Jy)
*set var Kz=operation(Iz+h-tf)
*set var Ly=operation(Iy)
*set var Lz=operation(Kz)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
*else
# Flange (90 Degree)
# patch rect $matTag $numSubdivIJ $numSubdivJK $yI $zI $yJ $zJ $yK $zK $yL $zL
*set var zdivision=MatProp(Flange_Z_fibers,int)
*set var ydivision=MatProp(Flange_Y_fibers,int)
*set var Iy=operation(-0.5*h)
*set var Iz=operation(-0.5*b)
*set var Jy=operation(Iy+tf)
*set var Jz=operation(Iz)
*set var Ky=operation(Jy)
*set var Kz=operation(Iz+b)
*set var Ly=operation(Iy)
*set var Lz=operation(Kz)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
# Web (90 Degree)
*set var zdivision=MatProp(Web_Z_fibers,int)
*set var ydivision=MatProp(Web_Y_fibers,int)
*set var Iy=operation(-0.5*h+tf)
*set var Iz=operation(-0.5*tw)
*set var Jy=operation(Iy+h-tf)
*set var Jz=operation(Iz)
*set var Ky=operation(Jy)
*set var Kz=operation(Iz+tw)
*set var Ly=operation(Iy)
*set var Lz=operation(Kz)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
*endif
*endif
*else
# Top flange
# patch rect $matTag $numSubdivIJ $numSubdivJK $yI $zI $yJ $zJ $yK $zK $yL $zL
*set var zdivision=MatProp(Flange_Z_fibers,int)
*set var ydivision=MatProp(Flange_Y_fibers,int)
*set var Iy=tcl(GetTopFlangeIy *h *b *tf *angle)
*set var Iz=tcl(GetTopFlangeIz *h *b *tf *angle)
*set var Jy=tcl(GetTopFlangeJy *h *b *tf *angle)
*set var Jz=tcl(GetTopFlangeJz *h *b *tf *angle)
*set var Ky=tcl(GetTopFlangeKy *h *b *tf *angle)
*set var Kz=tcl(GetTopFlangeKz *h *b *tf *angle)
*set var Ly=tcl(GetTopFlangeLy *h *b *tf *angle)
*set var Lz=tcl(GetTopFlangeLz *h *b *tf *angle)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
# Web
*set var zdivision=MatProp(Web_Z_fibers,int)
*set var ydivision=MatProp(Web_Y_fibers,int)
*set var Iy=tcl(GetWebIy *h *tw *tf *angle)
*set var Iz=tcl(GetWebIz *h *tw *tf *angle)
*set var Jy=tcl(GetWebJy *h *tw *tf *angle)
*set var Jz=tcl(GetWebJz *h *tw *tf *angle)
*set var Ky=tcl(GetWebKy *h *tw *tf *angle)
*set var Kz=tcl(GetWebKz *h *tw *tf *angle)
*set var Ly=tcl(GetWebLy *h *tw *tf *angle)
*set var Lz=tcl(GetWebLz *h *tw *tf *angle)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
*if(strcmp(Matprop(Cross_section),"Stiffened_I_Section")==0 && MatProp(Plate_t,real) > 0)
# Left stiffening plate
*set var pt = MatProp(Plate_t,real)
*set var pl = MatProp(Plate_l,real)
*set var zdivision=MatProp(Plate_Z_fibers,int)
*set var ydivision=MatProp(Plate_Y_fibers,int)
*set var Iy=tcl(GetLeftPlateIy *pl *b *pt *angle)
*set var Iz=tcl(GetLeftPlateIz *pl *b *pt *angle)
*set var Jy=tcl(GetLeftPlateJy *pl *b *pt *angle)
*set var Jz=tcl(GetLeftPlateJz *pl *b *pt *angle)
*set var Ky=tcl(GetLeftPlateKy *pl *b *pt *angle)
*set var Kz=tcl(GetLeftPlateKz *pl *b *pt *angle)
*set var Ly=tcl(GetLeftPlateLy *pl *b *pt *angle)
*set var Lz=tcl(GetLeftPlateLz *pl *b *pt *angle)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedPlateSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
# Right stiffening plate
*set var Iy=tcl(GetRightPlateIy *pl *b *pt *angle)
*set var Iz=tcl(GetRightPlateIz *pl *b *pt *angle)
*set var Jy=tcl(GetRightPlateJy *pl *b *pt *angle)
*set var Jz=tcl(GetRightPlateJz *pl *b *pt *angle)
*set var Ky=tcl(GetRightPlateKy *pl *b *pt *angle)
*set var Kz=tcl(GetRightPlateKz *pl *b *pt *angle)
*set var Ly=tcl(GetRightPlateLy *pl *b *pt *angle)
*set var Lz=tcl(GetRightPlateLz *pl *b *pt *angle)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedPlateSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
*endif 
# Bottom flange
*set var zdivision=MatProp(Flange_Z_fibers,int)
*set var ydivision=MatProp(Flange_Y_fibers,int)
*set var Iy=tcl(GetBotFlangeIy *h *b *tf *angle)
*set var Iz=tcl(GetBotFlangeIz *h *b *tf *angle)
*set var Jy=tcl(GetBotFlangeJy *h *b *tf *angle)
*set var Jz=tcl(GetBotFlangeJz *h *b *tf *angle)
*set var Ky=tcl(GetBotFlangeKy *h *b *tf *angle)
*set var Kz=tcl(GetBotFlangeKz *h *b *tf *angle)
*set var Ly=tcl(GetBotFlangeLy *h *b *tf *angle)
*set var Lz=tcl(GetBotFlangeLz *h *b *tf *angle)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
*#-------web stiffeners--------
*if(Matprop(Web_plate_stiffened,int)==1)
*set var wpt = MatProp(Web_plate_t,real)
*set var wpl = MatProp(Web_plate_l,real)
*set var zdivision=MatProp(Web_plate_Z_fibers,int)
*set var ydivision=MatProp(Web_plate_Y_fibers,int)
*if(angle==0)
#right web stiffening plate
*set var Iy=operation(0.5*tw)
*set var Iz=operation(-0.5*wpl)
*set var Jy=operation(Iy+wpt)
*set var Jz=operation(Iz)
*set var Ky=operation(Jy)
*set var Kz=operation(0.5*wpl)
*set var Ly=operation(Iy)
*set var Lz=operation(Kz)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedWebPlateSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
#left web stiffening plate
*set var Iy=operation(-0.5*tw-wpt)
*set var Iz=operation(-0.5*wpl)
*set var Jy=operation(-0.5*tw)
*set var Jz=operation(Iz)
*set var Ky=operation(Jy)
*set var Kz=operation(0.5*wpl)
*set var Ly=operation(Iy)
*set var Lz=operation(Kz)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedWebPlateSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
*else
#right (top) web stiffening plate
*set var Iy=operation(-0.5*wpl)
*set var Iz=operation(0.5*tw)
*set var Jy=operation(0.5*wpl)
*set var Jz=operation(Iz)
*set var Ky=operation(Jy)
*set var Kz=operation(Jz+wpt)
*set var Ly=operation(Iy)
*set var Lz=operation(Kz)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedWebPlateSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
#left (bottom) web stiffening plate
*set var Iy=operation(-0.5*wpl)
*set var Iz=operation(-0.5*tw-wpt)
*set var Jy=operation(0.5*wpl)
*set var Jz=operation(Iz)
*set var Ky=operation(Jy)
*set var Kz=operation(Jz+wpt)
*set var Ly=operation(Iy)
*set var Lz=operation(Kz)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedWebPlateSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
*endif
*endif
*endif
}
