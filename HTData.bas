*if(ndime==3)
*set cond Line_Gas_Temperatures_Central *elems
ID composite slab protection_material tf tw h b dp dps ts bs plt FireExposure tFinal dt hfire hamb
*set var HT_time=GenData(fire_duration,real)
*set var HT_timestep=GenData(HT_time_step,real)
*set var override=GenData(override_default_h,int)
*set var global_h_fire=GenData(convective_h_fire,real)
*set var global_h_amb=GenData(convective_h_ambient,real)
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
*set var p_mat=MatProp(protection_material,int)
*set var dp=MatProp(protection_thickness,real)
*else
*MessageBox Error: Cannot grab section properties from anything other than a Fiber section
*endif
*break
*endif
*end materials
*if(strcmp(*cond(3),"standard_fire")==0)
*set var fire = 1
*set var h_f = 35
*set var h_a = 10
*elseif(strcmp(*cond(3),"Hydrocarbon")==0)
*set var fire = 2
*set var h_f = 50
*set var h_a = 10
*else(strcmp(*cond(3),"FDS")==0)
*set var fire = 3
*endif
*if(*override == 1)
*set var h_f = *global_h_fire
*set var h_a = *global_h_amb
*endif
*format "%s%d%g%g%g%g%g%g%d%g%g%g%g
ID 	composite slab protection_material tf tw h b dp dps ts bs plt FireExposure tFinal dt hfire hamb
*cond(2)	0	0	*p_mat	*tf	*tw	*h	*b	*dp	0.0	0.1	0.9	*plt	*fire	*HT_time *HT_timestep *h_f	*h_a			
*endif
*end elems
*endif