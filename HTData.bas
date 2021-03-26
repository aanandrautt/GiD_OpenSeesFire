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
*loop intervals
*#beams
*set cond Line_Gas_Temperatures_Central *elems
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
*set var hf = cond(convective_coefficient,real)
*set var ha = globalhamb
*endif
*format "%d%d%g%g%g%g%g%g%d%g%g%g%g
*cond(ID,int)	0	0	*pmat	*tf	*tw	*h	*b	*dp	0.0	0.1	0.9	*plt	*fire	*HTtime *HTtimestep *hf	*ha			
*endif
*end elems
*#slabs
*set cond Surface_Gas_Temperatures_central *elems
*loop elems *OnlyInCond
*if(strcmp(ElemsMatProp(Element_type:),"Shell")==0 || strcmp(ElemsMatProp(Element_type:),"ShellDKGQ"))
*set var DomainNum=6
*set var SelectedSection=tcl(FindMaterialNumber *ElemsMatProp(Type) *DomainNum)
*loop materials *NotUsed
*set var SectionID=tcl(FindMaterialNumber *MatProp(0) *DomainNum)
*if(SelectedSection==SectionID)
*set var dummy=tcl(AddUsedMaterials *SelectedSection)
*if(strcmp(MatProp(Section:),"LayeredShell")==0)
*set var plt = 0.0
*set var ts=MatProp(Slab_thickness,real)
*set var pmat=MatProp(protection_material,int)
*set var dps=MatProp(protection_thickness,real)
*else
*MessageBox Error: Cannot grab section properties from anything other than a LayeredShell section
*endif
*break
*endif
*end materials
*if(*override == 1)
*set var hf = globalhfire
*set var ha = globalhamb
*else
*set var hf = cond(convective_coefficient,real)
*set var ha = globalhamb
*endif
*format "%d%d%g%g%d%g%g%g%g
*cond(ID,int)	0	1	*pmat	0.025	0.08	0.3	0.15	0.0	*dps	*ts	1.0	0.0	*fire	*HTtime *HTtimestep *hf	*ha			
*endif
*end elems
*#composite beams
*set cond Line_Composite_Section_Beam_central *elems
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
*MessageBox Error: Cannot use use a stiffened section with a composite section assignment. HT will crash.
*else
*set var plt = 0.0
*endif
*set var tf=MatProp(Flange_thickness_tf,real)
*set var tw=MatProp(Web_thickness_tw,real)
*set var h=MatProp(Height_h,real)
*set var b=MatProp(Flange_width_b,real)
*set var pmat=MatProp(protection_material,int)
*set var dp=MatProp(protection_thickness,real)
*set var dps=cond(slab_protection,real)
*set var ts=cond(slab_depth,real)
*set var bs=cond(slab_width,real)
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
*set var hf = cond(convective_coefficient,real)
*set var ha = globalhamb
*endif
*format "%d%d%g%g%g%g%g%g%g%g%g%d%g%g%g%g
*cond(ID,int)	1	0	*pmat	*tf	*tw	*h	*b	*dp	*dps	*ts	*bs	*plt	*fire	*HTtime *HTtimestep *hf	*ha			
*endif
*end elems
*end intervals