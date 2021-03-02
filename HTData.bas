*if(ndime==3)
*set cond Line_Thermo_Couple *elems
ID	SidesHeated(3/4?)	Protected?	composite?	thickness_flange	thickness_web	section_depth	section_width	protection_thickness	protection_slab	thickness_slab	width_slab
*loop elems *OnlyInCond
*if(strcmp(ElemsMatProp(Element_type:),"dispBeamColumn")==0)
*set var DomainNum=6
*set var SelectedSection=tcl(FindMaterialNumber *ElemsMatProp(Section) *DomainNum)
*loop materials *NotUsed
*set var SectionID=tcl(FindMaterialNumber *MatProp(0) *DomainNum)
*if(SelectedSection==SectionID)
*set var dummy=tcl(AddUsedMaterials *SelectedSection)
*if(strcmp(MatProp(Section:),"Fiber")==0)
*set var tf=MatProp(Flange_thickness_tf,real)
*set var tw=MatProp(Web_thickness_tw,real)
*set var h=MatProp(Height_h,real)
*set var b=MatProp(Flange_width_b,real)
*set var area=MatProp(Cross_section_area,real)
*else
*MessageBox Error: Cannot grab section properties from anything other than a Fiber section
*endif
*break
*endif
*end materials
*format "%s%g%g%g%g
*cond(1)	4	FALSE	FALSE	*tf	*tw	*h	*b	0.0	0.0	150.0	1000.0
*endif
*end elems
*endif