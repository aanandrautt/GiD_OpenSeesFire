namespace eval Fire {
	variable condition_ID 1
	variable composite_ID 1
	variable constraint_ID 10000
}
proc Fire::ResetIDs { } {
	set Fire::condition_ID 1
	set Fire::composite_ID 1
	set Fire::constraint_ID 10000
}
proc GiD_Event_BeforeMeshGeneration { element_size } {
	WarnWinText ".....Starting pre-meshing commands.....\n\n"
	Fire::ResetIDs
	set current_interval [lindex [GiD_Info intvdata num] 0]
	set num_of_intervals [lindex [GiD_Info intvdata num] 1]
	WarnWinText "Current interval is: $current_interval"
	for {set interval 1} {$interval <= $num_of_intervals} {incr interval} {
		GiD_IntervalData set $interval
		WarnWinText "Changed interval to $interval"
		WarnWinText "\n-----Interval: $interval-----"
		Fire::AssignConditionIds
		WarnWinText "\n-----Interval: $interval-----"
		Fire::AssignSurfaceCompositeSectionCond
		WarnWinText "\n-----Interval: $interval-----"
		Fire::PairCompositeSections fire 0.00001 0.5
		Fire::PairCompositeSections ambient 0.00001 0.5
		WarnWinText "\n-----Ran all functions in interval: $interval-----"
	}
	GiD_IntervalData set $current_interval
	WarnWinText "Returned to original interval: $current_interval"
	WarnWinText "\n\n.....Finished all pre-meshing commands.....\n\n"
}
proc GiD_Event_AfterMeshGeneration { fail } { 	
	PostMeshing $fail
}
# proc AfterMeshGeneration is the legacy name of the post meshing function

proc PostMeshing { fail } {
	if {!$fail} {
		set pairs ""
		WarnWinText ".....Starting post-meshing commands.....\n\n"
		set current_interval [lindex [GiD_Info intvdata num] 0]
		set num_of_intervals [lindex [GiD_Info intvdata num] 1]
		WarnWinText "Current interval is: $current_interval"
		for {set interval 1} {$interval <= $num_of_intervals} {incr interval} {
			GiD_IntervalData set $interval
			WarnWinText "Changed interval to $interval"
			WarnWinText "\n-----Interval: $interval-----"
			append pairs [MeshRepair::MatchMesh] 
			Fire::AssignCompositeConnection ambient 0.00001
			WarnWinText "\n-----Interval: $interval-----"
			Fire::AssignCentralElementFlag
			WarnWinText "constraint ID = [expr $Fire::constraint_ID - 1]\ncondition ID = [expr $Fire::condition_ID - 1]\ncomposite ID = [expr $Fire::composite_ID - 1]                                         "
			WarnWinText "\n-----Ran all functions in interval: $interval-----"
		}
		GiD_IntervalData set 1
		W "\n-----Interval: 1-----"
		W "Assigning nodal masses corresponding to quad element if Automass is turned on in Gen. data."
		Dynamics::AutoMass
		W "Finished assigning mass information to nodes."
		GiD_IntervalData set $current_interval
		WarnWinText "Returned to original interval: $current_interval"
		W "\nCreating geometric transforms."
		Transform::PopulateTagsArray
		W "\nFinished creating transforms and populting the corresponding array.\n"
		MeshRepair::ReassignMeshDivisions $pairs
		W "\nFinished reassigning mesh divisions to beam-column elements.\n"
		WarnWinText "\n\n.....Finished all post-meshing commands....."
	}
}
# should be performed BEFORE meshing
# goes over the geometry-assigned conditions and iteratively gives them ID numbers.
# It does so by taking the condition arguments, changing the ID number based on 
# a counter, and then assigning the condition back with the modified ID. Since
# each condition cannot be repeated, the newly assigned condition overrides the 
# currently assigned condition. It also assigns the geometry parent number.
# This should always be the first function to call before any meshing or the like
# because it establishes the condition ID which is the backbone of the entire 
# framework here, and is performed purely over the geometry. 
proc Fire::AssignConditionIds {} {
	# variable condition_ID
	WarnWinText "\n------------------------------------------"
	WarnWinText "Entering function Fire::AssignConditionIds"
	WarnWinText "------------------------------------------\n"
	set condition_name "Line_Gas_Temperatures Surface_Gas_Temperatures Line_Composite_Section_Slab Line_Composite_Section_Slab_AMBIENT"
		foreach cond $condition_name {
		        set geometric_entity_list [GiD_Info Conditions $cond geometry]
		        foreach geometric_entity $geometric_entity_list {
		                set geometric_entity_id [lindex $geometric_entity 1]
		                
		                set condition_args [lrange $geometric_entity 3 end]
		                set condition_args [lreplace $condition_args 0 0 $geometric_entity_id]
						if {$cond == "Line_Composite_Section_Slab_AMBIENT"} {
							set condition_args [lreplace $condition_args 1 1 $Fire::composite_ID]
							GiD_AssignData condition $cond lines $condition_args $geometric_entity_id
							set Fire::composite_ID [expr $Fire::composite_ID + 1]
						} else {
							set condition_args [lreplace $condition_args 1 1 $Fire::condition_ID]
							if {$cond == "Surface_Gas_Temperatures"} {
								GiD_AssignData condition $cond surfaces $condition_args $geometric_entity_id
							} else {
								GiD_AssignData condition $cond lines $condition_args $geometric_entity_id
							}
							set Fire::condition_ID [expr $Fire::condition_ID + 1]
						}
		        }
		}
}

proc Fire::GetConditionID { cond elem_id } {
	
	return [lindex [GiD_Info Conditions $cond mesh $elem_id] 5]
} 

# Assigns the composite section surface condition to surfaces attached to the line with
# with the condition Line_Composite_Section_Slab, which is the leader condition in this
# automatic composite section framework in GiD. This means that the surfaces attached to
# the line will inherit the condition ID number. 
# Another very important thing this function does is get the width, thickness, and protection
# information from the surface's material, and then assigns this to the leader condition. This 
# means that the orignal arguments of the leader line are overridden BEFORE then being assigned
# to the surface which virtually takes the exact same condition arguments. This procedure is 
# only performed over geometry and NOT over mesh. 
# This should be the second procedure to call, and just after the ID assignment. This is because 
# it gives the leader line the section information it needs, which we want to propagate throughout
# to the follower lines.
proc Fire::AssignSurfaceCompositeSectionCond {} {
	WarnWinText "\n----------------------------------------------------------"
	WarnWinText "Entering function: Fire::AssignSurfaceCompositeSectionCond"
	WarnWinText "----------------------------------------------------------\n"
	set condition_name "Line_Composite_Section_Slab"
	set line_list [GiD_Info Conditions $condition_name geometry]
	array unset line_id_list

	foreach line_instance $line_list {
		set id [lindex $line_instance 1]
		set args [lrange $line_instance 3 end]
		set line_id_list($id) $args
	}

	set surf_condition_name "Surface_Composite_Section"
	set material_list [GiD_Info material]
	GiD_UnAssignData condition $surf_condition_name surfaces all

	foreach line_id [array names line_id_list] {
		# set associated_surf_ids [GetLineHigherEntities $line_id]
		set associated_surf_ids [GidUtils::GetEntityHigherEntities line $line_id] 
		set width 0
		foreach surf $associated_surf_ids {
		        set xyz_surf [GidUtils::GetEntityCenter surface $surf]
		        set xyz_line [GidUtils::GetEntityCenter line $line_id]
		        set distance_vect [math::linearalgebra::sub_vect  $xyz_line  $xyz_surf]
		        set distance [expr 2*[math::linearalgebra::norm_two $distance_vect]]
		        set width [expr $width + $distance]
		}
		set width "$width [GiD_Units get model_unit_length]"
		
		set info [GiD_Info list_entities surface $associated_surf_ids]
		set element_type_index [lsearch $info "material:"]
		set element_type_num [lindex $info [expr $element_type_index +1]]
		set element_type_name [lindex [.central.s info materials] [expr $element_type_num-1]]
		set element_type_info [GiD_Info materials $element_type_name]
		
		set section_type_num [lsearch $element_type_info "Type#MAT#(Section_Force-Deformation,User_Materials)"]
		set section_type_name [lindex $element_type_info  [expr $section_type_num+1]]
		set section_type_info [GiD_Info materials $section_type_name]

		set slab_thickness_index [lsearch $section_type_info "Slab_thickness#UNITS#"]
		set slab_thickness [lindex $section_type_info [expr $slab_thickness_index + 1]]
		
		set slab_protection_index [lsearch $section_type_info "protection_thickness#UNITS#"]
		set slab_protection_thickness [lindex $section_type_info [expr $slab_protection_index + 1]]
		
		set slab_protection_mat_index [lsearch $section_type_info "protection_material#CB#(1,2,3)"]
		set slab_protection_mat [lindex $section_type_info [expr $slab_protection_mat_index + 1]]
		set line_id_list($line_id) [lreplace $line_id_list($line_id) end-3 end $width $slab_thickness $slab_protection_thickness $slab_protection_mat]
		
		GiD_AssignData condition $condition_name lines $line_id_list($line_id)  $line_id
		GiD_AssignData condition $surf_condition_name surfaces $line_id_list($line_id)  $associated_surf_ids

	}
}

# With both the ID numbers and slab section properties being assigned to the composite section
# leader condition in the last two procedures, it is time to propagate the information from
# the leader condition lines to the follower lines. This is important because we want the follower
# lines to inherit the ID number as well as the section data to make pairing up nodes easier 
# by allowing us to only look up the nodes of the paired lines each time (paired based on condition
# ID number) rather than try and find the distance between each node and all other nodes. 
# This command MUST be flexible, however, as it is not only used for the composite section 
# condition used for fire, but also for the ambient condition that only pairs up nodes and does
# not need to propagate slab information. Hence, this procedure takes a 'state' which can either 
# be 'fire' or 'ambient', as well as tolerances for xy and z. xy tolerances should be very small
# as it is there to account for precision errors (we want xy and to coincide), while z should be
# significantly bigger as it is there to prevent lines at different floors from coupling with each
# other while still allowing slabs and beams offset from each other to interact. 
# This command also takes place only over the geometry and so must be called before meshing.
proc Fire::PairCompositeSections { state xytolerance ztolerance } {
	WarnWinText "\n------------------------------------------------------------------------"
	WarnWinText "Entering function Fire::PairCompositeSections given state: $state"
	WarnWinText "The tolerance for the combined xy directions is given as: $xytolerance"	
	WarnWinText "The tolerance for the z direction is given as: $ztolerance"
	WarnWinText "------------------------------------------------------------------------\n"
	if {$state == "fire"} {
		set leader_condition_name "Line_Composite_Section_Slab"
		set follower_condition_name "Line_Composite_Section_Beam"
	} elseif {$state == "ambient"} {
		set leader_condition_name "Line_Composite_Section_Slab_AMBIENT"
		set follower_condition_name "Line_Composite_Section_Beam_AMBIENT"
	} else {
		WarnWinText "ERROR: Unknown state used for Fire:PairCompositeSections.\n can be either 'fire' or 'ambient'."
		return -1
	}   

	set line_list [GiD_Info Conditions $leader_condition_name geometry]
	set num_of_leader_lines [llength $line_list]
	array unset leader_line_data_list
	foreach line_instance $line_list {
		set line_id [lindex $line_instance 1]
		set composite_id [lindex $line_instance 4]
		set pts_xyz [OS_Geom::GetPointCoords $line_id]
		set xyz_i [lrange $pts_xyz 0 2]
		set xyz_f [lrange $pts_xyz 3 5]
			
		if {$state == "fire"} {
			set slab_props [lrange $line_instance end-3 end]
		} elseif {$state == "ambient"} {
			set slab_props $state
		}
		lappend leader_line_data_list($line_id) $composite_id $slab_props $xyz_i $xyz_f
	}
	
	set line_list [GiD_Info Conditions $follower_condition_name geometry]
	set num_of_follower_lines [llength $line_list]
	array unset follower_line_data_list
	foreach line_instance $line_list {
		set line_id [lindex $line_instance 1]
		# set composite_id [lindex $line_instance 4]
		set args [lrange $line_instance 3 end]
		set pts_xyz [OS_Geom::GetPointCoords $line_id]
		set xyz_i [lrange $pts_xyz 0 2]
		set xyz_f [lrange $pts_xyz 3 5]
		lappend follower_line_data_list($line_id) $args $xyz_i $xyz_f
	}
	
	set line_pairs ""
	
	foreach leader_line [array names leader_line_data_list] {
		# where 'f' means endpoint, and 'i' is the begining point of a line.
		set xyz_i_leader [lindex $leader_line_data_list($leader_line) 2]
		set xyz_f_leader [lindex $leader_line_data_list($leader_line) 3]
		
		foreach follower_line [array names follower_line_data_list] {
			# assuming that the first and last points of both follower and leader
			# lines coincide and both extend in the same direction ('i' and 'f'
			# points coincide) so we find the difference between 'i' of each line 
			# and 'f' of each line.
			set xyz_i_follower [lindex $follower_line_data_list($follower_line) 1]
			set xyz_f_follower [lindex $follower_line_data_list($follower_line) 2]
			set distance_i_i [math::linearalgebra::sub_vect  $xyz_i_follower  $xyz_i_leader]
			set distance_f_f [math::linearalgebra::sub_vect  $xyz_f_follower  $xyz_f_leader]
			set delta_x_i [lindex $distance_i_i 0]
			set delta_y_i [lindex $distance_i_i 1]
			set delta_z_i [lindex $distance_i_i 2]
			set delta_x_f [lindex $distance_f_f 0]
			set delta_y_f [lindex $distance_f_f 1] 
			set delta_z_f [lindex $distance_f_f 2] 
			set err [expr abs($delta_x_i)  + abs($delta_y_i) + abs($delta_x_f)  + abs($delta_y_f)]
			# if the summation of the difference in x and y exceeds a given tolerance, then this
			# means that either: these two lines are not a pair, or that the two lines extend in 
			# opposite directions. Assuming the latter, we will find the difference between the 
			# 'i' and 'f' points of each line, and 'f' and 'i' of each line.
			if {$err > $xytolerance} {
				set distance_i_f [math::linearalgebra::sub_vect  $xyz_i_follower  $xyz_f_leader]
				set distance_f_i [math::linearalgebra::sub_vect  $xyz_f_follower  $xyz_i_leader]
				set delta_x_i [lindex $distance_i_f 0]
				set delta_y_i [lindex $distance_i_f 1]
				set delta_z_i [lindex $distance_i_f 2]
				set delta_x_f [lindex $distance_f_i 0]
				set delta_y_f [lindex $distance_f_i 1] 
				set delta_z_f [lindex $distance_f_i 2]
				set err [expr abs($delta_x_i)  + abs($delta_y_i) + abs($delta_x_f)  + abs($delta_y_f)]
			}
			set z_err [expr abs($delta_z_i) + abs($delta_z_f)]
			# if the error is still large, or if the z difference is over a present tolerance then 
			# this can only mean that the two lines are NOT a pair so we do nothing for now. 
			if {$err < $xytolerance && $z_err < $ztolerance} {
				# if the error and z difference is less than the tolerance then the two lines are
				# a pair and will be added to the list of pairs.
				lappend line_pairs "$leader_line $follower_line"
			}  		
		}
	}
	WarnWinText "There are $num_of_leader_lines leader lines, $num_of_follower_lines follower lines, and [llength $line_pairs] line pairs."
	foreach pair $line_pairs {
		set leader_line [lindex $pair 0]
		set follower_line [lindex $pair 1]
		
		set ID [lindex $leader_line_data_list($leader_line) 0]
		set follower_args [lindex $follower_line_data_list($follower_line) 0]
		# replace the geometric parent and the ID of the follower line with the
		# approporiate values.
		set follower_args [lreplace $follower_args 0 1 $follower_line $ID]
		if {$state == "fire"} {
			set slab_properties [lindex $leader_line_data_list($leader_line) 1]
			set follower_args [lreplace $follower_args end-3 end {*}$slab_properties]
		} else {
		}
		GiD_AssignData condition $follower_condition_name lines $follower_args $follower_line
	}
}

proc Fire::GenerateThermoCouples {} {
	array unset thermocouple_data
	set condition_name "Line_Gas_Temperatures Surface_Gas_Temperatures Line_Composite_Section_Slab"
	foreach cond $condition_name {
		set geometric_entity_list [GiD_Info Conditions $cond geometry]
		foreach geometric_entity $geometric_entity_list {
			set geometric_entity_id [lindex $geometric_entity 1]
			set condition_id [lindex $geometric_entity 4]
			set xyz ""
			if {$cond == "Surface_Gas_Temperatures"} {
				set xyz [GidUtils::GetEntityCenter surface $geometric_entity_id]
			} else {
				set xyz [GidUtils::GetEntityCenter line $geometric_entity_id]
			}
			set thermocouple_data($condition_id) $xyz
		}
	}
	set sorted_thermocouple_data_keys [lsort -integer [array names thermocouple_data]]
	set fileHandle [open "[OpenSees::GetProjectPath]/Records/TCouples.txt" w+]
	foreach key $sorted_thermocouple_data_keys {
		set xyz $thermocouple_data($key)
		set x [lindex $xyz 0]; set y [lindex $xyz 1]; set z [lindex $xyz 2];
		puts $fileHandle "&DEVC ID = '$key', QUANTITY='TEMPERATURE', XYZ=$x,$y,$z/"
	}
	close $fileHandle
}

proc GetLineHigherEntities { line_ID } {
	set line_info_list [split [GiD_Info list_entities -more line $line_ID] \n]
	set higher_entity_list [lindex  $line_info_list [expr [llength $line_info_list] - 3]]
	return [lrange $higher_entity_list 3 end]
}
proc Fire::GetLineEndPoints { line_ID } {
	set line_data [GiD_Geometry get line $line_ID]
	return [lrange $line_data 2 3]
} 

proc Fire::GetCompositeSectionSurface { cond_id over} {
	set surf_condition_name "Surface_Composite_Section"
	set result " "
	set surfaces_list [GiD_Info Conditions $surf_condition_name $over]
	foreach surface $surfaces_list {
		set current_id [lindex $surface 4]
		if {$cond_id == $current_id} {
		        lappend result [lindex $surface 1]
		}
	}
	return $result
}

# The following command assumes that all conditions have been assigned an ID number, all information 
# was propagated successfully from leader to follower conditions by being paired up. This function 
# operates upon the mesh and thus expects to be called only after the mesh has been created. Similar
# to the function Fire::PairCompositeSections, this function takes a state ('fire' or 'ambient') as well
# as a tolerance for xy. Since this function is only called after the various conditions/geometric 
# entities have been paired up, it does not need to check for difference in z as that has already been
# performed.  
#
proc Fire::AssignCompositeConnection { state xytolerance } {
	WarnWinText "\n------------------------------------------------------------------------"
	WarnWinText "Entering function Fire::AssignCompositeConnection given state: $state"
	WarnWinText "The tolerance for the combined xy directions is given as: $xytolerance"	
	WarnWinText "------------------------------------------------------------------------\n"
	set interval [lindex [GiD_Info intvdata num] 0]
	
	if {$state == "fire"} {
		set leader_condition_name "Line_Composite_Section_Slab"
		set follower_condition_name "Line_Composite_Section_Beam"
	} elseif {$state == "ambient"} {
		set leader_condition_name "Line_Composite_Section_Slab_AMBIENT"
		set follower_condition_name "Line_Composite_Section_Beam_AMBIENT"
	} else {
		WarnWinText "ERROR: Unknown state used for Fire:PairCompositeSections.\n can be either 'fire' or 'amient'."
		return -1
	}   
	set nodes_to_collapse ""
	
		set leader_node_list [GiD_Info Conditions $leader_condition_name mesh]
		array unset leader_node_array
		foreach leader_node $leader_node_list {
			set node_id [lindex $leader_node 1] 
			set cond_id [lindex $leader_node 4]
			set args [lrange $leader_node 3 end]
			# Make sure that the item at index 0 of the condition ID is always
			# the arguments for that condition, follower by the nodes over which
			# the condition was applied. 
			if {![info exists leader_node_array($cond_id)]} {
				lappend leader_node_array($cond_id) "$args"
			}                
			lappend leader_node_array($cond_id) $node_id
		}
		# The follower condition is applied over elements rather than over nodes
		# so that it can be used when applying the thermal load in the structural
		# model using the bas file. The following loop finds the nodes overwhich
		# the condition is applied by retrieving element information.
		set follower_elem_list [GiD_Info Conditions $follower_condition_name mesh]
		array unset follower_node_array
		foreach follower_elem $follower_elem_list {
			set elem_id [lindex $follower_elem 1] 
			set cond_id [lindex $follower_elem 4]
			set args [lrange $leader_node 3 end]
			set elem_info [GiD_Mesh get element $elem_id]
			# because the function LappendUnique expects the array key to already exist
			# it is necessary that the array and its key are created if it does already
			# already exist. LappendUnique is used here to ensure the nodes are not 
			# repeated since elements share some nodes due to connectivity. 
			if {![info exists follower_node_array($cond_id)]} {
				lappend follower_node_array($cond_id) $args
			}
			set follower_node_array($cond_id) [LappendUnique $follower_node_array($cond_id) [lindex $elem_info 3]]
			set follower_node_array($cond_id) [LappendUnique $follower_node_array($cond_id) [lindex $elem_info 4]]                
		}
		
		# check if the conditions match
		set leader_conditions [array names leader_node_array]
		set follower_conditions [array names follower_node_array]
		set conds_commons [FindListCommonItems $leader_conditions $follower_conditions]
		set common_conds [lindex $conds_commons 1]
		if {[lindex $conds_commons 0]} {
			WarnWinText "All leader conditions are common with follower conditions."
		} else {
			set uncommon_conds [lindex $conds_commons 2]
			WarnWinText "The following conditions are uncommon:\n$uncommon_conds"
			foreach bug $uncommon_conds {
				if {$bug in $leader_conditions} {
					set debug_args [lrange [lindex $leader_node_array($bug) 0] 0 1]
					set nodes_to_debug [lrange $leader_node_array($bug) 1 end]
					lappend debug_args "leader without follower"
				} else {
					set debug_args [lrange [lindex $follower_node_array($bug) 0] 0 1]
					set nodes_to_debug [lrange $follower_node_array($bug) 1 end]
					lappend debug_args "follower without leader"
				}
				foreach bugged_node $nodes_to_debug {
					GiD_IntervalData set 1
					GiD_AssignData condition Line_connectivity_condition_debug Nodes $debug_args $bugged_node
					GiD_IntervalData set $interval
				}
			}
		}

		
		# pair up nodes and apply connection condition
		array unset node_pairs
		variable constraint_ID
		set count 1 
		foreach cond_id $common_conds {
			set args [lindex $leader_node_array($cond_id) 0]
			set leader_node_ids [lrange $leader_node_array($cond_id) 1 end]
			set follower_node_ids [lrange $follower_node_array($cond_id) 1 end]
			lappend node_pairs($cond_id) $args
			foreach leader_node $leader_node_ids {
				set xyz_leader [lindex [GiD_Info Coordinates $leader_node mesh] 0];
				foreach follower_node $follower_node_ids {
					
					set xyz_follower [lindex [GiD_Info Coordinates $follower_node mesh] 0];
					# WarnWinText "Follower node $follower_node x y z = $xyz_follower"
					set distance_vect [math::linearalgebra::sub_vect  $xyz_leader  $xyz_follower]
					set delta_x [lindex $distance_vect 0]
					set delta_y [lindex $distance_vect 1]
					if {abs($delta_x) < 1e-5 && abs($delta_y) < 1e-5} {
						if {$leader_node == $follower_node} {
							WarnWinText "Warning: leader and follower nodes have the same ID: $leader_node"
							set debug_args [lrange $args 0 1]
							lappend debug_args "identical leader and follower"
							GiD_IntervalData set 1
							GiD_AssignData condition Line_connectivity_condition_debug Nodes $debug_args $leader_node
							GiD_IntervalData set $interval
						} else {
							# WarnWinText "leader node xyz: $xyz_leader\nfollower node xyz: $xyz_follower"
							lappend node_pairs($cond_id) "$leader_node $follower_node"
						}
					}
				}
			}
			set condition_type [lindex $args 2]
			
			if {$condition_type == "rigid_link"} {
					foreach pair [lrange $node_pairs($cond_id) 1 end] {
							set cond_args "$constraint_ID [lindex $args 3]"
							GiD_IntervalData set 1
							GiD_AssignData condition Point_Rigid_link_master_node Nodes $cond_args [lindex $pair 0]
							GiD_AssignData condition Point_Rigid_link_slave_nodes Nodes $cond_args [lindex $pair 1]
							GiD_IntervalData set $interval							
							set constraint_ID [expr $constraint_ID + 1]
					}
			} elseif {$condition_type == "equal_DOF"} {
					foreach pair [lrange $node_pairs($cond_id) 1 end] {
							GiD_IntervalData set 1
							set cond_args_follower "$constraint_ID [lrange $args 4 9]"
							GiD_AssignData condition Point_Equal_constraint_master_node Nodes "$constraint_ID 0 0" [lindex $pair 0]
							GiD_AssignData condition Point_Equal_constraint_slave_nodes Nodes $cond_args_follower [lindex $pair 1]
							GiD_IntervalData set $interval							
							set constraint_ID [expr $constraint_ID + 1]
					}
			
			} elseif {$condition_type == "common_nodes"} {
					foreach pair [lrange $node_pairs($cond_id) 1 end] {
							set nodes_to_collapse [LappendUnique $nodes_to_collapse $pair] 
					}
			} elseif {$condition_type == "finite"} {
			W  "condition type is finite!!!"
					foreach pair [lrange $node_pairs($cond_id) 1 end] {
							GiD_IntervalData set 1
						
							GiD_Mesh create element append Line 2 "[lindex $pair 1] [lindex $pair 0]" [lindex $args 10]
							
							GiD_IntervalData set $interval							
							set constraint_ID [expr $constraint_ID + 1]
					}
			
			}
			
		}
	if {[llength $nodes_to_collapse] == 0} {
		WarnWinText "nodes_to_collapse: none"
	} else {
		WarnWinText "nodes_to_collapse: $nodes_to_collapse"
		set cmd [join "GiD_Process Mescape Utilities Collapse Nodes" " "]
		foreach node $nodes_to_collapse {
			lappend cmd $node
		}
		lappend cmd escape escape
		eval $cmd
	}
}



# a procedure to find items that are common in two lists. Returns a list 
# that contains a boolean for weather all the two list items are common 
# at index 0,all common items as a list at index 1, and all uncommon items
# at index 2.
proc FindListCommonItems { list1 list2 } {
	set common ""
	set uncommon ""
	set length1 [llength $list1]
	set length2 [llength $list2]
	if {$length1 >= $length2} {
		foreach item $list1 {
			if {$item in $list2} {
				lappend common $item
			} else {
				lappend uncommon $item
			}
		}
	} else {
		foreach item $list2 {
			if {$item in $list1} {
				lappend common $item
			} else {
				lappend uncommon $item
			}
		}
	}
	set length_common [llength $common]
	if {$length1 == $length_common && $length2 == $length_common} {
		set all_common 1
	} else {
		set all_common 0
	}
	if {!$all_common} {
		if {$length1 >= $length2} {
			foreach item $list2 {
				if {!($item in $common)} {
					lappend uncommon $item
				}
			}
		} else {
			foreach item $list1 {
				if {!($item in $common)} {
					lappend uncommon $item
				}
			}
		}
	} 
	lappend answer $all_common $common $uncommon
	return $answer
}
# The following command is used purely to select a representative element and apply a 
# copy of one of the condition related to its HT analysis. The condition is used by 
# the bas file to generate the HT data files.
proc Fire::AssignCentralElementFlag {} {
	WarnWinText "\n------------------------------------------------"
	WarnWinText "Entering function Fire::AssignCentralElementFlag"
	WarnWinText "------------------------------------------------\n"
	
	
	set condition_name "Line_Gas_Temperatures Line_Composite_Section_Beam Surface_Gas_Temperatures"
	foreach cond $condition_name {
		array unset geometry_elements_mesh
		array unset geometry_elements_args
		set elem_list [GiD_Info Conditions $cond mesh]
		foreach elem $elem_list {
		
			set elem_id [lindex $elem 1]
			set geometric_entity_id [lindex $elem 3]
			set condition_id [lindex $elem 4]
			set args [lrange $elem 3 end]
			lappend geometry_elements_mesh($geometric_entity_id) $elem_id
			set geometry_elements_args($geometric_entity_id) $args
		}
		
		foreach geometric_entity [array names geometry_elements_mesh] {
		
			if {$cond == "Surface_Gas_Temperatures"} {
							set xyz [GidUtils::GetEntityCenter surface $geometric_entity]
							set central_elem_id [GidUtils::GetClosestElement surface $xyz $geometry_elements_mesh($geometric_entity)]
							GiD_AssignData condition Surface_Gas_Temperatures_Central Elements $geometry_elements_args($geometric_entity) $central_elem_id
			} elseif {$cond == "Line_Composite_Section_Beam"} {
							set xyz [GidUtils::GetEntityCenter line $geometric_entity]
							set central_elem_id [GidUtils::GetClosestElement line $xyz $geometry_elements_mesh($geometric_entity)]
							GiD_AssignData condition Line_Composite_Section_Beam_Central Elements $geometry_elements_args($geometric_entity) $central_elem_id
			} elseif {$cond == "Line_Gas_Temperatures"} {
							set xyz [GidUtils::GetEntityCenter line $geometric_entity]
							set central_elem_id [GidUtils::GetClosestElement line $xyz $geometry_elements_mesh($geometric_entity)]
							GiD_AssignData condition Line_Gas_Temperatures_Central Elements $geometry_elements_args($geometric_entity) $central_elem_id
			}
		}
	}
}

# lappends a list with only unique items from another list
proc LappendUnique { a_list another_list } {
	foreach item $another_list {
		if {!($item in $a_list)} {
		        lappend a_list $item
		}
	}
	return $a_list
}

# method for generating string for the directory of the thermal loading files
proc Fire::GetTempFileDir { ID a_string } {
	if {$a_string == "slab"} {
		return "\"../Records/Thermal_load/Slab$ID.dat\""
	} elseif {$a_string == "beam-column"} {
		return "\"../Records/Thermal_load/BeamColumn$ID.dat\""
	}
	
}

# method to get the number of workers
proc Fire::GetNumOWorkers { } {
	set all_gen_data [GiD_Info gendata]
	set num_o_workers_index [expr [lsearch $all_gen_data num_of_workers] + 1]
	return [lindex $all_gen_data $num_o_workers_index]
} 

#method to shorten the call to WarnWinText
proc W {anything} {	
	WarnWinText "$anything" 
}

proc SourceHello { } {
	source "C:\\Program Files\\GiD\\GiD 15.0.2\\problemtypes\\OpenSees.gid\\exe\\hello.tcl"
}

