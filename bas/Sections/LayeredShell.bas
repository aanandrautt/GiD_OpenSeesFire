### *tcl(UserMaterial::GetMaterialName *MatProp(0))
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
*else
*MessageBox Error: Unsupported steel material for LayeredShell Section
*endif
*set var dummy=tcl(AddUsedMaterials *SelectedLongRBMaterial)
*break
*endif
*end materials
*endif
*format "%6d%6d%6d"
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
*# define PlateRebar for steel decking
*#
*set var PlateRebarDeckingTag=PlateRebarDeckingTag+1
*set var SelectedDeckingRBMaterial=tcl(FindMaterialNumber *MatProp(Decking_steel_material) *DomainNum)
*set var MaterialExists=tcl(CheckUsedMaterials *SelectedDeckingRBMaterial )
*if(MaterialExists==-1)
*loop materials *NotUsed
*set var MaterialID=tcl(FindMaterialNumber *Matprop(0) *DomainNum)
*if(SelectedDeckingRBMaterial==MaterialID)
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
*else
*MessageBox Error: Unsupported steel material for LayeredShell Section
*endif
*set var dummy=tcl(AddUsedMaterials *SelectedDeckingRBMaterial)
*break
*endif
*end materials
*endif
*set var angle=MatProp(Angle,real)
*format "%6d%6d%6g"
nDMaterial PlateRebarThermal *PlateRebarDeckingTag *SelectedDeckingRBMaterial *angle
*#
*# define CDPThermal for concrete
*#
*set var SelectedCDPMaterial=tcl(FindMaterialNumber *MatProp(Concrete_material) *DomainNum)
*#set var MaterialExists=tcl(CheckUsedMaterials *SelectedDeckingRBMaterial )
*set var MaterialExists=tcl(CheckUsedMaterials *SelectedCDPMaterial)
*if(MaterialExists==-1)
*loop materials *NotUsed
*set var MaterialID=tcl(FindMaterialNumber *Matprop(0) *DomainNum)
*if(SelectedCDPMaterial==MaterialID)
*if(strcmp(MatProp(Material:),"CDPThermal")==0)
*include ..\Materials\nD\CDP.bas
*else
*MessageBox Error: Unsupported concrete material for LayeredShell Section
*endif
*set var dummy=tcl(AddUsedMaterials *SelectedCDPMaterial)
*break
*endif
*end materials
*endif
*#set var PlateFromPlaneStressMaterialTag=SelectedCDPMaterial
*#
*#
*#
*set var offset=MatProp(Offset,real)
*set var thickness=MatProp(Slab_thickness,real)
*set var topCover=MatProp(Top_reinforcement_cover,real)
*set var botCover=MatProp(Bot_reinforcement_cover,real)
*set var topLongBarDiameter=MatProp(Top_longitudinal_bar_diameter,real)
*set var botLongBarDiameter=MatProp(Bot_longitudinal_bar_diameter,real)
*set var topTransBarDiameter=MatProp(Top_transverse_bar_diameter,real)
*set var botTransBarDiameter=MatProp(Bot_transverse_bar_diameter,real)
*set var topLongBarSpacing=MatProp(Top_longitudinal_bar_spacing,real)
*set var botLongBarSpacing=MatProp(Bot_longitudinal_bar_spacing,real)
*set var topTransBarSpacing=MatProp(Top_transverse_bar_spacing,real)
*set var botTransBarSpacing=MatProp(Bot_transverse_bar_spacing,real)
*#
*# Values to use for the layers
*set var topLongThick=operation((topLongBarDiameter*topLongBarDiameter*3.1415926/4)*(1/topLongBarSpacing))
*set var topTransThick=operation((topTransBarDiameter*topTransBarDiameter*3.1415926/4)*(1/topTransBarSpacing))
*set var botLongThick=operation((botLongBarDiameter*botLongBarDiameter*3.1415926/4)*(1/botLongBarSpacing))
*set var botTransThick=operation((botTransBarDiameter*botTransBarDiameter*3.1415926/4)*(1/botTransBarSpacing))
*set var deckingThick=MatProp(Decking_thickness,real)
*#
*#
*set var nlayersTopCover=MatProp(Top_cover_layers,int)
*set var nlayersBotCover=MatProp(Bot_cover_layers,int)
*set var nlayersCore=MatProp(Core_layers,int)
*#
*set var nlayersSteel=5
*if(topLongThick<=1e-8)
*set var nlayersSteel=operation(nlayersSteel-1)
*endif
*if(topTransThick<=1e-8)
*set var nlayersSteel=operation(nlayersSteel-1)
*endif
*if(botLongThick<=1e-8)
*set var nlayersSteel=operation(nlayersSteel-1)
*endif
*if(botTransThick<=1e-8)
*set var nlayersSteel=operation(nlayersSteel-1)
*endif
*if(deckingThick<=1e-8)
*set var nlayersSteel=operation(nlayersSteel-1)
*endif
*set var nlayersTot=operation(nlayersTopCover+nlayersBotCover+nlayersCore+nlayersSteel)
*#
*#
*#
*set var topCoverThick=operation(topCover/nlayersTopCover)
*set var botCoverThick=operation(botCover/nlayersBotCover)
*set var coreThick=operation((thickness-(topCover+botCover+botTransThick+botLongThick+topTransThick+topLongThick))/nlayersCore)
*set var LayeredShellTag=SectionID
*#
*#
*if(offset==0)
#section LayeredShellThermal $sectionTag $nLayers $matTag1 $thickness_1 ... $matTagn $thickness_n
*format "%d%d"
section LayeredShellThermal *LayeredShellTag *nlayersTot *\
*else
# section	LayeredShellThermal	$sectionTag	-offset $offset	$nLayers	$matTag1 $thickness_1 ... $matTagn $thickness_n
*format "%d"
section LayeredShellThermal *LayeredShellTag *\
*format "%g"
-offset *offset *\
*format "%d"
*nlayersTot *\
*endif
*if(deckingThick!=0)
*format "%d%g"
*PlateRebarDeckingTag *deckingThick *\
*endif
*#
*# Bot cover
*if(botCover!=0)
*for(i=1;i<=nlayersBotCover;i=i+1)
*format "%d%g"
*SelectedCDPMaterial *BotCoverThick *\
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
*for(i=1;i<=nlayersCore;i=i+1)
*format "%d%g"
*SelectedCDPMaterial *coreThick *\
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
*SelectedCDPMaterial *topCoverThick *\
*endfor
*endif

