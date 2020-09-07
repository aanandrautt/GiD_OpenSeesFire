*#	Added By Tejeswar Yarlagadda------------Add Thermal Analysis----------------------------------------------------------------------------------/////////////////////////////////////////////////
*if(cntDBC!=0)
*set cond Line_Thermal *elems *CanRepeat
*loop elems *OnlyInCond
*if(strcmp(ElemsMatProp(Element_type:),"dispBeamColumn")==0)
*if(ElemsMatProp(Activate_Thermal,int)==1)
*if(strcmp(cond(1),"Elemental")==0)
*set var SelectedFireDataRecord=tcl(FindMaterialNumber *cond(2) *DomainNum)
*set var FireDataMaterialExists=tcl(ThermalCheckUsedMaterials *SelectedFireDataRecord)
*set var SelectedSection=tcl(FindMaterialNumber *ElemsMatProp(Section) *DomainNum)
*set var ThermalSectionMaterialExists=tcl(ThermalCheckUsedMaterials *SelectedSection)
*set var ThermalLoadDataTag=tcl(ThermalLoadTag *SelectedFireDataRecord *SelectedSection)
*if(FireDataMaterialExists==-1||ThermalSectionMaterialExists==-1)
*#------------------------------------------------------------------------------------------------
*#loop for thermal conditions applied on elements
*#------------------------------------------------------------------------------------------------
*loop materials *NotUsed
*set var FireDataRecordId=tcl(FindMaterialNumber *MatProp(0) *DomainNum)
*if(SelectedFireDataRecord==FireDataRecordId)
*if(FireDataMaterialExists==-1)
*set var dummy=tcl(ThermalAddUsedMaterials *SelectedFireDataRecord)
*endif
*set var DataType1=strcmp(MatProp(Data_Type:),"Time_Independant")
*set var DataType2=strcmp(MatProp(Data_Type:),"Time_Dependant")
*set var DataPoints=Matprop(Number_of_Data_Points,int)
*set var CalculateDepthPoints=MatProp(Custom_Depth_Points,int)
*if(CalculateDepthPoints!=0)
*set var NPt=MatProp(__,int)
*if(DataPoints==2)
*if(DataPoints==NPt)
*set var Pt1=MatProp(__,1,real)
*set var Pt2=MatProp(__,2,real)
*else
*if(DataType1==0)
*MessageBox Error: Please provide the Depth Points in single row only for the Datat type of Static_Temperature_Data_2
*elseif(DataType2==0)
*MessageBox Error: Please provide the Depth Points in single row only for the Datat type of Transient_Temperature_Data_2
*endif
*endif
*elseif(DataPoints==5)
*if(DataPoints==NPt)
*set var Pt1=MatProp(__,1,real)
*set var Pt2=MatProp(__,2,real)
*set var Pt3=MatProp(__,3,real)
*set var Pt4=MatProp(__,4,real)
*set var Pt5=MatProp(__,5,real)
*else
*if(DataType1==0)
*MessageBox Error: Please provide the Depth Points in single row only for the Datat type of Static_Temperature_Data_5
*elseif(DataType2==0)
*MessageBox Error: Please provide the Depth Points in single row only for the Datat type of Transient_Temperature_Data_5
*endif
*endif
*elseif(DataPoints==9)
*if(DataPoints==NPt)
*set var Pt1=MatProp(__,1,real)
*set var Pt2=MatProp(__,2,real)
*set var Pt3=MatProp(__,3,real)
*set var Pt4=MatProp(__,4,real)
*set var Pt5=MatProp(__,5,real)
*set var Pt6=MatProp(__,6,real)
*set var Pt7=MatProp(__,7,real)
*set var Pt8=MatProp(__,8,real)
*set var Pt9=MatProp(__,9,real)
*else
*if(DataType1==0)
*MessageBox Error: Please provide the Depth Points in single row only for the Datat type of Static_Temperature_Data_9
*elseif(DataType2==0)
*MessageBox Error: Please provide the Depth Points in single row only for the Datat type of Transient_Temperature_Data_9
*endif
*endif
*endif
*endif
*set var NT=MatProp(___,int)
*if(DataType1==0&&strcmp(IntvData(Analysis_Type),"Static")==0)
*if(DataPoints==2)
*if(DataPoints==NT)
*set var T1=MatProp(___,1,real)
*set var T2=MatProp(___,2,real)
*else
*MessageBox Error: Please provide the Temperature data in single row only for the Datat type of Static_Temperature_Data_2
*endif
*elseif(DataPoints==5)
*if(DataPoints==NT)
*set var T1=MatProp(___,1,real)
*set var T2=MatProp(___,2,real)
*set var T3=MatProp(___,3,real)
*set var T4=MatProp(___,4,real)
*set var T5=MatProp(___,5,real)
*else
*MessageBox Error: Please provide the Temperature data in single row only for the Datat type of Static_Temperature_Data_5
*endif
*elseif(DataPoints==9)
*if(DataPoints==NT)
*set var T1=MatProp(___,1,real)
*set var T2=MatProp(___,2,real)
*set var T3=MatProp(___,3,real)
*set var T4=MatProp(___,4,real)
*set var T5=MatProp(___,5,real)
*set var T6=MatProp(___,6,real)
*set var T7=MatProp(___,7,real)
*set var T8=MatProp(___,8,real)
*set var T9=MatProp(___,9,real)
*else
*MessageBox Error: Please provide the Temperature data in single row only for the Datat type of Static_Temperature_Data_9
*endif
*endif
*elseif(DataType2==0&&strcmp(IntvData(Analysis_Type),"Transient")==0)
*set var Ncolumns=operation(DataPoints+1)
*set var Nrows=operation(NT/Ncolumns)
*if(Nrows<7)
*if(DataPoints==2)
*MessageBox Error: Please provide the Temperature data in atleast 7 rows for the Datat type of Transient_Temperature_Data_2
*elseif(DataPoints==5)
*MessageBox Error: Please provide the Temperature data in atleast 7 rows for the Datat type of Transient_Temperature_Data_5
*elseif(DataPoints==9)
*MessageBox Error: Please provide the Temperature data in atleast 7 rows for the Datat type of Transient_Temperature_Data_9
*endif
*else
*if(FireDataMaterialExists==-1)
*for(i=1;i<=NT;i=i+1)
*set var dummy=tcl(Fire::SetScript *cond(2) *MatProp(___,*i,real))
*end for
*set var dummy=tcl(Fire::SaveScriptFile *cond(2) *Nrows *Ncolumns)
*endif
*endif
*else
*MessageBox Error: Please check with Data Type in Fire Window and Analysis type in Interval Data \n if Data Type - Time Independant, then set Analysis Type - Static \n if Data Type - Time Dependant then set Analysis Type - Transient
*endif
*break
*endif
*end materials
*#------------------------------------------------------------------------------------------------
*#loop sections assigned to elements 
*#------------------------------------------------------------------------------------------------
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
*elseif(DataPoints==5)
*if(Pt1>=zhalfbottom&&Pt5=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5)
*endif
*else
*MessageBox Error: Depth Points Defined outside the Fiber section region of Rectangular Column
*endif
*elseif(DataPoints==9)
*if(Pt1>=zhalfbottom&&Pt9<=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5 *T6 *Pt6 *T7 *Pt7 *T8 *Pt8 *T9 *Pt9)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5 *Pt6 *Pt7 *Pt8 *Pt9)
*endif
*else
*MessageBox Error: Depth Points Defined outside the Fiber section region of Rectanguar Column
*endif
*endif
*else
*if(DataPoints==2)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *zhalftop)
*endif
*elseif(DataPoints==5)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom/2) *T3 0 *T4 *operation(zhalftop/2) *T5 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom/2) 0 *operation(zhalftop/2) *zhalftop)
*endif
*elseif(DataPoints==9)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(3.0*zhalfbottom/4.0) *T3 *operation(2.0*zhalfbottom/4.0) *T4 *operation(1.0*zhalfbottom/4.0) *T5 0 *T6 *operation(1.0*zhalftop/4.0) *T7 *operation(2.0*zhalftop/4.0) *T8 *operation(3.0*zhalftop/4.0) *T9 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(3.0*zhalfbottom/4.0) *operation(2.0*zhalfbottom/4.0) *operation(1.0*zhalfbottom/4.0) 0 *operation(1.0*zhalftop/4.0) *operation(2.0*zhalftop/4.0) *operation(3.0*zhalftop/4.0) *zhalftop)
*endif
*endif
*endif
*elseif(strcmp(Matprop(Cross_section),"Rectangular_Beam")==0)
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
*MessageBox Error: Depth Points Defined outside the Fiber section region of Rectangular Beam
*endif
*elseif(DataPoints==5)
*if(Pt1>=zhalfbottom&&Pt5=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5)
*endif
*else
*MessageBox Error: Depth Points Defined outside the Fiber section region of Rectangular Beam
*endif
*elseif(DataPoints==9)
*if(Pt1>=zhalfbottom&&Pt9<=zhalftop)
*if(DataType1==0)
*format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5 *T6 *Pt6 *T7 *Pt7 *T8 *Pt8 *T9 *Pt9)
*elseif(DataType2==0)
*format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*Pt1 *Pt2 *Pt3 *Pt4 *Pt5 *Pt6 *Pt7 *Pt8 *Pt9)
*endif
*else
*MessageBox Error: Depth Points Defined outside the Fiber section region of Rectangular Beam
*endif
*endif
*else
*if(DataPoints==2)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *zhalftop)
*endif
*elseif(DataPoints==5)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom/2) *T3 0 *T4 *operation(zhalftop/2) *T5 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom/2) 0 *operation(zhalftop/2) *zhalftop)
*endif
*elseif(DataPoints==9)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(3.0*zhalfbottom/4.0) *T3 *operation(2.0*zhalfbottom/4.0) *T4 *operation(1.0*zhalfbottom/4.0) *T5 0 *T6 *operation(1.0*zhalftop/4.0) *T7 *operation(2.0*zhalftop/4.0) *T8 *operation(3.0*zhalftop/4.0) *T9 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(3.0*zhalfbottom/4.0) *operation(2.0*zhalfbottom/4.0) *operation(1.0*zhalfbottom/4.0) 0 *operation(1.0*zhalftop/4.0) *operation(2.0*zhalftop/4.0) *operation(3.0*zhalftop/4.0) *zhalftop)
*endif
*endif
*endif
*elseif(strcmp(Matprop(Cross_section),"Tee_Beam")==0)
*set var th=Matprop(Height_h,real)
*set var fw=Matprop(Width_bf,real)
*set var tw=Matprop(Web_width_bw,real)
*set var ts=Matprop(Slab_thickness_hf,real)
*set var SA=operation(ts*(fw-tw))
*set var WA=operation(th*tw)
*set var A=operation(SA+WA)
*set var CM=operation((WA*th/2.0+SA*(th-ts/2.0))/A)
*set var zhalftop=operation(th-CM)
*set var zhalfbottom=operation(-CM)
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
*MessageBox Error: Depth Points Defined outside the Fiber section region of T Beam
*endif
*elseif(DataPoints==5)
*if(Pt1>=zhalfbottom&&Pt5=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5)
*endif
*else
*MessageBox Error: Depth Points Defined outside the Fiber section region of T Beam
*endif
*elseif(DataPoints==9)
*if(Pt1>=zhalfbottom&&Pt9<=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5 *T6 *Pt6 *T7 *Pt7 *T8 *Pt8 *T9 *Pt9)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5 *Pt6 *Pt7 *Pt8 *Pt9)
*endif
*else
*MessageBox Error: Depth Points Defined outside the Fiber section region of T Beam
*endif
*endif
*else
*if(DataPoints==2)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *zhalftop)
*endif
*elseif(DataPoints==5)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/4.0) *T3 *operation(zhalfbottom+2.0*th/4.0) *T4 *operation(zhalftop-th/4.0) *T5 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/4.0) *operation(zhalfbottom+2.0*th/4.0) *operation(zhalftop-th/4.0) *zhalftop)
*endif
*elseif(DataPoints==9)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/8.0) *T3 *operation(zhalfbottom+2.0*th/8.0) *T4 *operation(zhalfbottom+3.0*th/8.0) *T5 *operation(zhalfbottom+4.0*th/8.0) *T6 *operation(zhalftop-3.0*th/8.0) *T7 *operation(zhalftop-2.0*th/8.0) *T8 *operation(zhalftop-th/8.0) *T9 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/8.0) *operation(zhalfbottom+2.0*th/8.0) *operation(zhalfbottom+3.0*th/8.0) *operation(zhalfbottom+4.0*th/8.0) *operation(zhalftop-3.0*th/8.0) *operation(zhalftop-2.0*th/8.0) *operation(zhalftop-th/8.0) *zhalftop)
*endif
*endif
*endif
*elseif(strcmp(Matprop(Cross_section),"Circular_Column")==0)
*set var height=Matprop(Diameter_d,real)
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
*MessageBox Error: Depth Points Defined outside the Fiber section region of Circular Colmn
*endif
*elseif(DataPoints==5)
*if(Pt1>=zhalfbottom&&Pt5=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5)
*endif
*else
*MessageBox Error: Depth Points Defined outside the Fiber section region of Circular Colmn
*endif
*elseif(DataPoints==9)
*if(Pt1>=zhalfbottom&&Pt9<=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5 *T6 *Pt6 *T7 *Pt7 *T8 *Pt8 *T9 *Pt9)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5 *Pt6 *Pt7 *Pt8 *Pt9)
*endif
*else
*MessageBox Error: Depth Points Defined outside the Fiber section region of Circular Colmn
*endif
*endif
*else
*if(DataPoints==2)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *zhalftop)
*endif
*elseif(DataPoints==5)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom/2) *T3 0 *T4 *operation(zhalftop/2) *T5 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom/2) 0 *operation(zhalftop/2) *zhalftop)
*endif
*elseif(DataPoints==9)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(3.0*zhalfbottom/4.0) *T3 *operation(2.0*zhalfbottom/4.0) *T4 *operation(1.0*zhalfbottom/4.0) *T5 0 *T6 *operation(1.0*zhalftop/4.0) *T7 *operation(2.0*zhalftop/4.0) *T8 *operation(3.0*zhalftop/4.0) *T9 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(3.0*zhalfbottom/4.0) *operation(2.0*zhalfbottom/4.0) *operation(1.0*zhalfbottom/4.0) 0 *operation(1.0*zhalftop/4.0) *operation(2.0*zhalftop/4.0) *operation(3.0*zhalftop/4.0) *zhalftop)
*endif
*endif
*endif
*elseif(strcmp(Matprop(Cross_section),"Bridge_Deck")==0)
*if(CalculateDepthPoints!=0)
*if(DataPoints==2)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2)
*elseif(DataType2==0)
*#format "%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2)
*endif
*elseif(DataPoints==5)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5)
*endif
*elseif(DataPoints==9)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5 *T6 *Pt6 *T7 *Pt7 *T8 *Pt8 *T9 *Pt9)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5 *Pt6 *Pt7 *Pt8 *Pt9)
*endif
*endif
*else
*MessageBox Error: Automatic Depth Points cannot be evaluated for Bridge Deck Sections
*endif
*endif
*else
*MessageBox Error: Activate Thermal was not activated in Corresponding Fiber section type assigned to one of the dispBeamColumn element type
*endif
*elseif(strcmp(MatProp(Section:),"FiberBuiltUpSections")==0)
*if(MatProp(Activate_Thermal,int)!=0)
*if(strcmp(Matprop(Section_Type),"Plate")==0)
*set var th=MatProp(lb,real)
*set var zhalftop=th
*set var zhalfbottom=0.0
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
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of Plate
*endif
*elseif(DataPoints==5)
*if(Pt1>=zhalfbottom&&Pt5=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of Plate
*endif
*elseif(DataPoints==9)
*if(Pt1>=zhalfbottom&&Pt9<=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5 *T6 *Pt6 *T7 *Pt7 *T8 *Pt8 *T9 *Pt9)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5 *Pt6 *Pt7 *Pt8 *Pt9)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of Plate
*endif
*endif
*else
*if(DataPoints==2)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *zhalftop)
*endif
*elseif(DataPoints==5)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/4.0) *T3 *operation(zhalfbottom+2.0*th/4.0) *T4 *operation(zhalftop-th/4.0) *T5 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/4.0) *operation(zhalfbottom+2.0*th/4.0) *operation(zhalftop-th/4.0) *zhalftop)
*endif
*elseif(DataPoints==9)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/8.0) *T3 *operation(zhalfbottom+2.0*th/8.0) *T4 *operation(zhalfbottom+3.0*th/8.0) *T5 *operation(zhalfbottom+4.0*th/8.0) *T6 *operation(zhalftop-3.0*th/8.0) *T7 *operation(zhalftop-2.0*th/8.0) *T8 *operation(zhalftop-th/8.0) *T9 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/8.0) *operation(zhalfbottom+2.0*th/8.0) *operation(zhalfbottom+3.0*th/8.0) *operation(zhalfbottom+4.0*th/8.0) *operation(zhalftop-3.0*th/8.0) *operation(zhalftop-2.0*th/8.0) *operation(zhalftop-th/8.0) *zhalftop)
*endif
*endif
*endif
*elseif(strcmp(Matprop(Section_Type),"Angle")==0)
*if(strcmp(Matprop(Make_Section:),"L")==0)
*set var th=operation(MatProp(lb,real)+MatProp(tb,real))
*set var zhalftop=th
*set var zhalfbottom=0.0
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
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of L made up of angle sections
*endif
*elseif(DataPoints==5)
*if(Pt1>=zhalfbottom&&Pt5=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of L made up of angle sections
*endif
*elseif(DataPoints==9)
*if(Pt1>=zhalfbottom&&Pt9<=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5 *T6 *Pt6 *T7 *Pt7 *T8 *Pt8 *T9 *Pt9)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5 *Pt6 *Pt7 *Pt8 *Pt9)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of L made up of angle sections
*endif
*endif
*else
*if(DataPoints==2)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *zhalftop)
*endif
*elseif(DataPoints==5)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/4.0) *T3 *operation(zhalfbottom+2.0*th/4.0) *T4 *operation(zhalftop-th/4.0) *T5 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/4.0) *operation(zhalfbottom+2.0*th/4.0) *operation(zhalftop-th/4.0) *zhalftop)
*endif
*elseif(DataPoints==9)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/8.0) *T3 *operation(zhalfbottom+2.0*th/8.0) *T4 *operation(zhalfbottom+3.0*th/8.0) *T5 *operation(zhalfbottom+4.0*th/8.0) *T6 *operation(zhalftop-3.0*th/8.0) *T7 *operation(zhalftop-2.0*th/8.0) *T8 *operation(zhalftop-th/8.0) *T9 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/8.0) *operation(zhalfbottom+2.0*th/8.0) *operation(zhalfbottom+3.0*th/8.0) *operation(zhalfbottom+4.0*th/8.0) *operation(zhalftop-3.0*th/8.0) *operation(zhalftop-2.0*th/8.0) *operation(zhalftop-th/8.0) *zhalftop)
*endif
*endif
*endif
*elseif(strcmp(Matprop(Make_Section:),"T")==0)
*set var th=operation(MatProp(lb,real)+MatProp(tb,real))
*set var zhalftop=th
*set var zhalfbottom=0.0
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
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of T made up of angle sections
*endif
*elseif(DataPoints==5)
*if(Pt1>=zhalfbottom&&Pt5=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of T made up of angle sections
*endif
*elseif(DataPoints==9)
*if(Pt1>=zhalfbottom&&Pt9<=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5 *T6 *Pt6 *T7 *Pt7 *T8 *Pt8 *T9 *Pt9)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5 *Pt6 *Pt7 *Pt8 *Pt9)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of T made up of angle sections
*endif
*endif
*else
*if(DataPoints==2)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *zhalftop)
*endif
*elseif(DataPoints==5)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/4.0) *T3 *operation(zhalfbottom+2.0*th/4.0) *T4 *operation(zhalftop-th/4.0) *T5 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/4.0) *operation(zhalfbottom+2.0*th/4.0) *operation(zhalftop-th/4.0) *zhalftop)
*endif
*elseif(DataPoints==9)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/8.0) *T3 *operation(zhalfbottom+2.0*th/8.0) *T4 *operation(zhalfbottom+3.0*th/8.0) *T5 *operation(zhalfbottom+4.0*th/8.0) *T6 *operation(zhalftop-3.0*th/8.0) *T7 *operation(zhalftop-2.0*th/8.0) *T8 *operation(zhalftop-th/8.0) *T9 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/8.0) *operation(zhalfbottom+2.0*th/8.0) *operation(zhalfbottom+3.0*th/8.0) *operation(zhalfbottom+4.0*th/8.0) *operation(zhalftop-3.0*th/8.0) *operation(zhalftop-2.0*th/8.0) *operation(zhalftop-th/8.0) *zhalftop)
*endif
*endif
*endif
*elseif(strcmp(Matprop(Make_Section:),"IT")==0)
*set var th=operation(MatProp(lb,real)+MatProp(tb,real))
*set var zhalftop=th
*set var zhalfbottom=0.0
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
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of IT made up of angle sections
*endif
*elseif(DataPoints==5)
*if(Pt1>=zhalfbottom&&Pt5=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of IT
*endif
*elseif(DataPoints==9)
*if(Pt1>=zhalfbottom&&Pt9<=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5 *T6 *Pt6 *T7 *Pt7 *T8 *Pt8 *T9 *Pt9)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5 *Pt6 *Pt7 *Pt8 *Pt9)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of IT made up of angle sections
*endif
*endif
*else
*if(DataPoints==2)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *zhalftop)
*endif
*elseif(DataPoints==5)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/4.0) *T3 *operation(zhalfbottom+2.0*th/4.0) *T4 *operation(zhalftop-th/4.0) *T5 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/4.0) *operation(zhalfbottom+2.0*th/4.0) *operation(zhalftop-th/4.0) *zhalftop)
*endif
*elseif(DataPoints==9)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/8.0) *T3 *operation(zhalfbottom+2.0*th/8.0) *T4 *operation(zhalfbottom+3.0*th/8.0) *T5 *operation(zhalfbottom+4.0*th/8.0) *T6 *operation(zhalftop-3.0*th/8.0) *T7 *operation(zhalftop-2.0*th/8.0) *T8 *operation(zhalftop-th/8.0) *T9 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/8.0) *operation(zhalfbottom+2.0*th/8.0) *operation(zhalfbottom+3.0*th/8.0) *operation(zhalfbottom+4.0*th/8.0) *operation(zhalftop-3.0*th/8.0) *operation(zhalftop-2.0*th/8.0) *operation(zhalftop-th/8.0) *zhalftop)
*endif
*endif
*endif											
*elseif(strcmp(Matprop(Make_Section:),"Plus")==0)
*set var th=operation(2.0*(MatProp(lb,real)+MatProp(tb,real)))
*set var zhalftop=operation(th/2.0)
*set var zhalfbottom=operation(-th/2.0)
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
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of Plus made up of angle sections
*endif
*elseif(DataPoints==5)
*if(Pt1>=zhalfbottom&&Pt5=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of Plus made up of angle sections
*endif
*elseif(DataPoints==9)
*if(Pt1>=zhalfbottom&&Pt9<=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5 *T6 *Pt6 *T7 *Pt7 *T8 *Pt8 *T9 *Pt9)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5 *Pt6 *Pt7 *Pt8 *Pt9)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of Plus made up of angle sections
*endif
*endif
*else
*if(DataPoints==2)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *zhalftop)
*endif
*elseif(DataPoints==5)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/4.0) *T3 *operation(zhalfbottom+2.0*th/4.0) *T4 *operation(zhalftop-th/4.0) *T5 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/4.0) *operation(zhalfbottom+2.0*th/4.0) *operation(zhalftop-th/4.0) *zhalftop)
*endif
*elseif(DataPoints==9)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/8.0) *T3 *operation(zhalfbottom+2.0*th/8.0) *T4 *operation(zhalfbottom+3.0*th/8.0) *T5 *operation(zhalfbottom+4.0*th/8.0) *T6 *operation(zhalftop-3.0*th/8.0) *T7 *operation(zhalftop-2.0*th/8.0) *T8 *operation(zhalftop-th/8.0) *T9 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/8.0) *operation(zhalfbottom+2.0*th/8.0) *operation(zhalfbottom+3.0*th/8.0) *operation(zhalfbottom+4.0*th/8.0) *operation(zhalftop-3.0*th/8.0) *operation(zhalftop-2.0*th/8.0) *operation(zhalftop-th/8.0) *zhalftop)
*endif
*endif
*endif											
*endif
*elseif(strcmp(Matprop(Section_Type),"Channel")==0)
*if(strcmp(Matprop(Make_Section:_),"C")==0)
*set var th=operation(MatProp(lb,real)+MatProp(tb,real))
*set var zhalftop=th
*set var zhalfbottom=0.0
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
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of C made up of channel sections
*endif
*elseif(DataPoints==5)
*if(Pt1>=zhalfbottom&&Pt5=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of C made up of channel sections
*endif
*elseif(DataPoints==9)
*if(Pt1>=zhalfbottom&&Pt9<=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5 *T6 *Pt6 *T7 *Pt7 *T8 *Pt8 *T9 *Pt9)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5 *Pt6 *Pt7 *Pt8 *Pt9)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of C made up of channel sections
*endif
*endif
*else
*if(DataPoints==2)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *zhalftop)
*endif
*elseif(DataPoints==5)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/4.0) *T3 *operation(zhalfbottom+2.0*th/4.0) *T4 *operation(zhalftop-th/4.0) *T5 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/4.0) *operation(zhalfbottom+2.0*th/4.0) *operation(zhalftop-th/4.0) *zhalftop)
*endif
*elseif(DataPoints==9)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/8.0) *T3 *operation(zhalfbottom+2.0*th/8.0) *T4 *operation(zhalfbottom+3.0*th/8.0) *T5 *operation(zhalfbottom+4.0*th/8.0) *T6 *operation(zhalftop-3.0*th/8.0) *T7 *operation(zhalftop-2.0*th/8.0) *T8 *operation(zhalftop-th/8.0) *T9 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/8.0) *operation(zhalfbottom+2.0*th/8.0) *operation(zhalfbottom+3.0*th/8.0) *operation(zhalfbottom+4.0*th/8.0) *operation(zhalftop-3.0*th/8.0) *operation(zhalftop-2.0*th/8.0) *operation(zhalftop-th/8.0) *zhalftop)
*endif
*endif
*endif											
*elseif(strcmp(Matprop(Make_Section:_),"I")==0)
*set var th=operation(MatProp(la,real)+2.0*MatProp(ta,real))
*set var zhalftop=operation(th/2.0)
*set var zhalfbottom=operation(-th/2.0)
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
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of I made up of channel sections
*endif
*elseif(DataPoints==5)
*if(Pt1>=zhalfbottom&&Pt5=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of I made up of channel sections
*endif
*elseif(DataPoints==9)
*if(Pt1>=zhalfbottom&&Pt9<=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5 *T6 *Pt6 *T7 *Pt7 *T8 *Pt8 *T9 *Pt9)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5 *Pt6 *Pt7 *Pt8 *Pt9)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of I made up of channel sections
*endif
*endif
*else
*if(DataPoints==2)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *zhalftop)
*endif
*elseif(DataPoints==5)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/4.0) *T3 *operation(zhalfbottom+2.0*th/4.0) *T4 *operation(zhalftop-th/4.0) *T5 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/4.0) *operation(zhalfbottom+2.0*th/4.0) *operation(zhalftop-th/4.0) *zhalftop)
*endif
*elseif(DataPoints==9)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/8.0) *T3 *operation(zhalfbottom+2.0*th/8.0) *T4 *operation(zhalfbottom+3.0*th/8.0) *T5 *operation(zhalfbottom+4.0*th/8.0) *T6 *operation(zhalftop-3.0*th/8.0) *T7 *operation(zhalftop-2.0*th/8.0) *T8 *operation(zhalftop-th/8.0) *T9 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/8.0) *operation(zhalfbottom+2.0*th/8.0) *operation(zhalfbottom+3.0*th/8.0) *operation(zhalfbottom+4.0*th/8.0) *operation(zhalftop-3.0*th/8.0) *operation(zhalftop-2.0*th/8.0) *operation(zhalftop-th/8.0) *zhalftop)
*endif
*endif
*endif
*elseif(strcmp(Matprop(Make_Section:_),"H"==0)
*set var th=operation(2.0*(MatProp(lb,real)+MatProp(tb,real)))
*set var zhalftop=operation(th/2.0)
*set var zhalfbottom=operation(-th/2.0)
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
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of H made up of channel sections
*endif
*elseif(DataPoints==5)
*if(Pt1>=zhalfbottom&&Pt5=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of H made up of channel sections
*endif
*elseif(DataPoints==9)
*if(Pt1>=zhalfbottom&&Pt9<=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5 *T6 *Pt6 *T7 *Pt7 *T8 *Pt8 *T9 *Pt9)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5 *Pt6 *Pt7 *Pt8 *Pt9)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of H made up of channel sections
*endif
*endif
*else
*if(DataPoints==2)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *zhalftop)
*endif
*elseif(DataPoints==5)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/4.0) *T3 *operation(zhalfbottom+2.0*th/4.0) *T4 *operation(zhalftop-th/4.0) *T5 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/4.0) *operation(zhalfbottom+2.0*th/4.0) *operation(zhalftop-th/4.0) *zhalftop)
*endif
*elseif(DataPoints==9)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/8.0) *T3 *operation(zhalfbottom+2.0*th/8.0) *T4 *operation(zhalfbottom+3.0*th/8.0) *T5 *operation(zhalfbottom+4.0*th/8.0) *T6 *operation(zhalftop-3.0*th/8.0) *T7 *operation(zhalftop-2.0*th/8.0) *T8 *operation(zhalftop-th/8.0) *T9 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/8.0) *operation(zhalfbottom+2.0*th/8.0) *operation(zhalfbottom+3.0*th/8.0) *operation(zhalfbottom+4.0*th/8.0) *operation(zhalftop-3.0*th/8.0) *operation(zhalftop-2.0*th/8.0) *operation(zhalftop-th/8.0) *zhalftop)
*endif
*endif
*endif										
*elseif(strcmp(Matprop(Make_Section:_),"Box")==0)
*set var th=operation(2.0*(MatProp(lb,real)+MatProp(tb,real)))
*set var zhalftop=operation(th/2.0)
*set var zhalfbottom=operation(-th/2.0)
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
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of Box made up of channel sections
*endif
*elseif(DataPoints==5)
*if(Pt1>=zhalfbottom&&Pt5=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of Box made up of channel sections
*endif
*elseif(DataPoints==9)
*if(Pt1>=zhalfbottom&&Pt9<=zhalftop)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5 *T6 *Pt6 *T7 *Pt7 *T8 *Pt8 *T9 *Pt9)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5 *Pt6 *Pt7 *Pt8 *Pt9)
*endif
*else
*MessageBox Error: Depth Points Defined outside the FiberBuiltUP section region of Box made up of channel sections
*endif
*endif
*else
*if(DataPoints==2)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *zhalftop)
*endif
*elseif(DataPoints==5)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/4.0) *T3 *operation(zhalfbottom+2.0*th/4.0) *T4 *operation(zhalftop-th/4.0) *T5 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/4.0) *operation(zhalfbottom+2.0*th/4.0) *operation(zhalftop-th/4.0) *zhalftop)
*endif
*elseif(DataPoints==9)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *zhalfbottom *T2 *operation(zhalfbottom+th/8.0) *T3 *operation(zhalfbottom+2.0*th/8.0) *T4 *operation(zhalfbottom+3.0*th/8.0) *T5 *operation(zhalfbottom+4.0*th/8.0) *T6 *operation(zhalftop-3.0*th/8.0) *T7 *operation(zhalftop-2.0*th/8.0) *T8 *operation(zhalftop-th/8.0) *T9 *zhalftop)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *zhalfbottom *operation(zhalfbottom+th/8.0) *operation(zhalfbottom+2.0*th/8.0) *operation(zhalfbottom+3.0*th/8.0) *operation(zhalfbottom+4.0*th/8.0) *operation(zhalftop-3.0*th/8.0) *operation(zhalftop-2.0*th/8.0) *operation(zhalftop-th/8.0) *zhalftop)
*endif
*endif
*endif										
*endif
*endif
*else
*MessageBox Error: Activate Thermal was not activated in Corresponding FiberBuuiltup section assigned to one of the dispBeamColumn element type
*endif
*elseif(strcmp(MatProp(Section:),"FiberCustom")==0)
*if(MatProp(Activate_Thermal,int)!=0)
*if(CalculateDepthPoints!=0)
*if(DataPoints==2)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2)
*elseif(DataType2==0)
*#format "%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2)
*endif
*elseif(DataPoints==5)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5)
*endif
*elseif(DataPoints==9)
*if(DataType1==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *T1 *Pt1 *T2 *Pt2 *T3 *Pt3 *T4 *Pt4 *T5 *Pt5 *T6 *Pt6 *T7 *Pt7 *T8 *Pt8 *T9 *Pt9)
*elseif(DataType2==0)
*#format "%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f%10.6f"
*set var dummy=tcl(Fire::ThermalLoadData *ThermalLoadDataTag *Pt1 *Pt2 *Pt3 *Pt4 *Pt5 *Pt6 *Pt7 *Pt8 *Pt9)
*endif
*endif
*else
*MessageBox Error: Automatic Depth Points cannot be evaluated for FiberCustom Sections.
*endif
*else
*MessageBox Error: Activate Thermal was not activated in Corresponding FiberBuiltup section type assigned to one of the dispBeamColumn element type
*endif
*else
*MessageBox Error: Section type assigned to one of the dispBeamColumn Elementy type is not compatible for thermal analysis
*endif
*break
*endif
*end materials
*endif
*if(strcmp(IntvData(Analysis_Type),"Static")==0)
*format "%6d"
eleLoad -ele *ElemsNum -type -beamThermal *tcl(Fire::GetThermalLoadData *ThermalLoadDataTag)
*elseif(strcmp(IntvData(Analysis_Type),"Transient")==0)
*format "%6d"
eleLoad -ele *ElemsNum -type -beamThermal -source "../FireData/*tcl(Fire::GetScriptName *cond(2))" *tcl(Fire::GetThermalLoadData *ThermalLoadDataTag)
*else
*MessageBox Error: Analysis Type not compatible for thermal analysis
*endif
*endif
*else
*MessageBox Error: Please activate thermal in respective dispBeamColumn element type in order to apply thermal load
*endif
*else
*MessageBox Error: Invalid element was selected for thermal analysis, dispBeamColumn type element is the only compatible element available for thermal analysis.
*endif
*end elems
*endif
*#	Ended By Tejeswar Yarlagadda------------Add Thermal Analysis----------------------------------------------------------------------------------/////////////////////////////////////////////////