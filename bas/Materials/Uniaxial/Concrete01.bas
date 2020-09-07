*set var dummy=tcl(Fire::ActivateThermalcheck Concrete01 *MatProp(Activate_Thermal,int) *ElemsMatProp(Element_type:) *ElemsNum)
*if(dummy==1)
*MessageBox
*endif
*format "%d%g%g%g%g"
*if(MatProp(Activate_Thermal,int)==0)
uniaxialMaterial Concrete01 *MaterialID *MatProp(Compressive_strength_fpc,real) *MatProp(Strain_at_maximum_strength_epsc0,real) *MatProp(Crushing_strength_fpcu,real) *MatProp(Strain_at_crushing_strength_epscU,real)
*else
uniaxialMaterial Concrete01Thermal *MaterialID *MatProp(Compressive_strength_fpc,real) *MatProp(Strain_at_maximum_strength_epsc0,real) *MatProp(Crushing_strength_fpcu,real) *MatProp(Strain_at_crushing_strength_epscU,real)
*endif