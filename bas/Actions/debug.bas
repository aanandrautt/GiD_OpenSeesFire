*loop materials *NotUsed
*set var SectionID=tcl(FindMaterialNumber *MatProp(0) *DomainNum)
*if(SelectedSection==SectionID)
*if(ThermalSectionMaterialExists==-1)
*set var dummy=tcl(ThermalAddUsedMaterials *SelectedSection)
*endif
*if(strcmp(MatProp(Section:),"Fiber")==0)
*if(MatProp(Activate_Thermal,int)!=0)
*if(strcmp(Matprop(Cross_section),"Rectangular_Column")==0)
*set var height=Matprop(Height_h,real)
*set var zhalftop=operation(height/2.0)
*set var zhalfbottom=operation(-height/2.0)
*if(CalculateDepthPoints!=0)
*if(DataPoints==2)
*if(Pt1>=zhalfbottom&&Pt2<=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2)
*elseif(DataType2==0)
*#format "%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2)
*endif
*else
*MessageBox Error: Depth Points Defined outside the Fiber section region of Rectangular Column
*endif