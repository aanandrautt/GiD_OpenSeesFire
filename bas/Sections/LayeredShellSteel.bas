### *tcl(UserMaterial::GetMaterialName *MatProp(0))
*set var PlateThickness=MatProp(Thickness,real)
*set var nLayers=MatProp(n_layers,int)
*set var layerThickness=operation(PlateThickness/nLayers)
*set var PlateFiberTag=SectionID
*set var SelectedMaterial=tcl(FindMaterialNumber *MatProp(Material) *DomainNum)
*set var MaterialExists=tcl(CheckUsedMaterials *SelectedMaterial)
*if(MaterialExists==-1)
*loop materials *NotUsed
*set var MaterialID=tcl(FindMaterialNumber *MatProp(0) *DomainNum)
*if(SelectedMaterial==MaterialID)
*set var dummy=tcl(AddUsedMaterials *SelectedMaterial)
*if(strcmp(MatProp(Material:),"ElasticIsotropic")==0)
*include ..\Materials\nD\ElasticIsotropic.bas
*elseif(strcmp(MatProp(Material:),"ElastiOrthotropic")==0)
*include ..\Materials\nD\ElasticOrthotropic.bas
*elseif(strcmp(MatProp(Material:),"PressureIndependMultiYield")==0)
*MessageBox Shell Elements do not support Plate Fiber Section with PressureIndependMultiYield Material assigned to each fiber
*elseif(strcmp(MatProp(Material:),"PressureDependMultiYield")==0)
*MessageBox Shell Elements do not support Plate Fiber Section with PressureDependMultiYield Material assigned to each fiber
*elseif(strcmp(MatProp(Material:),"J2Plasticity")==0)
*include ..\Materials\nD\J2Plasticity.bas
*elseif(strcmp(MatProp(Material:),"Damage2p")==0)
*include ..\Materials\nD\Damage2p.bas
*endif
*break
*endif
*end materials
*endif
*format "%d%d"
section LayeredShellThermal *PlateFiberTag *nLayers *\
*for(i=1;i<=nLayers;i=i+1)
*format "%d%g"
*SelectedMaterial *layerThickness *\
*endfor 

