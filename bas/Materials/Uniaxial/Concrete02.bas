*set var dummy=tcl(Fire::ActivateThermalcheck Concrete02 *MatProp(Activate_Thermal,int) *ElemsMatProp(Element_type:) *ElemsNum)
*if(dummy==1)
*MessageBox
*endif
*format "%d%g%g%g%g%g%g%g"
*if(MatProp(Activate_Thermal,int)==0)
uniaxialMaterial Concrete02 *MaterialID *MatProp(Compressive_strength_fpc,real) *MatProp(Strain_at_maximum_strength_epsc0,real) *MatProp(Crushing_strength_fpcu,real) *MatProp(Strain_at_crushing_strength_epscU,real) *MatProp(Ratio_between_unloading_slope_at_epscU_and_initial_slope_lambda,real) *MatProp(Tensile_strength_Ft,real) *MatProp(Tension_softening_stiffness_Ets,real)
*else
uniaxialMaterial Concrete02Thermal *MaterialID *MatProp(Compressive_strength_fpc,real) *MatProp(Strain_at_maximum_strength_epsc0,real) *MatProp(Crushing_strength_fpcu,real) *MatProp(Strain_at_crushing_strength_epscU,real) *MatProp(Ratio_between_unloading_slope_at_epscU_and_initial_slope_lambda,real) *MatProp(Tensile_strength_Ft,real) *MatProp(Tension_softening_stiffness_Ets,real)
*endif