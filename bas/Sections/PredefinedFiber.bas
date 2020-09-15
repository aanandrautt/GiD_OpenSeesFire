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
*# ------------------------FIBER definition--------------------
*set var h=MatProp(Height_h,real)
*set var tw=MatProp(Web_thickness_tw,real)
*set var b1=MatProp(Top_flange_width_b1,real)
*set var tf1=MatProp(Top_flange_thickness_tf1,real)
*set var b2=MatProp(Bot_flange_width_b2,real)
*set var tf2=MatProp(Bot_flange_thickness_tf2,real)
*set var angle=MatProp(Rotation_angle,real)
*set var E=MatProp(Young_modulus,real)
*set var G=operation(E/2.6)
*set var J=tcl(GetTorsionalConstant *h *tw *b1 *tf1 *b2 *tf2)
*set var JG=operation(J*G)
*format "%d"
section fiberSecThermal *FiberTag *\
*format "%g"
-GJ *JG *\
 {
*set var zdivision=MatProp(Web_Z_fibers,int)
*set var ydivision=MatProp(Web_Y_fibers,int)
*set var Iy=tcl(GetWebIy *h *tw *tf2 *angle)
*set var Iz=tcl(GetWebIz *h *tw *tf2 *angle)
*set var Jy=tcl(GetWebJy *h *tw *tf2 *angle)
*set var Jz=tcl(GetWebJz *h *tw *tf2 *angle)
*set var Ky=tcl(GetWebKy *h *tw *tf1 *angle)
*set var Kz=tcl(GetWebKz *h *tw *tf1 *angle)
*set var Ly=tcl(GetWebLy *h *tw *tf1 *angle)
*set var Lz=tcl(GetWebLz *h *tw *tf1 *angle)
# patch rect $matTag $numSubdivIJ $numSubdivJK $yI $zI $yJ $zJ $yK $zK $yL $zL
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
*set var zdivision=MatProp(Top_flange_Z_fibers,int)
*set var ydivision=MatProp(Top_flange_Y_fibers,int)
*set var Iy=tcl(GetTopFlangeIy *h *b1 *tf1 *angle)
*set var Iz=tcl(GetTopFlangeIz *h *b1 *tf1 *angle)
*set var Jy=tcl(GetTopFlangeJy *h *b1 *tf1 *angle)
*set var Jz=tcl(GetTopFlangeJz *h *b1 *tf1 *angle)
*set var Ky=tcl(GetTopFlangeKy *h *b1 *tf1 *angle)
*set var Kz=tcl(GetTopFlangeKz *h *b1 *tf1 *angle)
*set var Ly=tcl(GetTopFlangeLy *h *b1 *tf1 *angle)
*set var Lz=tcl(GetTopFlangeLz *h *b1 *tf1 *angle)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
*set var zdivision=MatProp(Bot_flange_Z_fibers,int)
*set var ydivision=MatProp(Bot_flange_Y_fibers,int)
*set var Iy=tcl(GetBotFlangeIy *h *b2 *tf2 *angle)
*set var Iz=tcl(GetBotFlangeIz *h *b2 *tf2 *angle)
*set var Jy=tcl(GetBotFlangeJy *h *b2 *tf2 *angle)
*set var Jz=tcl(GetBotFlangeJz *h *b2 *tf2 *angle)
*set var Ky=tcl(GetBotFlangeKy *h *b2 *tf2 *angle)
*set var Kz=tcl(GetBotFlangeKz *h *b2 *tf2 *angle)
*set var Ly=tcl(GetBotFlangeLy *h *b2 *tf2 *angle)
*set var Lz=tcl(GetBotFlangeLz *h *b2 *tf2 *angle)
*format "%6d%6d%6d%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
patch quad *SelectedSteelMaterial *ydivision *zdivision *Iy *Iz *Jy *Jz *Ky *Kz *Ly *Lz
}
