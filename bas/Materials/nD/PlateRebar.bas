*#
*# define CDPMaterial for concrete
*#
*set var PlaneStressUserMaterialTag=PlaneStressUserMaterialTag+1
*set var fc=MatProp(Concrete_compressive_strength,real)
*set var fct=MatProp(Concrete_tensile_strength,real)
*set var epsc0=MatProp(Concrete_strain_at_compr_strength,real)
*set var Ec=operation(1.5*fc/epsc0)
*set var n=MatProp(Compressive_cracking_energy_multiplier_n,real)
*set var m=MatProp(Tensile_cracking_energy_multiplier_m,real)
*set var gc=operation((fc/Ec)*(n-1)*fc/2)
*set var gt=operation((fct/Ec)*(m-1)*fct/2)
*#
#nDMaterial  CDPPlaneStressThermal matTag Ec  v  ft  fc  gt  gc
*format "%6d%6g%6g%6g%6g%6g"
nDMaterial CDPPlaneStressThermal   *PlaneStressUserMaterialTag *Ec 0.2 *fct *fc *gt *gc
*# define PlateFromPlaneStress material
*set var PlateFromPlaneStressMaterialTag=PlateFromPlaneStressMaterialTag+1
*format "%6d%6d%10g"
nDMaterial PlateFromPlaneStressThermal *PlateFromPlaneStressMaterialTag *PlaneStressUserMaterialTag *MatProp(Cover_G,real)