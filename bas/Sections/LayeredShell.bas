# section LayeredShell $sectionTag $nLayers $matTag1 $thickness_1 ... $matTagn $thickness_n
# *tcl(UserMaterial::GetMaterialName *MatProp(0))

*#
*# define PlateRebar for top longitudinal reinforcement
*#
*set var PlateRebarLongTag=PlateRebarLongTag+1
*set var SelectedLongRBMaterial=tcl(FindMaterialNumber *MatProp(Longitudinal_steel_material) *DomainNum)
*set var MaterialExists=tcl(CheckUsedMaterials *SelectedLongRBMaterial )
*if(MaterialExists==-1)
*loop materials *NotUsed
*set var MaterialID=tcl(FindMaterialNumber *Matprop(0) *DomainNum)
*if(SelectedLongRBMaterial==MaterialID)
*if(strcmp(MatProp(Material:),"Steel01")==0)
*include ..\Materials\Uniaxial\Steel01.bas
*elseif(strcmp(MatProp(Material:),"Steel02")==0)
*include ..\Materials\Uniaxial\Steel02.bas
*elseif(strcmp(MatProp(Material:),"Hysteretic")==0)
*include ..\Materials\Uniaxial\Hysteretic.bas
*elseif(strcmp(MatProp(Material:),"ReinforcingSteel")==0)
*include ..\Materials\Uniaxial\ReinforcingSteel.bas
*elseif(strcmp(MatProp(Material:),"RambergOsgoodSteel")==0)
*include ..\Materials\Uniaxial\RambergOsgoodSteel.bas
*elseif(strcmp(MatProp(Material:),"UserMaterial")==0)
set MatTag *SelectedSection; # *tcl(UserMaterial::GetMaterialName *MatProp(0))
*include ..\..\Materials\User\UserMaterial.bas
*else
*MessageBox Error: Unsupported steel material for LayeredShell Section
*endif
*set var dummy=tcl(AddUsedMaterials *SelectedLongRBMaterial)
*break
*endif
*end materials
*endif
*format "%6d%4d%4d"
nDMaterial PlateRebarThermal *PlateRebarLongTag *SelectedLongRBMaterial  90
*#
*# define PlateRebar for transverse reinforcement
*#
*set var PlateRebarTransTag=PlateRebarTransTag+1
*set var SelectedTransverseRBMaterial=tcl(FindMaterialNumber *MatProp(Transverse_steel_material) *DomainNum)
*set var MaterialExists=tcl(CheckUsedMaterials *SelectedTransverseRBMaterial )
*if(MaterialExists==-1)
*loop materials *NotUsed
*set var MaterialID=tcl(FindMaterialNumber *Matprop(0) *DomainNum)
*if(SelectedTransverseRBMaterial==MaterialID)
*if(strcmp(MatProp(Material:),"Steel01")==0)
*include ..\Materials\Uniaxial\Steel01.bas
*elseif(strcmp(MatProp(Material:),"Steel02")==0)
*include ..\Materials\Uniaxial\Steel02.bas
*elseif(strcmp(MatProp(Material:),"Hysteretic")==0)
*include ..\Materials\Uniaxial\Hysteretic.bas
*elseif(strcmp(MatProp(Material:),"ReinforcingSteel")==0)
*include ..\Materials\Uniaxial\ReinforcingSteel.bas
*elseif(strcmp(MatProp(Material:),"RambergOsgoodSteel")==0)
*include ..\Materials\Uniaxial\RambergOsgoodSteel.bas
*elseif(strcmp(MatProp(Material:),"UserMaterial")==0)
set MatTag *SelectedSection; # *tcl(UserMaterial::GetMaterialName *MatProp(0))
*include ..\..\Materials\User\UserMaterial.bas
*else
*MessageBox Error: Unsupported steel material for LayeredShell Section
*endif
*set var dummy=tcl(AddUsedMaterials *SelectedTransverseRBMaterial)
*break
*endif
*end materials
*endif
*format "%6d%4d%4d"
nDMaterial PlateRebarThermal *PlateRebarTransTag *SelectedTransverseRBMaterial  0
*#
*#
*# define decking steel
*#
*#
*set var PlateRebarDeckingTag=PlateRebarTransTag+1
*set var SelectedTransverseRBMaterial=tcl(FindMaterialNumber *MatProp(Transverse_steel_material) *DomainNum)
*set var MaterialExists=tcl(CheckUsedMaterials *SelectedTransverseRBMaterial )
*if(MaterialExists==-1)
*loop materials *NotUsed
*set var MaterialID=tcl(FindMaterialNumber *Matprop(0) *DomainNum)
*if(SelectedTransverseRBMaterial==MaterialID)
*if(strcmp(MatProp(Material:),"Steel01")==0)
*include ..\Materials\Uniaxial\Steel01.bas
*elseif(strcmp(MatProp(Material:),"Steel02")==0)
*include ..\Materials\Uniaxial\Steel02.bas
*elseif(strcmp(MatProp(Material:),"Hysteretic")==0)
*include ..\Materials\Uniaxial\Hysteretic.bas
*elseif(strcmp(MatProp(Material:),"ReinforcingSteel")==0)
*include ..\Materials\Uniaxial\ReinforcingSteel.bas
*elseif(strcmp(MatProp(Material:),"RambergOsgoodSteel")==0)
*include ..\Materials\Uniaxial\RambergOsgoodSteel.bas
*elseif(strcmp(MatProp(Material:),"UserMaterial")==0)
set MatTag *SelectedSection; # *tcl(UserMaterial::GetMaterialName *MatProp(0))
*include ..\..\Materials\User\UserMaterial.bas
*else
*MessageBox Error: Unsupported steel material for LayeredShell Section
*endif
*set var dummy=tcl(AddUsedMaterials *SelectedTransverseRBMaterial)
*break
*endif
*end materials
*endif
*set var angle=MatProp(Angle,real)
*if(strcmp(MatProp(Material:),"UserMaterial")==0)
*format "%6d%4d%4d"
nDMaterial   PlateFromPlaneStressThermal    *PlateRebarDeckingTag   *SelectedTransverseRBMaterial   20e5;
*else
*format "%6d%4d%4d%4d"
nDMaterial PlateRebarThermal *PlateRebarDeckingTag *SelectedTransverseRBMaterial  *angle
*#
*#
*# define CDPMaterial for concrete
*#
*set var PlaneStressUserMaterialTag=PlaneStressUserMaterialTag+1
*set var fc=MatProp(Concrete_compressive_strength,real)
*set var fct=MatProp(Concrete_tensile_strength,real)
*set var epsc0=MatProp(Concrete_strain_at_compr_strength,real)
*set var Ec=operation(1.5*fc/epsc0)
*set var n=MatProp(Compressive_cracking_energy_multiplier_n,real)
*set var m=MatProp(Tensile_cracking_energy_multiplier_m,real)
*set var gc=operation((fc/Ec)*(n-1)*fc/2)
*set var gt=operation((fct/Ec)*(m-1)*fct/2)
*#
#nDMaterial  CDPPlaneStressThermal matTag Ec  v  ft  fc  gt  gc
*format "%6d%6g%6g%6g%6g%6g"
nDMaterial CDPPlaneStressThermal   *PlaneStressUserMaterialTag *Ec 0.2 *fct *fc *gt *gc
*# define PlateFromPlaneStress material
*set var PlateFromPlaneStressMaterialTag=PlateFromPlaneStressMaterialTag+1
*format "%6d%6d%6g"
nDMaterial PlateFromPlaneStressThermal *PlateFromPlaneStressMaterialTag *PlaneStressUserMaterialTag *MatProp(Shear_modulus_of_out_plane,real)
*#
*#
*#
*set var offset=MatProp(Offset,real)
*set var thickness=MatProp(Slab_thickness,real)
*set var topCover=MatProp(Top_reinforcement_cover,real)
*set var botCover=MatProp(Bot_reinforcement_cover,real)
*set var topLongBarDiameter=MatProp(Top_longitudinal_bar_diameter, real)
*set var botLongBarDiameter=MatProp(Bot_longitudinal_bar_diameter, real)
*set var topTransBarDiameter=MatProp(Top_transverse_bar_diameter, real)
*set var botTransBarDiameter=MatProp(Bot_transverse_bar_diameter, real)
*set var topLongBarSpacing=MatProp(Top_longitudinal_bar_spacing, real)
*set var botLongBarSpacing=MatProp(Bot_longitudinal_bar_spacing, real)
*set var topTransBarSpacing=MatProp(Top_transverse_bar_spacing, real)
*set var botTransBarSpacing=MatProp(Bot_transverse_bar_spacing, real)
*#
*# Values to use for the layers
*set var topLongThick=operation((topLongBarDiameter*topLongBarDiameter*3.1415926/4)*(1/topLongBarSpacing))
*set var topTransThick=operation((topTransBarDiameter*topTransBarDiameter*3.1415926/4)*(1/topTransBarSpacing))
*set var botLongThick=operation((botLongBarDiameter*botLongBarDiameter*3.1415926/4)*(1/botLongBarSpacing))
*set var botTransThick=operation((botTransBarDiameter*botTransBarDiameter*3.1415926/4)*(1/botTransBarSpacing))
*set var deckingThick=MatProp(Decking_thickness, real)
*#
*#
*set var nlayersTopCover=MatProp(Top_cover_layers,int)
*set var nlayersBotCover=MatProp(Bot_cover_layers,int)
*set var nlayersCore=MatProp(Core_layers,int)
*#
*set var nlayersSteel=5
*if(topLongThick==0)
*set var nlayersSteel=operation(nlayersSteel-1)
*endif
*if(topTransThick==0)
*set var nlayersSteel=operation(nlayersSteel-1)
*endif
*if(botLongThick==0)
*set var nlayersSteel=operation(nlayersSteel-1)
*endif
*if(botTransThick==0)
*set var nlayersSteel=operation(nlayersSteel-1)
*endif
*if(deckingThick==0)
*set var nlayersSteel=operation(nlayersSteel-1)
*endif
*set var nlayers=operation(nlayersTopCover+nlayersBotCover+nlayersCore+nlayersSteel)
*#
*#
*#
*set var topCoverThick=operation(topCover/nlayersTopCover)
*set var botCoverThick=operation(botCover/nlayersBotCover)
*set var coreThick=operation((thickness-(topCover+botCover+botTransThick+botLongThick+topTransThick+topLongThick))/nlayersCore)
*set var LayeredShellTag=SectionID
*#
*#
*format "%d%d"
section LayeredShellThermal *LayeredShellTag *nlayers *\
*set var PlateFromPlaneStressMaterialTag=PlateFromPlaneStressMaterialTag-1
*if(deckingThick!=0)
*format "%d%g"
*PlateRebarDeckingTag *deckingThick *\
*endif
*#
*# Bot cover
*if(botCover!=0)
*for(i=1;i<=nlayersBotCover;i=i+1)
*format "%d%g"
*PlateFromPlaneStressMaterialTag *BotCoverThick *\
*endfor
*endif
*#
*# Bot Rebars
*#
*if(botTransThick!=0)
*format "%d%g"
*PlateRebarTransTag *botTransThick *\
*endif
*if(botLongThick!=0)
*format "%d%g"
*PlateRebarLongTag *botLongThick *\
*endif
*#
*#
*set var PlateFromPlaneStressMaterialTag=PlateFromPlaneStressMaterialTag+1
*for(i=1;i<=nlayersCore;i=i+1)
*format "%d%g"
*PlateFromPlaneStressMaterialTag *coreThick *\
*endfor
*#
*# Top Rebars
*if(topTransThick!=0)
*format "%d%g"
*PlateRebarTransTag *topTransThick *\
*endif
*if(topLongThick!=0)
*format "%d%g"
*PlateRebarLongTag *topLongThick *\
*endif
*#
*# Top cover
*if(topCover!=0)
*for(i=1;i<=nlayersTopCover;i=i+1)
*format "%d%g"
*PlateFromPlaneStressMaterialTag *topCoverThick *\
*endfor
*endif
*set var PlateFromPlaneStressMaterialTag=PlateFromPlaneStressMaterialTag+1
