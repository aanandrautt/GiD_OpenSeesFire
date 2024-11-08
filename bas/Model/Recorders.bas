
# --------------------------------------------------------------------------------------------------------------
# R E C O R D E R S
# --------------------------------------------------------------------------------------------------------------

*# Check if transient analysis is taking place, for recording nodal velocities and accelerations
*set var Transient_analysis=0
*loop intervals
*if(strcmp(IntvData(Analysis_type),"Transient")==0)
*set var Transient_analysis=1
*break
*endif
*end intervals
*#
*# Nodes
*#
*if(ndime==2)
*if(GenData(Nodal_displacements,int)==1)
recorder Node -file Node_displacements.out -time -nodeRange 1 *cntNodes -dof 1 2 disp
*endif
*if(GenData(Nodal_rotations,int)==1)
recorder Node -file Node_rotations.out -time -nodeRange 1 *cntNodes -dof 3 disp
*endif
*if(GenData(Nodal_reactions,int)==1)
recorder Node -file Node_forceReactions.out -time -nodeRange 1 *cntNodes -dof 1 2 reaction
recorder Node -file Node_momentReactions.out -time -nodeRange 1 *cntNodes -dof 3 reaction
*endif
*if(Transient_analysis==1)
*if(GenData(Nodal_accelerations,int)==1)
recorder Node -file Node_accelerations.out -time -nodeRange 1 *cntNodes -dof 1 2 accel
*endif
*if(GenData(Nodal_rotational_accelerations,int)==1)
recorder Node -file Node_rotAccelerations.out -time -nodeRange 1 *cntNodes -dof 3 accel
*endif
*if(GenData(Nodal_velocities,int)==1)
recorder Node -file Node_velocities.out -time -nodeRange 1 *cntNodes -dof 1 2 vel
*endif
*if(GenData(Nodal_rotational_velocities,int)==1)
recorder Node -file Node_rotVelocities.out -time -nodeRange 1 *cntNodes -dof 3 vel
*endif
*endif
*# 3D
*else
*if(GenData(Nodal_displacements,int)==1)
*if(GenData(Muli-case_fire_exposure,int)==0)
recorder Node -file Node_displacements.out -time -nodeRange 1 *cntNodes -dof 1 2 3 disp
*else
recorder Node -file "../Records/cases/$case/Results/Node_displacements.out" -time -nodeRange 1 *cntNodes -dof 1 2 3 disp
*endif
*endif
*if(GenData(Nodal_rotations,int)==1)
*if(GenData(Muli-case_fire_exposure,int)==0)
recorder Node -file Node_rotations.out -time -nodeRange 1 *cntNodes -dof 4 5 6 disp
*else
recorder Node -file "../Records/cases/$case/Results/Node_rotations.out" -time -nodeRange 1 *cntNodes -dof 4 5 6 disp
*endif
*endif
*if(GenData(Nodal_reactions,int)==1)
*if(GenData(Muli-case_fire_exposure,int)==0)
recorder Node -file Node_forceReactions.out -time -nodeRange 1 *cntNodes -dof 1 2 3 reaction
recorder Node -file Node_momentReactions.out -time -nodeRange 1 *cntNodes -dof 4 5 6 reaction
*else
recorder Node -file "../Records/cases/$case/Results/Node_forceReactions.out" -time -nodeRange 1 *cntNodes -dof 1 2 3 reaction
recorder Node -file "../Records/cases/$case/Results/Node_momentReactions.out" -time -nodeRange 1 *cntNodes -dof 4 5 6 reaction
*endif
*endif
*if(Transient_analysis==1)
*if(GenData(Nodal_accelerations,int)==1)
recorder Node -file Node_accelerations.out -time -nodeRange 1 *cntNodes -dof 1 2 3 accel
*endif
*if(GenData(Nodal_rotational_accelerations,int)==1)
recorder Node -file Node_rotAccelerations.out -time -nodeRange 1 *cntNodes -dof 4 5 6 accel
*endif
*if(GenData(Nodal_velocities,int)==1)
recorder Node -file Node_velocities.out -time -nodeRange 1 *cntNodes -dof 1 2 3 vel
*if(GenData(Nodal_rotational_velocities,int)==1)
recorder Node -file Node_rotVelocities.out -time -nodeRange 1 *cntNodes -dof 4 5 6 vel
*endif
*endif
*endif
*endif
*#
*# Brick
*#
*if(cntStdBrick!=0)
*set var FirstBrickElemNumber=0
*set var LastBrickElemNumber=0
*loop elems
*if(ElemsType==5)
*set var FirstBrickElemNumber=ElemsNum
*break
*endif
*end elems
*loop elems
*if(ElemsType==5)
*set var LastBrickElemNumber=ElemsNum
*endif
*end elems
*if(GenData(_Forces,int)==1)
recorder Element -file stdBrick_force.out -time -eleRange *FirstBrickElemNumber *LastBrickElemNumber forces
*endif
*if(GenData(_Stresses,int)==1)
recorder Element -file stdBrick_stress.out -time -eleRange *FirstBrickElemNumber *LastBrickElemNumber stresses
*endif
*if(GenData(_Strains,int)==1)
recorder Element -file stdBrick_strain.out -time -eleRange *FirstBrickElemNumber *LastBrickElemNumber strains
*endif
*endif
*#
*# ShellMITC4
*#
*if(cntShell!=0)
*if(GenData(Forces,int)==1)
*if(GenData(Muli-case_fire_exposure,int)==0)
recorder Element -file ShellMITC4_force.out -time -ele *\
*else
recorder Element -file "../Records/cases/$case/Results/ShellMITC4_force.out" -time -ele *\
*endif
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"Shell")==0)
*ElemsNum *\
*endif
*end elems
forces
*endif
*if(GenData(Stresses,int)==1)
*if(GenData(Muli-case_fire_exposure,int)==0)
recorder Element -file ShellMITC4_stress.out -time -ele *\
*else
recorder Element -file "../Records/cases/$case/Results/ShellMITC4_stress.out" -time -ele *\
*endif
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"Shell")==0)
*ElemsNum *\
*endif
*end elems
stresses
*endif
*if(GenData(Strains,int)==1)
*if(GenData(Muli-case_fire_exposure,int)==0)
recorder Element -file ShellMITC4_strain.out -time -ele *\
*else
recorder Element -file "../Records/cases/$case/Results/ShellMITC4_strain.out" -time -ele *\
*endif
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"Shell")==0)
*ElemsNum *\
*endif
*end elems
strains
*endif
*endif
*#
*# ShellDKGQ
*#
*if(cntShellDKGQ!=0)
*if(GenData(Forces,int)==1)
*if(GenData(Muli-case_fire_exposure,int)==0)
recorder Element -file ShellDKGQ_force.out -time -ele *\
*else
recorder Element -file "../Records/cases/$case/Results/ShellDKGQ_force.out" -time -ele *\
*endif
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"ShellDKGQ")==0)
*ElemsNum *\
*endif
*end elems
forces
*endif
*if(GenData(Stresses,int)==1)
*if(GenData(Muli-case_fire_exposure,int)==0)
recorder Element -file ShellDKGQ_stress.out -time -ele *\
*else
recorder Element -file "../Records/cases/$case/Results/ShellDKGQ_stress.out" -time -ele *\
*endif
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"ShellDKGQ")==0)
*ElemsNum *\
*endif
*end elems
stresses
*endif
*if(GenData(Strains,int)==1)
*if(GenData(Muli-case_fire_exposure,int)==0)
recorder Element -file ShellDKGQ_strain.out -time -ele *\
*else
recorder Element -file "../Records/cases/$case/Results/ShellDKGQ_strain.out" -time -ele *\
*endif
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"ShellDKGQ")==0)
*ElemsNum *\
*endif
*end elems
strains
*endif
*endif
*#
*# Quad
*#
*if(cntQuad!=0)
*if(GenData(Forces,int)==1)
recorder Element -file Quad_force.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"Quad")==0)
*ElemsNum *\
*endif
*end elems
forces
*endif
*if(GenData(Stresses,int)==1)
*# s11 s22 s12
recorder Element -file Quad_stress.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"Quad")==0)
*ElemsNum *\
*endif
*end elems
stresses
*endif
*if(GenData(Strains,int)==1)
*# e11 e22 e12
recorder Element -file Quad_strain.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"Quad")==0)
*ElemsNum *\
*endif
*end elems
strains
*endif
*endif
*#
*# QuadUP
*#
*if(cntQuadUP!=0)
*if(GenData(Stresses,int)==1)
*# s11 s22 s33 s12
recorder Element -file QuadUP_stress1.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"QuadUP")==0)
*ElemsNum *\
*endif
*end elems
material 1 stress
recorder Element -file QuadUP_stress2.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"QuadUP")==0)
*ElemsNum *\
*endif
*end elems
material 2 stress
recorder Element -file QuadUP_stress3.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"QuadUP")==0)
*ElemsNum *\
*endif
*end elems
material 3 stress
recorder Element -file QuadUP_stress4.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"QuadUP")==0)
*ElemsNum *\
*endif
*end elems
material 4 stress
*endif
*if(GenData(Strains,int)==1)
*# e11 e22 g12
recorder Element -file QuadUP_strain1.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"QuadUP")==0)
*ElemsNum *\
*endif
*end elems
material 1 strain
recorder Element -file QuadUP_strain2.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"QuadUP")==0)
*ElemsNum *\
*endif
*end elems
material 2 strain
recorder Element -file QuadUP_strain3.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"QuadUP")==0)
*ElemsNum *\
*endif
*end elems
material 3 strain
recorder Element -file QuadUP_strain4.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"QuadUP")==0)
*ElemsNum *\
*endif
*end elems
material 4 strain
*endif
*endif
*#
*# Tri
*#
*if(cntTri31!=0)
*if(GenData(Forces,int)==1)
recorder Element -file Tri31_force.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"Tri31")==0)
*ElemsNum *\
*endif
*end elems
forces
*endif
*if(GenData(Stresses,int)==1)
recorder Element -file Tri31_stress.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"Tri31")==0)
*ElemsNum *\
*endif
*end elems
stresses
*endif
*endif
*#
*# Elastic beam-column
*#
*if(cntEBC!=0)
*if(GenData(Local_forces,int)==1)
recorder Element -file ElasticBeamColumn_localForce.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"ElasticBeamColumn")==0)
*ElemsNum *\
*endif
*end elems
localForce
*endif
*endif
*#
*# Elastic Timoshenko beam-column
*#
*if(cntETB!=0)
*if(GenData(Local_forces,int)==1)
recorder Element -file ElasticTimoshenkoBeamColumn_localForce.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"ElasticTimoshenkoBeamColumn")==0)
*ElemsNum *\
*endif
*end elems
localForce
*endif
*endif
*#
*# Force beam-column
*#
*if(cntFBC!=0)
*if(GenData(Local_forces,int)==1)
recorder Element -file ForceBeamColumn_localForce.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"forceBeamColumn")==0)
*ElemsNum *\
*endif
*end elems
localForce
*endif
*if(GenData(Basic_deformation,int)==1)
recorder Element -file ForceBeamColumn_basicDeformation.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"forceBeamColumn")==0)
*ElemsNum *\
*endif
*end elems
basicDeformation
*endif
*if(GenData(Plastic_deformation,int)==1)
recorder Element -file ForceBeamColumn_plasticDeformation.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"forceBeamColumn")==0)
*ElemsNum *\
*endif
*end elems
plasticDeformation
*endif
*endif
*#
*# Displacement beam-column
*#
*if(cntDBC!=0)
*if(GenData(Local_forces,int)==1)
*if(GenData(Muli-case_fire_exposure,int)==0)
recorder Element -file DispBeamColumn_localForce.out -time -ele *\
*else
recorder Element -file "../Records/cases/$case/Results/DispBeamColumn_localForce.out" -time -ele *\
*endif
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"dispBeamColumn")==0)
*ElemsNum *\
*endif
*end elems
localForce
*endif
*if(GenData(Basic_deformation,int)==1)
*if(GenData(Muli-case_fire_exposure,int)==0)
recorder Element -file DispBeamColumn_basicDeformation.out -time -ele *\
*else
recorder Element -file "../Records/cases/$case/Results/DispBeamColumn_basicDeformation.out" -time -ele *\
*endif
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"dispBeamColumn")==0)
*ElemsNum *\
*endif
*end elems
basicDeformation
*endif
*if(GenData(Plastic_deformation,int)==1)
*if(GenData(Muli-case_fire_exposure,int)==0)
recorder Element -file DispBeamColumn_plasticDeformation.out -time -ele *\
*else
recorder Element -file "../Records/cases/$case/Results/DispBeamColumn_plasticDeformation.out" -time -ele *\
*endif
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"dispBeamColumn")==0)
*ElemsNum *\
*endif
*end elems
plasticDeformation
*endif
*endif
*#
*# Flexure-Shear Interaction Displacement beam-column
*#
*if(cntDBCI!=0)
*if(GenData(Local_forces,int)==1)
*if(GenData(Muli-case_fire_exposure,int)==0)
recorder Element -file DispBeamColumnInt_localForce.out -time -ele *\
*else
recorder Element -file "../Records/cases/$case/Results/DispBeamColumnInt_localForce.out" -time -ele *\
*endif
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"dispBeamColumnInt")==0)
*ElemsNum *\
*endif
*end elems
localForce
*endif
*endif
*#
*# Truss
*#
*if(cntTruss!=0)
*if(GenData(Axial_force,int)==1)
recorder Element -file Truss_axialForce.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"Truss")==0)
*ElemsNum *\
*endif
*end elems
axialForce
*endif
*if(GenData(Axial_deformation,int)==1)
recorder Element -file Truss_deformations.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"Truss")==0)
*ElemsNum *\
*endif
*end elems
deformations
*endif
*endif
*#
*# Corotational truss
*#
*if(cntCorotTruss!=0)
*if(GenData(Axial_force,int)==1)
recorder Element -file CorotTruss_axialForce.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"CorotationalTruss")==0)
*ElemsNum *\
*endif
*end elems
axialForce
*endif
*if(GenData(Axial_deformation,int)==1)
recorder Element -file CorotTruss_deformations.out -time -ele *\
*loop elems
*if(strcmp(ElemsMatProp(Element_type:),"CorotationalTruss")==0)
*ElemsNum *\
*endif
*end elems
deformations
*endif
*endif
*#
*# User recorders
*#
*set var FileExists=tcl(UserRecorder::RecorderFileExists)
*if(FileExists==1)

source "../Scripts/Recorders.tcl"; # user recorders
*endif
*#
*# Layer output
*#
*#
*# Both MITC4 and NLDKGQ
*#
*if(cntShell!=0 || cntShellDKGQ!=0)
set quad_elems "*tcl(Recorders::GetQuadElems)"
*set var layer = GenData(layer_A,int)
*if(layer >0)
*if(GenData(layer_A_is_steel,int)==0)
*if(GenData(Stresses_in_layer_A,int)==1)
#layer_A: *GenData(layer_A_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_A,int)==1)
#layer_A: *GenData(layer_A_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_A,int)==1)
#layer_A: *GenData(layer_A_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_temp_damage_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*else
*if(GenData(Stresses_in_layer_A,int)==1)
#layer_A: *GenData(layer_A_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_A,int)==1)
#layer_A: *GenData(layer_A_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_A,int)==1)
#layer_A: *GenData(layer_A_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_temp_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*endif
*endif
*set var layer = GenData(layer_B,int)
*if(layer >0)
*if(GenData(layer_B_is_steel,int)==0)
*if(GenData(Stresses_in_layer_B,int)==1)
#layer_B: *GenData(layer_B_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_B,int)==1)
#layer_B: *GenData(layer_B_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_B,int)==1)
#layer_B: *GenData(layer_B_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_temp_damage_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*else
*if(GenData(Stresses_in_layer_B,int)==1)
#layer_B: *GenData(layer_B_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_B,int)==1)
#layer_B: *GenData(layer_B_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_B,int)==1)
#layer_B: *GenData(layer_B_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_temp_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*endif
*endif
*set var layer = GenData(layer_C,int)
*if(layer >0)
*if(GenData(layer_C_is_steel,int)==0)
*if(GenData(Stresses_in_layer_C,int)==1)
#layer_C: *GenData(layer_C_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_C,int)==1)
#layer_C: *GenData(layer_C_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_C,int)==1)
#layer_C: *GenData(layer_C_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_temp_damage_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*else
*if(GenData(Stresses_in_layer_C,int)==1)
#layer_C: *GenData(layer_C_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_C,int)==1)
#layer_C: *GenData(layer_C_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_C,int)==1)
#layer_C: *GenData(layer_C_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_temp_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*endif
*endif
*set var layer = GenData(layer_D,int)
*if(layer >0)
*if(GenData(layer_D_is_steel,int)==0)
*if(GenData(Stresses_in_layer_D,int)==1)
#layer_D: *GenData(layer_D_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_D,int)==1)
#layer_D: *GenData(layer_D_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_D,int)==1)
#layer_D: *GenData(layer_D_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_temp_damage_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*else
*if(GenData(Stresses_in_layer_D,int)==1)
#layer_D: *GenData(layer_D_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_D,int)==1)
#layer_D: *GenData(layer_D_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_D,int)==1)
#layer_D: *GenData(layer_D_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_temp_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*endif
*endif
*set var layer = GenData(layer_E,int)
*if(layer >0)
*if(GenData(layer_E_is_steel,int)==0)
*if(GenData(Stresses_in_layer_E,int)==1)
#layer_E: *GenData(layer_E_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_E,int)==1)
#layer_E: *GenData(layer_E_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_E,int)==1)
#layer_E: *GenData(layer_E_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_temp_damage_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*else
*if(GenData(Stresses_in_layer_E,int)==1)
#layer_E: *GenData(layer_E_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_E,int)==1)
#layer_E: *GenData(layer_E_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_E,int)==1)
#layer_E: *GenData(layer_E_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_temp_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*endif
*endif
*set var layer = GenData(layer_F,int)
*if(layer >0)
*if(GenData(layer_F_is_steel,int)==0)
*if(GenData(Stresses_in_layer_F,int)==1)
#layer_F: *GenData(layer_F_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_F,int)==1)
#layer_F: *GenData(layer_F_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_F,int)==1)
#layer_F: *GenData(layer_F_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_temp_damage_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*else
*if(GenData(Stresses_in_layer_F,int)==1)
#layer_F: *GenData(layer_F_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_F,int)==1)
#layer_F: *GenData(layer_F_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_F,int)==1)
#layer_F: *GenData(layer_F_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_temp_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*endif
*endif
*set var layer = GenData(layer_G,int)
*if(layer >0)
*if(GenData(layer_G_is_steel,int)==0)
*if(GenData(Stresses_in_layer_G,int)==1)
#layer_G: *GenData(layer_G_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_G,int)==1)
#layer_G: *GenData(layer_G_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_G,int)==1)
#layer_G: *GenData(layer_G_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_temp_damage_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*else
*if(GenData(Stresses_in_layer_G,int)==1)
#layer_G: *GenData(layer_G_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_G,int)==1)
#layer_G: *GenData(layer_G_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_G,int)==1)
#layer_G: *GenData(layer_G_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_temp_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*endif
*endif
*set var layer = GenData(layer_H,int)
*if(layer >0)
*if(GenData(layer_H_is_steel,int)==0)
*if(GenData(Stresses_in_layer_H,int)==1)
#layer_H: *GenData(layer_H_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_H,int)==1)
#layer_H: *GenData(layer_H_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_H,int)==1)
#layer_H: *GenData(layer_H_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_temp_damage_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*else
*if(GenData(Stresses_in_layer_H,int)==1)
#layer_H: *GenData(layer_H_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_H,int)==1)
#layer_H: *GenData(layer_H_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_H,int)==1)
#layer_H: *GenData(layer_H_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_temp_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*endif
*endif
*set var layer = GenData(layer_I,int)
*if(layer >0)
*if(GenData(layer_I_is_steel,int)==0)
*if(GenData(Stresses_in_layer_I,int)==1)
#layer_I: *GenData(layer_I_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_I,int)==1)
#layer_I: *GenData(layer_I_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_I,int)==1)
#layer_I: *GenData(layer_I_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_temp_damage_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*else
*if(GenData(Stresses_in_layer_I,int)==1)
#layer_I: *GenData(layer_I_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_I,int)==1)
#layer_I: *GenData(layer_I_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_I,int)==1)
#layer_I: *GenData(layer_I_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_temp_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*endif
*endif
*set var layer = GenData(layer_J,int)
*if(layer >0)
*if(GenData(layer_J_is_steel,int)==0)
*if(GenData(Stresses_in_layer_J,int)==1)
#layer_J: *GenData(layer_J_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_J,int)==1)
#layer_J: *GenData(layer_J_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_J,int)==1)
#layer_J: *GenData(layer_J_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_temp_damage_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*else
*if(GenData(Stresses_in_layer_J,int)==1)
#layer_J: *GenData(layer_J_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_stress_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer stress
*endfor
*endif
*if(GenData(Strains_in_layer_J,int)==1)
#layer_J: *GenData(layer_J_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_strain_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer strain
*endfor
*endif
*if(GenData(Temp_damage_in_layer_J,int)==1)
#layer_J: *GenData(layer_J_name)
*for(i=1;i<=4;i=i+1)
recorder Element -file *GenData(Shell_element_type)_steel_temp_Layer*layer_GP*i.out -time -ele {*tcl(Recorders::ReturnStar)}$quad_elems material *i fiber *layer TempAndElong
*endfor
*endif
*endif
*endif
*endif
