*if(strcmp(MatProp(Type),"EC3-Structural")==0)
*set var typeTag=3
*elseif(strcmp(MatProp(Type),"EC2-Hot-Rolled")==0)
*set var typeTag=21
*else
*set var typeTag=22
*endif
*set var PlateFromPlaneStressMaterialTag=PlateFromPlaneStressMaterialTag+1
*format "%d%d%g%g%g%g%g%g"
#nDMaterial J2PlaneStressThermal $matTag $typeTag $E0 $Poisson_ratio $fy $fyu $H1 $H2;
nDMaterial J2PlaneStressThermal *PlateFromPlaneStressMaterialTag *typeTag *MatProp(Young_Modulus,real) *MatProp(Poisson_ratio,real) *MatProp(Yield_stress,real) *MatProp(Ultimate_stress,real) *MatProp(Kinematic_hardening_parameter_delta,real) *MatProp(Isotropic_hardening_parameter,real)
*set var G=operation(MatProp(Young_Modulus,real)/(2*(1+MatProp(Poisson_ratio,real))))
*format "%6d%6d%10g"
nDMaterial PlateFromPlaneStressThermal *MaterialID *PlateFromPlaneStressMaterialTag *G