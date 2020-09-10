namespace eval Fire {
	variable script
}

set ::ThermalUsedMaterialsList " "
proc Fire::SetActivateThermal { event args } {

	switch $event {

		SYNC {

			set GDN [lindex $args 0]
			set STRUCT [lindex $args 1]
			set QUESTION [lindex $args 2]
			
			set LocalName [lindex [split $STRUCT {,}] 1]
			set LocalNameTag [FindMaterialNumber $LocalName]
			set LocalTagExists [ThermalCheckUsedMaterials $LocalNameTag]
			set LocalNameTagExists 0
			
			set HostName [DWLocalGetValue $GDN $STRUCT $QUESTION]		
			set ActivateThermal [DWLocalGetValue $GDN $STRUCT Activate_Thermal]
			set ConcreteMaterials [Fire::CompatibleThermalConcreteMaterials $HostName]
			set SteelMaterials [Fire::CompatibleThermalSteelMaterials $HostName]
			set Sections [Fire::CompatibleThermalSections $HostName]
			set Elements [Fire::CompatibleThermalElements $HostName]
			
			if { $ConcreteMaterials!=-1 || $SteelMaterials!=-1 } {
			
				set FiberNameData [GiD_Info materials(Section_Force-Deformation)]
				set FiberNameNum [llength $FiberNameData]
				
				for {set i 0} {$i < $FiberNameNum} {incr i} {
				
					set FiberTag [FindMaterialNumber [lindex $FiberNameData $i]]
					set FiberLocalTag $FiberTag$LocalNameTag
					set FiberLocalTagExists [ThermalCheckUsedMaterials $FiberLocalTag]
					
					if {$FiberLocalTagExists!=-1} {
					
						set LocalNameTagExists 1
					
					}
				}
				
				if { $ActivateThermal } {
				
					if { $LocalTagExists==-1 } {
					
						set ok [ThermalAddUsedMaterials $LocalNameTag]
					
					}

				} else {

					if { $LocalNameTagExists==1 } {

						set ok [DWLocalSetValue $GDN $STRUCT Activate_Thermal 1]
						WarnWinText "Warning: Activate_Thermal cannot be unchecked in $LocalName: $HostName Material Type while it is being used in a Thermal Activated section"

					} else {
					
						if { $LocalTagExists!=-1 } {
					
							set ok [ThermalRemoveUsedMaterials $LocalNameTag]
							
						}
					
					}

				}
				
			} elseif { $Sections!=-1 } {

				set ElementNameData [GiD_Info materials(Beam-Column_Elements)]
				set ElementNameNum [llength $ElementNameData]
				
				for {set i 0} {$i < $ElementNameNum} {incr i} {
				
					set ElementTag [FindMaterialNumber [lindex $ElementNameData $i]]
					set ElementLocalTag $ElementTag$LocalNameTag
					set ElementLocalTagExists [ThermalCheckUsedMaterials $ElementLocalTag]
					
					if {$ElementLocalTagExists!=-1} {
					
						set LocalNameTagExists 1
					
					}
				}
				
				set MaterialNameData [GiD_Info materials(Uniaxial_Concrete_Materials)]
				append MaterialNameData " " [GiD_Info materials(Uniaxial_Steel_Materials)]
				set MaterialNameNum [llength $MaterialNameData]
				
				for {set i 0} {$i < $MaterialNameNum} {incr i} {
				
					set MaterialTag [FindMaterialNumber [lindex $MaterialNameData $i]]
					set MaterialTagExists [ThermalCheckUsedMaterials $LocalNameTag$MaterialTag]
					
					if {$MaterialTagExists!=-1} {
					
						set ok [ThermalRemoveUsedMaterials $LocalNameTag$MaterialTag]
					
					}
				}
						
				if { $HostName=="Fiber" } {

					set AssignedCrossSection [DWLocalGetValue $GDN $STRUCT Cross_section]

					if { $AssignedCrossSection!="Bridge_Deck"} {
						
						set AssignedCoreMaterial [DWLocalGetValue $GDN $STRUCT Core_material]
						set Material1 [FindMaterialNumber $AssignedCoreMaterial]
						set AssignedCoreMaterialTag $LocalNameTag$Material1
						
						set AssignedCoverMaterial [DWLocalGetValue $GDN $STRUCT Cover_material]
						set Material2 [FindMaterialNumber $AssignedCoverMaterial]
						set AssignedCoverMaterialTag $LocalNameTag$Material2
						
						set AssignedRBMaterial [DWLocalGetValue $GDN $STRUCT Reinforcing_bar_material]
						set Material3 [FindMaterialNumber $AssignedRBMaterial]
						set AssignedRBMaterialTag $LocalNameTag$Material3
						
						if { $ActivateThermal } {
						
							if { $LocalTagExists==-1 } {
							
								set ok [ThermalAddUsedMaterials $LocalNameTag]
							
							}
							
							set AssignedCoreMaterialExists [ThermalCheckUsedMaterials $AssignedCoreMaterialTag]
							set Material1Exists [ThermalCheckUsedMaterials $Material1]
							
							if { $AssignedCoreMaterialExists==-1 } {

								set ok [ThermalAddUsedMaterials $AssignedCoreMaterialTag]
								
							}
							
							if { $Material1Exists==-1 } {
							
								WarnWinText "Warning: Activate_Thermal is not activated in $AssignedCoreMaterial while it is activated in $LocalName : Fiber Section type.\n Activate_Thermal has been checked in corresponding $AssignedCoreMaterial material"
								GiD_AccessValue set materials "$AssignedCoreMaterial" "Activate_Thermal" 1
								set ok [ThermalAddUsedMaterials $Material1]
								
							}
								
							set AssignedCoverMaterialExists [ThermalCheckUsedMaterials $AssignedCoverMaterialTag]
							set Material2Exists [ThermalCheckUsedMaterials $Material2]
							
							if { $AssignedCoverMaterialExists==-1 } {

								set ok [ThermalAddUsedMaterials $AssignedCoverMaterialTag]

							}
							
							if { $Material2Exists==-1 } {
							
								WarnWinText "Warning: Activate_Thermal is not activated in $AssignedCoverMaterial while it is activated in $LocalName : Fiber Section type.\n Activate_Thermal has been checked in corresponding $AssignedCoverMaterial material"
								GiD_AccessValue set materials "$AssignedCoverMaterial" "Activate_Thermal" 1
								set ok [ThermalAddUsedMaterials $Material2]
								
							}	
								
							set AssignedRBMaterialExists [ThermalCheckUsedMaterials $AssignedRBMaterialTag]
							set Material3Exists [ThermalCheckUsedMaterials $Material3]
							
							if { $AssignedRBMaterialExists==-1 } {

								set ok [ThermalAddUsedMaterials $AssignedRBMaterialTag]							

							}
							
							if { $Material3Exists==-1 } {							
							
								WarnWinText "Warning: Activate_Thermal is not activated in $AssignedRBMaterial while it is activated in $LocalName : Fiber Section type.\n Activate_Thermal has been checked in corresponding $AssignedRBMaterial material"
								GiD_AccessValue set materials "$AssignedRBMaterial" "Activate_Thermal" 1							
								set ok [ThermalAddUsedMaterials $Material3]
								
							}
							
						} else {
						
							if { $LocalNameTagExists==1 } {

								set ok [DWLocalSetValue $GDN $STRUCT Activate_Thermal 1]
								WarnWinText "Warning: Activate_Thermal cannot be unchecked in $LocalName while it is being used in a Thermal Activated element "

							} else {
							
								if { $LocalTagExists!=-1 } {
							
									set ok [ThermalRemoveUsedMaterials $LocalNameTag]
								
								}
								
								set AssignedCoreMaterialExists [ThermalCheckUsedMaterials $AssignedCoreMaterialTag]					
								if { $AssignedCoreMaterialExists!=-1 } {		
								
									set ok [ThermalRemoveUsedMaterials $AssignedCorerMaterialTag]
									
								}
								
								set AssignedCoverMaterialExists [ThermalCheckUsedMaterials $AssignedCoverMaterialTag]					
								if { $AssignedCoverMaterialExists!=-1 } {
								
									set ok [ThermalRemoveUsedMaterials $AssignedCoverMaterialTag]
									
								}
								
								set AssignedRBMaterialExists [ThermalCheckUsedMaterials $AssignedRBMaterialTag]				
								if { $AssignedRBMaterialExists!=-1 } {
								
									set ok [ThermalRemoveUsedMaterials $AssignedRBMaterialTag]
									
								}

							}
						
						}
						
					} else {

						set Mainsectionmaterial [DWLocalGetValue $GDN $STRUCT Main_section_material]
						set Material4 [FindMaterialNumber $Mainsectionmaterial]
						set MainsectionmaterialTag $LocalNameTag$Material4
						
						set TopslabRBmaterial [DWLocalGetValue $GDN $STRUCT Top_slab_reinforcing_bar_material]
						set Material5 [FindMaterialNumber $TopslabRBmaterial]
						set TopslabRBmaterialTag $LocalNameTag$Material5
						
						set BottomslabRBmaterial [DWLocalGetValue $GDN $STRUCT Bottom_slab_reinforcing_bar_material]
						set Material6 [FindMaterialNumber $BottomslabRBmaterial]
						set BottomslabRBmaterialTag $LocalNameTag$Material6
						
						if { $ActivateThermal } {
						
							if { $LocalTagExists==-1 } {
							
								set ok [ThermalAddUsedMaterials $LocalNameTag]
							
							}
						
							set MainsectionmaterialExists [ThermalCheckUsedMaterials $MainsectionmaterialTag]
							set Material4Exists [ThermalCheckUsedMaterials $Material4]
							
							if { $MainsectionmaterialExists==-1 } {

								set ok [ThermalAddUsedMaterials $MainsectionmaterialTag]
													
							}
							
							if { $Material4Exists==-1 } {
							
								WarnWinText "Warning: Activate_Thermal is not activated in $Mainsectionmaterial while it is activated in $LocalName : Fiber Section type.\n Activate_Thermal has been checked in corresponding $Mainsectionmaterial material"
								GiD_AccessValue set materials "$Mainsectionmaterial" "Activate_Thermal" 1
								set ok [ThermalAddUsedMaterials $Material4]
							
							}

							set TopslabRBmaterialExists [ThermalCheckUsedMaterials $TopslabRBmaterialTag]
							set Material5Exists [ThermalCheckUsedMaterials $Material5]
							
							if { $TopslabRBmaterialExists==-1 } {

								set ok [ThermalAddUsedMaterials $TopslabRBmaterialTag]

							}
							
							if { $Material5Exists==-1 } {
							
								WarnWinText "Warning: Activate_Thermal is not activated in $TopslabRBmaterial while it is activated in $LocalName : Fiber Section type.\n Activate_Thermal has been checked in corresponding $TopslabRBmaterial material"
								GiD_AccessValue set materials "$TopslabRBmaterial" "Activate_Thermal" 1
								set ok [ThermalAddUsedMaterials $Material5]
								
							}

							set BottomslabRBmaterialExists [ThermalCheckUsedMaterials $BottomslabRBmaterialTag]
							set Material6Exists [ThermalCheckUsedMaterials $Material5]
							
							if { $BottomslabRBmaterialExists==-1 } {
			

								set ok [ThermalAddUsedMaterials $BottomslabRBmaterialTag]


							}
							
							if { $Material6Exists==-1 } {
							
								WarnWinText "Warning: Activate_Thermal is not activated in $BottomslabRBmaterial while it is activated in $LocalName : Fiber Section type.\n Activate_Thermal has been checked in corresponding $BottomslabRBmaterial material"
								GiD_AccessValue set materials "$BottomslabRBmaterial" "Activate_Thermal" 1
								set ok [ThermalAddUsedMaterials $Material6]
								
							}
								
							set AddPart [DWLocalGetValue $GDN $STRUCT Include_additional_part]
							set Material7 0
							set Material8 0
							set Material9 0

							if { $AddPart } {

								set AddPartMat [DWLocalGetValue $GDN $STRUCT Additional_part_material]
								set Material7 [FindMaterialNumber $AddPartMat]
								set AddPartMatTag $LocalNameTag$Material7
								
								set AddSlabRBmaterial [DWLocalGetValue $GDN $STRUCT Additional_slab_reinforcing_bar_material]
								set Material8 [FindMaterialNumber $AddSlabRBmaterial]
								set AddSlabRBmaterialTag $LocalNameTag$Material8
								
								set AddbeamRBmaterial [DWLocalGetValue $GDN $STRUCT Beam_reinforcing_bar_material]
								set Material9 [FindMaterialNumber $AddbeamRBmaterial]
								set AddbeamRBmaterialTag $LocalNameTag$Material9
								
								set AddPartMatExists [ThermalCheckUsedMaterials $AddPartMatTag]
								set Material7Exists [ThermalCheckUsedMaterials $Material7]
								
								if { $AddPartMatExists==-1 } {

									set ok [ThermalAddUsedMaterials $AddPartMatTag]

								}
								
								if { $Material7Exists==-1 } {
								
									WarnWinText "Warning: Activate_Thermal is not activated in $AddPartMat while it is activated in $LocalName : Fiber Section type.\n Activate_Thermal has been checked in corresponding $AddPartMat material"
									GiD_AccessValue set materials "$AddPartMat" "Activate_Thermal" 1															
									set ok [ThermalAddUsedMaterials $Material7]
								
								}
									
								set AddSlabRBmaterialExists [ThermalCheckUsedMaterials $AddSlabRBmaterialTag]
								set Material8Exists [ThermalCheckUsedMaterials $Material8]
								
								if { $AddSlabRBmaterialExists==-1 } {

									set ok [ThermalAddUsedMaterials $AddSlabRBmaterialTag]


								}
								
								if { $Material8Exists==-1 } {
								
									WarnWinText "Warning: Activate_Thermal is not activated in $AddSlabRBmaterial while it is activated in $LocalName : Fiber Section type.\n Activate_Thermal has been checked in corresponding $AddSlabRBmaterial material"
									GiD_AccessValue set materials "$AddSlabRBmaterial" "Activate_Thermal" 1							
									set ok [ThermalAddUsedMaterials $Material8]
									
								}
									
								set AddbeamRBmaterialExists [ThermalCheckUsedMaterials $AddbeamRBmaterialTag]
								set Material9Exists [ThermalCheckUsedMaterials $Material9]
								
								if { $AddbeamRBmaterialExists==-1 } {
								

									set ok [ThermalAddUsedMaterials $AddbeamRBmaterialTag]


								}
								
								if { $Material9Exists==-1 } {
								
									WarnWinText "Warning: Activate_Thermal is not activated in $AddbeamRBmaterial while it is activated in $LocalName : Fiber Section type.\n Activate_Thermal has been checked in corresponding $AddbeamRBmaterial material"
									GiD_AccessValue set materials "$AddbeamRBmaterial" "Activate_Thermal" 1							
									set ok [ThermalAddUsedMaterials $Material9]
									
								}
								
							} else {
							
								if { $Material7!=0&&$Material7!=$Material4&&$Material7!=$Material5&&$Material7!=$Material6 } {
									
									set AddPartMatTag $LocalNameTag$Material7
									set AddPartMatExists [ThermalCheckUsedMaterials $AddPartMatTag]
									if { $AddPartMatExists!=-1 } {						
									
										set ok [ThermalRemoveUsedMaterials $AddPartMatTag]
										
									}
								
								}
								
								if { $Material8!=0&&$Material8!=$Material4&&$Material8!=$Material5&&$Material8!=$Material6 } {
									
									set AddSlabRBmaterialTag $LocalNameTag$Material8
									set AddSlabRBmaterialExists [ThermalCheckUsedMaterials $AddSlabRBmaterialTag]
									if { $AddSlabRBmaterialExists!=-1 } {						
									
										set ok [ThermalRemoveUsedMaterials $AddSlabRBmaterialTag]
										
									}
								
								}
								
								if { $Material9!=0&&$Material9!=$Material4&&$Material9!=$Material5&&$Material9!=$Material6 } {
									
									set AddbeamRBmaterialTag $LocalNameTag$Material9
									set AddbeamRBmaterialExists [ThermalCheckUsedMaterials $AddbeamRBmaterialTag]
									if { $AddbeamRBmaterialExists!=-1 } {						

										set ok [ThermalRemoveUsedMaterials $AddbeamRBmaterialTag]
										
									}
								
								}
							
							}
							
						} else {
						
							if { $LocalNameTagExists==1 } {

								set ok [DWLocalSetValue $GDN $STRUCT Activate_Thermal 1]
								WarnWinText "Warning: Activate_Thermal cannot be unchecked in $LocalName while it is being used in a Thermal Activated element "
								
							} else {
							
								if { $LocalTagExists!=-1 } {
								
									set ok [ThermalRemoveUsedMaterials $LocalNameTag]
								
								}

								set MainsectionmaterialExists [ThermalCheckUsedMaterials $MainsectionmaterialTag]
								if { $MainsectionmaterialExists!=-1 } {	
								
									set ok [ThermalRemoveUsedMaterials $MainsectionmaterialTag]
									
								}
								
								set TopslabRBmaterialExists [ThermalCheckUsedMaterials $TopslabRBmaterialTag]
								if { $TopslabRBmaterialExists!=-1 } {
							
									set ok [ThermalRemoveUsedMaterials $TopslabRBmaterialTag]
									
								}
								
								set BottomslabRBmaterialExists [ThermalCheckUsedMaterials $BottomslabRBmaterialTag]
								if { $BottomslabRBmaterialExists!=-1 } {	
								
									set ok [ThermalRemoveUsedMaterials $BottomslabRBmaterialTag]	
									
								}
								
								if { $AddPart } {
								
									set AddPartMat [DWLocalGetValue $GDN $STRUCT Additional_part_material]
									set Material7 [FindMaterialNumber $AddPartMat]
									set AddPartMatTag $LocalNameTag$Material7
									
									set AddSlabRBmaterial [DWLocalGetValue $GDN $STRUCT Additional_slab_reinforcing_bar_material]
									set Material8 [FindMaterialNumber $AddSlabRBmaterial]
									set AddSlabRBmaterialTag $LocalNameTag$Material8
									
									set AddbeamRBmaterial [DWLocalGetValue $GDN $STRUCT Beam_reinforcing_bar_material]
									set Material9 [FindMaterialNumber $AddbeamRBmaterial]
									set AddbeamRBmaterialTag $LocalNameTag$Material9

									set AddPartMatExists [ThermalCheckUsedMaterials $AddPartMatTag]
									if { $AddPartMatExists!=-1 } {

										set ok [ThermalRemoveUsedMaterials $AddPartMatTag]
									
									}

									set AddSlabRBmaterialExists [ThermalCheckUsedMaterials $AddSlabRBmaterialTag]
									if { $AddSlabRBmaterialExists!=-1 } {

										set ok [ThermalRemoveUsedMaterials $AddSlabRBmaterialTag]
									
									}

									set AddbeamRBmaterialExists [ThermalCheckUsedMaterials $AddbeamRBmaterialTag]
									if { $AddbeamRBmaterialExists!=-1 } {
									
										set ok [ThermalRemoveUsedMaterials $AddbeamRBmaterialTag]
										
									}								
								
								}
							
							}
						
						}
						
					}

				} elseif { $HostName=="FiberBuiltUpSections" } {

					set AssignedSectionTypeMaterial [DWLocalGetValue $GDN $STRUCT Section_Type_Material:]
					set Material10 [FindMaterialNumber $AssignedSectionTypeMaterial]
					set AssignedSectionTypeMaterialTag $LocalNameTag$Material10
						
					if { $ActivateThermal } {
					
						if { $LocalTagExists==-1 } {
						
							set ok [ThermalAddUsedMaterials $LocalNameTag]
						
						}

						set AssignedSectionTypeMaterialExists [ThermalCheckUsedMaterials $AssignedSectionTypeMaterialTag]
						set Material10Exists [ThermalCheckUsedMaterials $Material10]
						
						if { $AssignedSectionTypeMaterialExists==-1 } {

							set ok [ThermalAddUsedMaterials $AssignedSectionTypeMaterialTag]

						}
						
						if { $Material10Exists==-1 } {
						
							WarnWinText "Warning: Activate_Thermal is not activated in $AssignedSectionTypeMaterial while it is activated in $LocalName : FiberBuiltUpSections type.\n Activate_Thermal has been checked in corresponding $AssignedSectionTypeMaterial material"
							GiD_AccessValue set materials "$AssignedSectionTypeMaterial" "Activate_Thermal" 1
							set ok [ThermalAddUsedMaterials $Material10]
							
						}
						
					} else {
					
						if { $LocalNameTagExists==1 } {
						
							set ok [DWLocalSetValue $GDN $STRUCT Activate_Thermal 1]
							WarnWinText "Warning: Activate_Thermal cannot be unchecked in $LocalName while it is being used in a Thermal Activated element "
							
						} else {
						
							if { $LocalTagExists!=-1 } {
							
								set ok [ThermalRemoveUsedMaterials $LocalNameTag]
							
							}
							
							set AssignedSectionTypeMaterialExists [ThermalCheckUsedMaterials $AssignedSectionTypeMaterialTag]
							if { $AssignedSectionTypeMaterialExists!=-1 } {
						
								set ok [ThermalRemoveUsedMaterials $AssignedSectionTypeMaterialTag]
								
							}

						}					
					
					}

				} elseif { $HostName=="FiberCustom" } {
				
					for {set i 1} {$i <= 10} {incr i} {

						append RegionName($i) "Region" "_" "$i" "_" "material:"
						set AssignedRegionMaterial($i) [DWLocalGetValue $GDN $STRUCT $RegionName($i)]
						set Material11($i) [FindMaterialNumber $AssignedRegionMaterial($i)]
						set AssignedRegionTag($i) $LocalNameTag$Material11($i)
						
					}
				
					if { $ActivateThermal } {
					
						if { $LocalTagExists==-1 } {
								
							set ok [ThermalAddUsedMaterials $LocalNameTag]
								
						}

						for {set i 1} {$i <= 10} {incr i} {

							set AssignedRegionMaterialExists [ThermalCheckUsedMaterials $AssignedRegionTag($i)]
							set Material11Exists [ThermalCheckUsedMaterials $Material11($i)]
							
							if { $AssignedRegionMaterialExists==-1 } {

								set ok [ThermalAddUsedMaterials $AssignedRegionTag($i)]

							}
							
							if { $Material11Exists==-1 } {
							
								WarnWinText "Warning: Activate_Thermal is not activated in $AssignedRegionMaterial($i) while it is activated in $LocalName : FiberCustom type.\n Activate_Thermal has been checked in corresponding $AssignedRegionMaterial($i) material"
								GiD_AccessValue set materials "$AssignedRegionMaterial($i)" "Activate_Thermal" 1
								set ok [ThermalAddUsedMaterials $Material11($i)]
							
							}
						}
						
					} else {
					
						if { $LocalNameTagExists==1 } {
						
							set ok [DWLocalSetValue $GDN $STRUCT Activate_Thermal 1]
							WarnWinText "Warning: Activate_Thermal cannot be unchecked in $LocalName while it is being used in a Thermal Activated element "

						} else {
						
							if { $LocalTagExists!=-1 } {
							
								set ok [ThermalRemoveUsedMaterials $LocalNameTag]
							
							}
						
							for {set i 1} {$i <= 10} {incr i} {

								set AssignedRegionMaterialExists [ThermalCheckUsedMaterials $AssignedRegionTag($i)]
								
								if { $AssignedRegionMaterialExists!=-1 } {
								
									set ok [ThermalRemoveUsedMaterials $AssignedRegionTag($i)]
									
								}
								
							}

						}					
					
					}

				}

			} elseif { $Elements!=-1 } {
			
				set FiberNameData [GiD_Info materials(Section_Force-Deformation)]
				set FiberNameNum [llength $FiberNameData]
				for {set i 0} {$i < $FiberNameNum} {incr i} {
				
					set FiberName [lindex $FiberNameData $i]
					set FiberNameTag $LocalNameTag[FindMaterialNumber $FiberName]
					set FiberNameTagExists [ThermalCheckUsedMaterials $FiberNameTag]
					
					if {$FiberNameTagExists!=-1} {
					
						set ok [ThermalRemoveUsedMaterials $FiberNameTag]
					
					}
				
				}
				
				set AssignedSection [DWLocalGetValue $GDN $STRUCT Section]
				set SectionTag [FindMaterialNumber $AssignedSection]
				set AssignedSectionTag $LocalNameTag$SectionTag
				set SectionHostName [GiD_AccessValue get materials $AssignedSection Thermal_Section:]
				
				if { $ActivateThermal } {

					set AssignedSectionExists [ThermalCheckUsedMaterials $AssignedSectionTag]
					set SectionTagExists [ThermalCheckUsedMaterials $SectionTag]
					
					if { $SectionTagExists==-1 } {
					
						WarnWinText "Warning: Activate_Thermal is not activated in $AssignedSection while it is activated in $LocalName : dispBeamColumn type.\n Activate_Thermal has been checked in corresponding $AssignedSection section"
						GiD_AccessValue set materials "$AssignedSection" "Activate_Thermal" 1
						set ok [ThermalAddUsedMaterials $SectionTag]
						
					}
						
					if { $AssignedSectionExists==-1 } {

						set ok [ThermalAddUsedMaterials $AssignedSectionTag]
						
						if { $SectionHostName=="Fiber" || $SectionHostName=="FiberBuiltUpSections" || $SectionHostName=="FiberCustom" } {

							if { $SectionHostName=="Fiber" } {

								set AssignedCrossSection [GiD_AccessValue get materials $AssignedSection Cross_section]

								if { $AssignedCrossSection!="Bridge_Deck"} {
									
									set AssignedCoreMaterial1 [GiD_AccessValue get materials $AssignedSection Core_material]
									set AssignedCoreMaterialType [GiD_AccessValue get materials $AssignedCoreMaterial1 Material:]
									if { $AssignedCoreMaterialType!="Concrete01" && $AssignedCoreMaterialType!="Concrete02" } {
									
										set AssignedCoreMaterial "Concrete01_(Zero_tensile_strength)"
										set ok [GiD_AccessValue set materials $AssignedSection Core_material $AssignedCoreMaterial]
										WarnWinText "Warning: Core_material in $AssignedSection has been changed to $AssignedCoreMaterial since $AssignedCoreMaterial1 is not a compatible Thermal material"
										
									} else {
									
										set AssignedCoreMaterial $AssignedCoreMaterial1
										
									}
									set Material1 [FindMaterialNumber $AssignedCoreMaterial]
									set AssignedCoreMaterialTag $SectionTag$Material1
									
									set AssignedCoverMaterial1 [GiD_AccessValue get materials $AssignedSection Cover_material]
									set AssignedCoverMaterialType [GiD_AccessValue get materials $AssignedCoverMaterial1 Material:]
									if { $AssignedCoverMaterialType!="Concrete01" && $AssignedCoverMaterialType!="Concrete02" } {
									
										set AssignedCoverMaterial "Concrete01_(Zero_tensile_strength)"
										set ok [GiD_AccessValue set materials $AssignedSection Cover_material $AssignedCoverMaterial]
										WarnWinText "Warning: Cover_material in $AssignedSection has been changed to $AssignedCoverMaterial since $AssignedCoverMaterial1 is not a compatible Thermal material"
										
									} else {
									
										set AssignedCoverMaterial $AssignedCoverMaterial1
										
									}			
									set Material2 [FindMaterialNumber $AssignedCoverMaterial]
									set AssignedCoverMaterialTag $SectionTag$Material2
									
									
									set AssignedRBMaterial1 [GiD_AccessValue get materials $AssignedSection Reinforcing_bar_material]
									set AssignedRBMaterialType [GiD_AccessValue get materials $AssignedRBMaterial1 Material:]
									if { $AssignedRBMaterialType!="Steel01" && $AssignedRBMaterialType!="Steel02" } {
									
										set AssignedRBMaterial "Steel01"
										set ok [GiD_AccessValue set materials $AssignedSection Reinforcing_bar_material $AssignedRBMaterial]
										WarnWinText "Warning: Reinforcing_bar_material in $AssignedSection has been changed to $AssignedRBMaterial since $AssignedRBMaterial1 is not a compatible Thermal material"
										
									} else {
									
										set AssignedRBMaterial $AssignedRBMaterial1
										
									}			
									set Material3 [FindMaterialNumber $AssignedRBMaterial]
									set AssignedRBMaterialTag $SectionTag$Material3
									
									set AssignedCoreMaterialExists [ThermalCheckUsedMaterials $AssignedCoreMaterialTag]
									set Material1Exists [ThermalCheckUsedMaterials $Material1]
									
									if { $AssignedCoreMaterialExists==-1 } {

										set ok [ThermalAddUsedMaterials $AssignedCoreMaterialTag]
										
									}
									
									if { $Material1Exists==-1 } {
									
										WarnWinText "Warning: Activate_Thermal is not activated in $AssignedCoreMaterial while it is activated in $AssignedSection : Fiber Section type.\n Activate_Thermal has been checked in corresponding $AssignedCoreMaterial material"
										GiD_AccessValue set materials "$AssignedCoreMaterial" "Activate_Thermal" 1
										set ok [ThermalAddUsedMaterials $Material1]
										
									}
										
									set AssignedCoverMaterialExists [ThermalCheckUsedMaterials $AssignedCoverMaterialTag]
									set Material2Exists [ThermalCheckUsedMaterials $Material2]
									
									if { $AssignedCoverMaterialExists==-1 } {

										set ok [ThermalAddUsedMaterials $AssignedCoverMaterialTag]

									}
									
									if { $Material2Exists==-1 } {
									
										WarnWinText "Warning: Activate_Thermal is not activated in $AssignedCoverMaterial while it is activated in $AssignedSection : Fiber Section type.\n Activate_Thermal has been checked in corresponding $AssignedCoverMaterial material"
										GiD_AccessValue set materials "$AssignedCoverMaterial" "Activate_Thermal" 1
										set ok [ThermalAddUsedMaterials $Material2]
										
									}	
										
									set AssignedRBMaterialExists [ThermalCheckUsedMaterials $AssignedRBMaterialTag]
									set Material3Exists [ThermalCheckUsedMaterials $Material3]
									
									if { $AssignedRBMaterialExists==-1 } {

										set ok [ThermalAddUsedMaterials $AssignedRBMaterialTag]							

									}
									
									if { $Material3Exists==-1 } {							
									
										WarnWinText "Warning: Activate_Thermal is not activated in $AssignedRBMaterial while it is activated in $AssignedSection : Fiber Section type.\n Activate_Thermal has been checked in corresponding $AssignedRBMaterial material"
										GiD_AccessValue set materials "$AssignedRBMaterial" "Activate_Thermal" 1							
										set ok [ThermalAddUsedMaterials $Material3]
										
									}
										
								} else {

									set Mainsectionmaterial1 [GiD_AccessValue get materials $AssignedSection Main_section_material]
									set MainsectionmaterialType [GiD_AccessValue get materials $Mainsectionmaterial1 Material:]
									if { $MainsectionmaterialType!="Concrete01" && $MainsectionmaterialType!="Concrete02" } {
									
										set Mainsectionmaterial "Concrete01_(Zero_tensile_strength)"
										set ok [GiD_AccessValue set materials $AssignedSection Main_section_material $Mainsectionmaterial]
										WarnWinText "Warning: Main_section_material in $AssignedSection has been changed to $Mainsectionmaterial since $Mainsectionmaterial1 is not a compatible Thermal material"
										
									} else {
									
										set Mainsectionmaterial $Mainsectionmaterial1
										
									}
									set Material4 [FindMaterialNumber $Mainsectionmaterial]
									set MainsectionmaterialTag $SectionTag$Material4
									
									set TopslabRBmaterial1 [GiD_AccessValue get materials $AssignedSection Top_slab_reinforcing_bar_material]
									set TopslabRBmaterialType [GiD_AccessValue get materials $TopslabRBmaterial1 Material:]
									if { $TopslabRBmaterialType!="Steel01" && $TopslabRBmaterialType!="Steel02" } {
									
										set TopslabRBmaterial "Steel01"
										set ok [GiD_AccessValue set materials $AssignedSection Top_slab_reinforcing_bar_material $TopslabRBmaterial]
										WarnWinText "Warning: Top_slab_reinforcing_bar_material in $AssignedSection has been changed to $TopslabRBmaterial since $TopslabRBmaterial1 is not a compatible Thermal material"
										
									} else {
									
										set TopslabRBmaterial $TopslabRBmaterial1
										
									}			
									set Material5 [FindMaterialNumber $TopslabRBmaterial]
									set TopslabRBmaterialTag $SectionTag$Material5
									
									set BottomslabRBmaterial1 [GiD_AccessValue get materials $AssignedSection Bottom_slab_reinforcing_bar_material]
									set BottomslabRBmaterialType [GiD_AccessValue get materials $BottomslabRBmaterial1 Material:]
									if { $BottomslabRBmaterialType!="Steel01" && $BottomslabRBmaterialType!="Steel02" } {
									
										set BottomslabRBmaterial "Steel01"
										set ok [GiD_AccessValue set materials $AssignedSection Bottom_slab_reinforcing_bar_material $BottomslabRBmaterial]
										WarnWinText "Warning: Bottom_slab_reinforcing_bar_material in $AssignedSection has been changed to $BottomslabRBmaterial since $BottomslabRBmaterial1 is not a compatible Thermal material"
										
									} else {
									
										set BottomslabRBmaterial $BottomslabRBmaterial1
										
									}
									set Material6 [FindMaterialNumber $BottomslabRBmaterial]
									set BottomslabRBmaterialTag $SectionTag$Material6
									
									set MainsectionmaterialExists [ThermalCheckUsedMaterials $MainsectionmaterialTag]
									set Material4Exists [ThermalCheckUsedMaterials $Material4]
									
									if { $MainsectionmaterialExists==-1 } {

										set ok [ThermalAddUsedMaterials $MainsectionmaterialTag]
															
									}
									
									if { $Material4Exists==-1 } {
									
										WarnWinText "Warning: Activate_Thermal is not activated in $Mainsectionmaterial while it is activated in $AssignedSection : Fiber Section type.\n Activate_Thermal has been checked in corresponding $Mainsectionmaterial material"
										GiD_AccessValue set materials "$Mainsectionmaterial" "Activate_Thermal" 1
										set ok [ThermalAddUsedMaterials $Material4]
									
									}

									set TopslabRBmaterialExists [ThermalCheckUsedMaterials $TopslabRBmaterialTag]
									set Material5Exists [ThermalCheckUsedMaterials $Material5]
									
									if { $TopslabRBmaterialExists==-1 } {

										set ok [ThermalAddUsedMaterials $TopslabRBmaterialTag]

									}
									
									if { $Material5Exists==-1 } {
									
										WarnWinText "Warning: Activate_Thermal is not activated in $TopslabRBmaterial while it is activated in $AssignedSection : Fiber Section type.\n Activate_Thermal has been checked in corresponding $TopslabRBmaterial material"
										GiD_AccessValue set materials "$TopslabRBmaterial" "Activate_Thermal" 1
										set ok [ThermalAddUsedMaterials $Material5]
										
									}

									set BottomslabRBmaterialExists [ThermalCheckUsedMaterials $BottomslabRBmaterialTag]
									set Material6Exists [ThermalCheckUsedMaterials $Material5]
									
									if { $BottomslabRBmaterialExists==-1 } {
					

										set ok [ThermalAddUsedMaterials $BottomslabRBmaterialTag]


									}
									
									if { $Material6Exists==-1 } {
									
										WarnWinText "Warning: Activate_Thermal is not activated in $BottomslabRBmaterial while it is activated in $AssignedSection : Fiber Section type.\n Activate_Thermal has been checked in corresponding $BottomslabRBmaterial material"
										GiD_AccessValue set materials "$BottomslabRBmaterial" "Activate_Thermal" 1
										set ok [ThermalAddUsedMaterials $Material6]
										
									}
									
									set AddPart [GiD_AccessValue get materials $AssignedSection Include_additional_part]
									set Material7 0
									set Material8 0
									set Material9 0

									if { $AddPart } {

										set AddPartMat1 [GiD_AccessValue get materials $AssignedSection Additional_part_material]
										set AddPartMatType [GiD_AccessValue get materials $AddPartMat1 Material:]
										if { $AddPartMatType!="Concrete01" && $AddPartMatType!="Concrete02" } {
										
											set AddPartMat "Concrete01_(Zero_tensile_strength)"
											set ok [GiD_AccessValue set materials $AssignedSection Additional_part_material $AddPartMat]
											WarnWinText "Warning: Additional_part_material in $AssignedSection has been changed to $AddPartMat since $AddPartMat1 is not a compatible Thermal material"
											
										} else {
										
											set AddPartMat $AddPartMat1
											
										}					
										set Material7 [FindMaterialNumber $AddPartMat]
										set AddPartMatTag $SectionTag$Material7
										
										set AddSlabRBmaterial1 [GiD_AccessValue get materials $AssignedSection Additional_slab_reinforcing_bar_material]
										set AddSlabRBmaterialType [GiD_AccessValue get materials $AddSlabRBmaterial1 Material:]
										if { $AddSlabRBmaterialType!="Steel01" && $AddSlabRBmaterialType!="Steel02" } {
										
											set AddSlabRBmaterial "Steel01"
											set ok [GiD_AccessValue set materials $AssignedSection Additional_slab_reinforcing_bar_material $AddSlabRBmaterial]
											WarnWinText "Warning: Additional_slab_reinforcing_bar_material in $AssignedSection has been changed to $AddSlabRBmaterial since $AddSlabRBmaterial1 is not a compatible Thermal material"
											
										} else {
										
											set AddSlabRBmaterial $AddSlabRBmaterial1
											
										}					
										set Material8 [FindMaterialNumber $AddSlabRBmaterial]
										set AddSlabRBmaterialTag $SectionTag$Material8
										
										set AddbeamRBmaterial1 [GiD_AccessValue get materials $AssignedSection Beam_reinforcing_bar_material]
										set AddbeamRBmaterialType [GiD_AccessValue get materials $AddbeamRBmaterial1 Material:]
										if { $AddbeamRBmaterialType!="Steel01" && $AddbeamRBmaterialType!="Steel02" } {
										
											set AddbeamRBmaterial "Steel01"
											set ok [GiD_AccessValue set materials $AssignedSection Beam_reinforcing_bar_material $AddbeamRBmaterial]
											WarnWinText "Warning: Beam_reinforcing_bar_material in $AssignedSection has been changed to $AddbeamRBmaterial since $AddbeamRBmaterial1 is not a compatible Thermal material"
											
										} else {
										
											set AddbeamRBmaterial $AddbeamRBmaterial1
											
										}					
										set Material9 [FindMaterialNumber $AddbeamRBmaterial]
										set AddbeamRBmaterialTag $SectionTag$Material9
										
										set AddPartMatExists [ThermalCheckUsedMaterials $AddPartMatTag]
										set Material7Exists [ThermalCheckUsedMaterials $Material7]
										
										if { $AddPartMatExists==-1 } {

											set ok [ThermalAddUsedMaterials $AddPartMatTag]

										}
										
										if { $Material7Exists==-1 } {
										
											WarnWinText "Warning: Activate_Thermal is not activated in $AddPartMat while it is activated in $AssignedSection : Fiber Section type.\n Activate_Thermal has been checked in corresponding $AddPartMat material"
											GiD_AccessValue set materials "$AddPartMat" "Activate_Thermal" 1															
											set ok [ThermalAddUsedMaterials $Material7]
										
										}
											
										set AddSlabRBmaterialExists [ThermalCheckUsedMaterials $AddSlabRBmaterialTag]
										set Material8Exists [ThermalCheckUsedMaterials $Material8]
										
										if { $AddSlabRBmaterialExists==-1 } {

											set ok [ThermalAddUsedMaterials $AddSlabRBmaterialTag]


										}
										
										if { $Material8Exists==-1 } {
										
											WarnWinText "Warning: Activate_Thermal is not activated in $AddSlabRBmaterial while it is activated in $AssignedSection : Fiber Section type.\n Activate_Thermal has been checked in corresponding $AddSlabRBmaterial material"
											GiD_AccessValue set materials "$AddSlabRBmaterial" "Activate_Thermal" 1							
											set ok [ThermalAddUsedMaterials $Material8]
											
										}
											
										set AddbeamRBmaterialExists [ThermalCheckUsedMaterials $AddbeamRBmaterialTag]
										set Material9Exists [ThermalCheckUsedMaterials $Material9]
										
										if { $AddbeamRBmaterialExists==-1 } {
										

											set ok [ThermalAddUsedMaterials $AddbeamRBmaterialTag]


										}
										
										if { $Material9Exists==-1 } {
										
											WarnWinText "Warning: Activate_Thermal is not activated in $AddbeamRBmaterial while it is activated in $AssignedSection : Fiber Section type.\n Activate_Thermal has been checked in corresponding $AddbeamRBmaterial material"
											GiD_AccessValue set materials "$AddbeamRBmaterial" "Activate_Thermal" 1							
											set ok [ThermalAddUsedMaterials $Material9]
											
										}

									}
									
								}

							} elseif { $SectionHostName=="FiberBuiltUpSections" } {
							
								set AssignedSectionTypeMaterial1 [GiD_AccessValue get materials $AssignedSection Section_Type_Material:]
								set AssignedSectionTypeMaterialType [GiD_AccessValue get materials $AssignedSectionTypeMaterial1 Material:]
								if { $AssignedSectionTypeMaterialType!="Steel01" && $AssignedSectionTypeMaterialType!="Steel02" } {
								
									set AssignedSectionTypeMaterial "Steel01"
									set ok [GiD_AccessValue set materials $AssignedSection Section_Type_Material: $AssignedSectionTypeMaterial]
									WarnWinText "Warning: Section_Type_Material: in $AssignedSection has been changed to $AssignedSectionTypeMaterial since $AssignedSectionTypeMaterial1 is not a compatible Thermal material"
									
								} else {
								
									set AssignedSectionTypeMaterial $AssignedSectionTypeMaterial1
									
								}	
								
								set Material10 [FindMaterialNumber $AssignedSectionTypeMaterial]
								set AssignedSectionTypeMaterialTag $SectionTag$Material10
								set AssignedSectionTypeMaterialExists [ThermalCheckUsedMaterials $AssignedSectionTypeMaterialTag]
								set Material10Exists [ThermalCheckUsedMaterials $Material10]
								
								if { $AssignedSectionTypeMaterialExists==-1 } {


									set ok [ThermalAddUsedMaterials $AssignedSectionTypeMaterialTag]

								}
								
								if { $Material10Exists==-1 } {
								
									WarnWinText "Warning: Activate_Thermal is not activated in $AssignedSectionTypeMaterial while it is activated in $AssignedSection : FiberBuiltUpSections type.\n Activate_Thermal has been checked in corresponding $AssignedSectionTypeMaterial material"
									GiD_AccessValue set materials "$AssignedSectionTypeMaterial" "Activate_Thermal" 1
									set ok [ThermalAddUsedMaterials $Material10]
									
								}

							} elseif { $SectionHostName=="FiberCustom" } {
							
								for {set i 1} {$i <= 10} {incr i} {

									append RegionName($i) "Region" "_" "$i" "_" "material:"
									set AssignedRegionMaterial1($i) [GiD_AccessValue get materials $AssignedSection $RegionName($i)]
									set AssignedRegionMaterialType($i) [GiD_AccessValue get materials $AssignedRegionMaterial1($i) Material:]
									if { $AssignedRegionMaterialType($i)!="Steel01" && $AssignedRegionMaterialType($i)!="Steel02" && $AssignedRegionMaterialType($i)!="Concrete01" && $AssignedRegionMaterialType($i)!="Concrete02" } {
									
										set AssignedRegionMaterial($i) "Steel01"
										set ok [GiD_AccessValue set materials $AssignedSection $RegionName($i) $AssignedRegionMaterial($i)]
										WarnWinText "Warning: $RegionName($i) in $AssignedSection has been changed to $AssignedRegionMaterial($i) since $AssignedRegionMaterial1($i) is not a compatible Thermal material"
										
									} else {
									
										set AssignedRegionMaterial($i) $AssignedRegionMaterial1($i)
										
									}
									
									set Material11($i) [FindMaterialNumber $AssignedRegionMaterial($i)]
									set AssignedRegionTag($i) $SectionTag$Material11($i)
									
								}

								for {set i 1} {$i <= 10} {incr i} {

									set AssignedRegionMaterialExists [ThermalCheckUsedMaterials $AssignedRegionTag($i)]
									set Material11Exists [ThermalCheckUsedMaterials $Material11($i)]
									
									if { $AssignedRegionMaterialExists==-1 } {

										set ok [ThermalAddUsedMaterials $AssignedRegionTag($i)]

									}
									
									if { $Material11Exists==-1 } {
									
										WarnWinText "Warning: Activate_Thermal is not activated in $AssignedRegionMaterial($i) while it is activated in $AssignedSection : FiberCustom type.\n Activate_Thermal has been checked in corresponding $AssignedRegionMaterial($i) material"
										GiD_AccessValue set materials "$AssignedRegionMaterial($i)" "Activate_Thermal" 1
										set ok [ThermalAddUsedMaterials $Material11($i)]
									
									}

								}

							}

						}
					}

				} else {

					set AssignedSectionExists [ThermalCheckUsedMaterials $AssignedSectionTag]
					if { $AssignedSectionExists!=-1 } {		
					
						set ok [ThermalRemoveUsedMaterials $AssignedSectionTag]
					
					}
					
				}

			}

		}

	}

	return ""

}

proc Fire::SetThermalLoadType { event args } {

	switch $event {

		SYNC {

			lassign $args GDN STRUCT QUESTION	
			set LocalName [lindex [split $STRUCT {,}] 1]

			# WarnWinText "GDN: $GDN"
			# WarnWinText "STRUCT: $STRUCT"
			# WarnWinText "QUESTION: $QUESTION"
			# WarnWinText "LocalName: $LocalName"
			
			if {$LocalName=="Line_Thermal"} {
			
				set LocalValue [DWLocalGetValue $GDN $STRUCT $QUESTION]
				set DataType [GiD_AccessValue get materials $LocalValue Data_Type:]
				# WarnWinText "DataType: $DataType"
				
				if { $DataType=="Time_Independant" } {
					
					set Analysistype [GiD_AccessValue get intvdata Analysis_type]
					
					if { $Analysistype!="Static" } {
					
						set ok [GiD_AccessValue set intvdata Analysis_type "Static"]
						WarnWinText "Warning: Since Thermal load is Applied and Temperature Data Type is Time Independant - Data in corresponding interval has been changed as follows\n Analysis type - Static"
						
					}
					
				} elseif { $DataType=="Time_Dependant" } {
				
					set Analysistype [GiD_AccessValue get intvdata Analysis_type]
					
					if { $Analysistype!="Transient" } {
					
						set ok [GiD_AccessValue set intvdata Analysis_type "Transient"]
						WarnWinText "Warning: Since Thermal load is Applied and Temperature Data Type is Time Dependant - Data in corresponding interval has been changed as follows\n Analysis type - Transient"
						
						set DataPoints [GiD_AccessValue get materials $LocalValue Number_of_data_points:]
						set DataTime [GiD_AccessValue get materials $LocalValue ___]
						set DataTime [lreplace $DataTime 0 0]
						set DataTime [lreplace $DataTime 0 0]
						set DataTime [lindex $DataTime end-$DataPoints]
						set AnalysisdurationUnit [GiD_AccessValue get intvdata Analysis_duration]
						set temp [GidConvertValueUnit $AnalysisdurationUnit]
						set temp [ParserNumberUnit $temp Analysisduration AnalysisUnit]
						
						if { $Analysisduration!=$DataTime } {
						
							set ok [GiD_AccessValue set intvdata Analysis_duration $DataTime$AnalysisUnit]
							set ok [GiD_AccessValue set intvdata Analysis_time_Step [ expr $DataTime/10.0]$AnalysisUnit]
						
						}
						
					}
					
				}

				set Solutionalgorithm [GiD_AccessValue get intvdata Solution_algorithm]
				set Loadingtype [GiD_AccessValue get intvdata Loading_type]	
				
				if { $Solutionalgorithm!="Linear" } {
				
					set ok [GiD_AccessValue set intvdata Solution_algorithm "Full_Newton-Raphson"]
					WarnWinText "Warning: Since Thermal load is Applied - Data in corresponding interval has been changed as follows\n Solution algorithm - Full Newton-Raphson"
					
				}
				
				if { $Loadingtype!="Thermal" } {
				
					set ok [GiD_AccessValue set intvdata Loading_type "Thermal"]						
					WarnWinText "Warning: Since Thermal load is Applied - Data in corresponding interval has been changed as follows\n Loading type - Thermal"
				
				}
				
			}
			
		}
	
	}

	return ""

}

proc Fire::SetScript { MaterialName table } {

	variable script
	lappend script($MaterialName) $table
	return 0
	
}

proc Fire::SaveScriptFile { MaterialName Nrows Ncolumns } {

	variable script

	set data [GiD_Info Project]
	set ProjectName [lindex $data 1]

	OpenSees::SetProjectNameAndPath
	set GiDProjectDir [OpenSees::GetProjectPath]
	set script($MaterialName) [string trim $script($MaterialName)]
	
	# WarnWinText "data: $data"				
	# WarnWinText "ProjectName: $ProjectName"
	
	if { $ProjectName != "UNNAMED" } {

		set filename [Fire::GetScriptName $MaterialName]
		set folderpath [file join $GiDProjectDir FireData]
		set filepath [file join $GiDProjectDir FireData $filename]
		
		# WarnWinText "filename: $filename"				
		# WarnWinText "folderpath: $folderpath"
		# WarnWinText "filepath: $filepath"
	
		set fexists [file exists $filepath]
		set folderexists [file exists $folderpath]

		if {!$folderexists} {

			file mkdir [file join $GiDProjectDir FireData]
		}

		if {$script($MaterialName) != ""} {

			cd "$GiDProjectDir/FireData"
			set fp [open $filepath w]			
			for {set i 0} {$i < $Nrows} {incr i} {
				
				puts $fp [lrange $script($MaterialName) [expr $i*$Ncolumns] [expr ($i+1)*$Ncolumns-1]]
				
			}
			close $fp

		} else {
		# empty textbox
			if {$fexists} {

				file delete -force $filepath

			}
		}
	}
	set script($MaterialName) ""

	return 0
}

proc Fire::GetScriptName { MaterialName } {


	set filename [string map {" " "_"} $MaterialName]
	append filename ".dat"

	return $filename
}

proc Fire::ThermalLoadData { LoadTag args } {

	variable script
	set script($LoadTag) ""
	set script($LoadTag) [lappend $script($LoadTag) $args]
	set script($LoadTag) [regsub -all {\{|\}} $script($LoadTag) ""]
	return 0
}

proc Fire::GetThermalLoadData { LoadTag } {
	
	variable script
	return $script($LoadTag)

}

proc Fire::CompatibleThermalConcreteMaterials { Material } {

	set CompatibleThermalConcreteMaterials " \
	Concrete01 \
	Concrete02 \
	"

	set MaterialCompatibility [lsearch $CompatibleThermalConcreteMaterials $Material]
	
	return $MaterialCompatibility
}

proc Fire::CompatibleThermalSteelMaterials { Material } {

	set CompatibleThermalSteelMaterials " \
	Steel01 \
	Steel02 \
	"

	set MaterialCompatibility [lsearch $CompatibleThermalSteelMaterials $Material]
	
	return $MaterialCompatibility
}

proc Fire::CompatibleThermalSections { Section } {

	set CompatibleThermalSections " \
	Fiber \
	FiberBuiltUpSections \
	FiberCustom \
	"

	set SectionCompatibility [lsearch $CompatibleThermalSections $Section]
	
	return $SectionCompatibility
	
}

proc Fire::CompatibleThermalElements { Element } {

	set CompatibleThermalElements " \
	dispBeamColumn \
	ShellDKGQ \
	Shell \
	"

	set ElementCompatibility [lsearch $CompatibleThermalElements $Element]
	
	return $ElementCompatibility
	
}

proc Fire::ActivateThermalcheck { MaterialName MaterialActiveThermal ElementType ElementNumber} {


	set Material [Fire::CompatibleThermalConcreteMaterials $MaterialName]
	if { $Material==-1 } {
	
		set Material [Fire::CompatibleThermalSteelMaterials $MaterialName]
	
	}
	set Section [Fire::CompatibleThermalSections $MaterialName]
	set AssignedElement [Fire::CompatibleThermalElements $ElementType]
	set error 0

	if { $MaterialActiveThermal==1 } {

		if { $Material!=-1 && $AssignedElement==-1 } {

			WarnWinText "one of the $MaterialName material type was checked with ActivateThermal and assidned $ElementType with Element Tag $ElementNumber is not a compatible thermal element."
			set error 1
			
		} elseif { $Section!=-1 && $AssignedElement==-1 } {

			WarnWinText "one of the $MaterialName section type was checked with ActivateThermal and assidned $ElementType with Element Tag $ElementNumber is not a compatible thermal element."
			set error 1
		
		}

	}
	return $error

}