*if(ndime==3)
*set cond Line_Gas_Temperatures_Central *elems
ID composite slab protection_material tf tw h b dp dps ts bs plt FireExposure tFinal dt hfire hamb
*set var HTtime=GenData(fire_duration,real)
*set var HTtimestep=GenData(HT_time_step,real)
*set var override=GenData(override_default_h,int)
*set var globalhfire=GenData(convective_h_fire,real)
*set var globalhamb=GenData(convective_h_ambient,real)
*if(strcmp(GenData(Exposure_type),"standard_fire")==0)
*set var fire=1
*elseif(strcmp(GenData(Exposure_type),"Hydrocarbon")==0)
*set var fire=2
*else
*set var fire=3
*endif
*loop elems *OnlyInCond
*if(strcmp(ElemsMatProp(Element_type:),"dispBeamColumn")==0)
*set var DomainNum=6
*set var SelectedSection=tcl(FindMaterialNumber *ElemsMatProp(Section) *DomainNum)
*loop materials *NotUsed
*set var SectionID=tcl(FindMaterialNumber *MatProp(0) *DomainNum)
*if(SelectedSection==SectionID)
*set var dummy=tcl(AddUsedMaterials *SelectedSection)
*if(strcmp(MatProp(Section:),"Fiber")==0)
*if(strcmp(MatProp(Cross_section),"Stiffened_I_Section")==0)
*set var plt=MatProp(Plate_t,real)
*else
*set var plt = 0.0
*endif
*set var tf=MatProp(Flange_thickness_tf,real)
*set var tw=MatProp(Web_thickness_tw,real)
*set var h=MatProp(Height_h,real)
*set var b=MatProp(Flange_width_b,real)
*set var pmat=MatProp(protection_material,int)
*set var dp=MatProp(protection_thickness,real)
*else
*MessageBox Error: Cannot grab section properties from anything other than a Fiber section
*endif
*break
*endif
*end materials
*if(*override == 1)
*set var hf = globalhfire
*set var ha = globalhamb
*else
*set var hf = cond(3,real)
*set var ha = globalhamb
*endif
*format "%s%d%g%g%g%g%g%g%d%g%g%g%g
*cond(2)	0	0	*pmat	*tf	*tw	*h	*b	*dp	0.0	0.1	0.9	*plt	*fire	*HTtime *HTtimestep *hf	*ha			
*endif
*end elems
*endif