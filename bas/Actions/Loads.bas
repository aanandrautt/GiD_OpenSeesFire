*set var PrintPlainPattern=0
*set var PrintMultiSupportPattern=0
*set var PrintPlainPatternPathTimeseries=0
*#
*# Check if there are any loads applied
*#
*set cond Point_Forces *nodes *CanRepeat
*add cond Line_Forces *nodes *CanRepeat
*add cond Surface_Forces *nodes *CanRepeat
*add cond Point_Displacements *nodes *CanRepeat
*loop nodes *OnlyInCond
*set var PrintPlainPatternPathTimeseries=1
*break
*end nodes
*set cond Point_Forces *nodes *CanRepeat
*add cond Line_Forces *nodes *CanRepeat
*add cond Surface_Forces *nodes *CanRepeat
*add cond Point_Displacements *nodes *CanRepeat
*add cond Line_Displacements *nodes *CanRepeat
*add cond Surface_Displacements *nodes *CanRepeat
*loop nodes *OnlyInCond
*set var PrintPlainPattern=1
*break
*end nodes
*set cond Line_Uniform_Forces *elems *CanRepeat
*loop elems *OnlyInCond
*set var PrintPlainPattern=1
*set var PrintPlainPatternPathTimeseries=1
*break
*end elems
*set cond Line_Linear_Temperatures *elems *CanRepeat
*loop elems *OnlyInCond
*set var PrintPlainPattern=1
*set var PrintPlainPatternPathTimeseries=1
*break
*end elems
*set cond Surface_Linear_Temperatures *elems *CanRepeat
*loop elems *OnlyInCond
*set var PrintPlainPattern=1
*set var PrintPlainPatternPathTimeseries=1
*break
*end elems
*set cond Surface_Temperature_History *elems *CanRepeat
*loop elems *OnlyInCond
*set var PrintPlainPattern=1
*set var PrintPlainPatternPathTimeseries=1
*break
*end elems
*if(IntvData(Activate_dead_load,int)==1)
*set var PrintPlainPattern=1
*endif
*set cond Point_Ground_Motion_from_Record *nodes
*add cond Point_Sine_Ground_Motion *nodes
*loop nodes *OnlyInCond
*set var PrintMultiSupportPattern=1
*break
*end nodes
*if(strcmp(IntvData(Loading_type),"Constant")==0 || strcmp(IntvData(Loading_type),"Linear")==0)
*#
*# if there are loads applied, Create the pattern
*#
*if(PrintPlainPattern==1)
# Loads - Plain Pattern
*set var PatternTag=operation(IntvNum*100)
pattern Plain *PatternTag *IntvData(Loading_type) {
*#
*# Point / line / surface forces
*#
*set cond Point_Forces *nodes *CanRepeat
*add cond Line_Forces *nodes *CanRepeat
*add cond Surface_Forces *nodes *CanRepeat
*loop nodes *OnlyInCond
*set var nodeDOF=tcl(ReturnNodeGroupDOF *NodesNum)
*if(nodeDOF==6)
*format "%6d"
    load *NodesNum *\
*format "%8g%8g%8g%8g%8g%8g"
*cond(1,real) *cond(2,real) *cond(3,real) *cond(4,real) *cond(5,real) *cond(6,real)
*elseif(nodeDOF==3)
*if(ndime==3)
*format "%6d"
    load *NodesNum *\
*format "%8g%8g%8g"
*cond(1,real) *cond(2,real) *cond(3,real)
*# 2D with 3DOF : Ux Uy Rz --> Fx Fy Mz
*else
*format "%6d"
    load *NodesNum *\
*format "%8g%8g%8g"
*cond(1,real) *cond(2,real) *cond(6,real)
*endif
*elseif(nodeDOF==2)
*format "%6d"
    load *NodesNum *\
*format "%8g%8g"
*cond(1,real) *cond(2,real)
*endif
*end nodes
*if(ndime==3)
*set cond Line_Uniform_Forces *elems
*loop elems *OnlyInCond
*format "%6d%8g%8g%8g"
    eleLoad -ele *ElemsNum -type -beamUniform *cond(2,real) *cond(3,real) *cond(1,real)
*end elems
*# if it is 2D
*else
*set cond Line_Uniform_Forces *elems
*loop elems *OnlyInCond
*format "%6d%8g%8g"
    eleLoad -ele *ElemsNum -type -beamUniform *cond(2,real) *cond(1,real)
*end elems
*endif
*if(ndime==3)
*set cond Line_Linear_Temperatures *elems
*loop elems *OnlyInCond
*format "%6d%8g%8g%8g%8g"
    eleLoad -ele *ElemsNum -type -beamThermal *cond(4,real) *cond(3,real) *cond(2,real) *cond(1,real)
*end elems
*# if it is 2D
*else
*set cond Line_Uniform_Forces *elems
*loop elems *OnlyInCond
*format "%6d%8g%8g%8g%8g"
    eleLoad -ele *ElemsNum -type -beamThermal *cond(1,real) *cond(2,real) *cond(3,real) *cond(4,real)
*end elems
*endif
*if(ndime==3)
*set cond Surface_Linear_Temperatures *elems
*loop elems *OnlyInCond
*format "%6d%8g%8g%8g%8g"
    eleLoad -ele *ElemsNum -type -shellThermal *cond(4,real) *cond(3,real) *cond(2,real) *cond(1,real)
*end elems
*endif
*if(ndime==3)
*set cond Surface_Temperature_History *elems
*loop elems *OnlyInCond
*if(strcmp(ElemsMatProp(Element_type:),"ShellDKGQ")==0 || strcmp(ElemsMatProp(Element_type:),"Shell")==0)
*set var SelectedSection=tcl(FindMaterialNumber *ElemsMatProp(Type) *DomainNum)
*loop materials *NotUsed
*set var SectionID=tcl(FindMaterialNumber *MatProp(0) *DomainNum)
*if(SelectedSection==SectionID)
*set var dummy=tcl(AddUsedMaterials *SelectedSection)
*if(strcmp(MatProp(Section:),"PlateFiber")==0)
*set var thickness=MatProp(Plate_thickness_h,real)
*set var offset=0.0
*set var deckingThick=0.0
*elseif(strcmp(MatProp(Section:),"ElasticMembranePlate")==0)
*set var thickness=MatProp(Section_depth_h,real)
*set var offset=0.0
*set var deckingThick=0.0
*elseif(strcmp(MatProp(Section:),"LayeredShell")==0)
*set var thickness=MatProp(Slab_thickness,real)
*set var deckingThickness=MatProp(Decking_thickness,real)
*set var offset=MatProp(Offset,real)
*elseif(strcmp(MatProp(Section:),"UserMaterial")==0)
*set var thickness=MatProp(Width,real)
*set var offset=0.0
*set var deckingThick=0.0
*else
*MessageBox Error: Invalid Section selected for Shell/ShellDKGQ element
*endif
*break
*endif
*end materials
*set var topFiber=operation(1.001*(thickness+deckingThick)/2.0+offset)
*set var botFiber=operation(-1.001*(thickness+deckingThick)/2.0+offset)
*format "%6d%8g%8g%8g%8g"
    eleLoad -ele *ElemsNum -type -shellThermal -source *cond(1) *botFiber *topFiber	
*endif
*end elems
*endif
*set cond Point_Displacements *nodes
*add cond Line_Displacements *nodes
*add cond Surface_Displacements *nodes
*loop nodes *OnlyInCond
*set var nodeDOF=tcl(ReturnNodeGroupDOF *NodesNum)
*if(nodeDOF==6)
*# 3D - 6 Dofs -> Ux Uy Uz Rx Ry Rz
*# If value is zero, it is like a restraint! So a restraint condition can be used instead.
*if(cond(1,real)!=0)
*format "%6d%8g"
  sp *NodesNum 1 *cond(1,real)
*endif
*if(cond(2,real)!=0)
*format "%6d%8g"
  sp *NodesNum 2 *cond(2,real)
*endif
*if(cond(3,real)!=0)
*format "%6d%8g"
  sp *NodesNum 3 *cond(3,real)
*endif
*if(cond(4,real)!=0)
*format "%6d%8g"
  sp *NodesNum 4 *cond(4,real)
*endif
*if(cond(5,real)!=0)
*format "%6d%8g"
  sp *NodesNum 5 *cond(5,real)
*endif
*if(cond(6,real)!=0)
*format "%6d%8g"
  sp *NodesNum 6 *cond(6,real)
*endif
*elseif(nodeDOF==3)
*if(ndime==3)
*# 3D - 3 Dofs -> Ux Uy Uz
  sp *NodesNum 1 *cond(1,real)
  sp *NodesNum 2 *cond(2,real)
  sp *NodesNum 3 *cond(3,real)
*else
*# 2D - 3 Dofs -> 2 Translations (Ux,Uy) 1 Rotation Rz
*if(cond(1,real)!=0)
*format "%6d%8g"
  sp *NodesNum 1 *cond(1,real)
*endif
*if(cond(2,real)!=0)
*format "%6d%8g"
  sp *NodesNum 2 *cond(2,real)
*endif
*if(cond(6,real)!=0)
*format "%6d%8g"
  sp *NodesNum 3 *cond(6,real)
*endif
*endif
*# 2 dofs
*else
*if(cond(1,real)!=0)
*format "%6d%8g"
  sp *NodesNum 1 *cond(1,real)
*endif
*if(cond(2,real)!=0)
*format "%6d%8g"
  sp *NodesNum 2 *cond(2,real)
*endif
*endif
*end nodes
*if(IntvData(Activate_dead_load,int)==1 && strcmp(IntvData(Analysis_type),"Static")==0 && strcmp(IntvData(Integrator_type),"Load_control")==0)

# Dead Loads

*include DeadLoad.bas
*endif
}
*endif
*elseif(strcmp(IntvData(Loading_type),"Function")==0)
*if(PrintPlainPatternPathTimeseries==1)

# Loads - Timeseries Path

*include PlainPatternTimeseriesPath.bas
*endif
*elseif(strcmp(IntvData(Loading_type),"Multiple_support_excitation")==0)
*if(PrintMultiSupportPattern==1)

# Loads - Multiple Support Pattern

*set var PatternTag=operation(IntvNum*1000)
*include MultipleSupportExcitationPattern.bas
*endif
*endif
