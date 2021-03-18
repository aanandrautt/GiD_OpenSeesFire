namespace eval Fire {
	
}
proc GiD_Event_BeforeMeshGeneration { element_size } {
	Fire::AssignConditionIds
}
proc GiD_Event_AfterMeshGeneration { fail } { 
	if {!$fail} {
		Fire::AssignCompositeConnection 
	}
}
# should be performed BEFORE meshing
proc Fire::AssignConditionIds {} {
	set ID 1
	array unset thermocouple_data
	set condition_name "Line_Gas_Temperatures Surface_Gas_Temperatures Line_Composite_Section_Slab"
		foreach cond $condition_name {
		        set geometric_entity_list [GiD_Info Conditions $cond geometry]
		        foreach geometric_entity $geometric_entity_list {
		                set geometric_entity_id [lindex $geometric_entity 1]
		                set xyz ""
		                
		                set condition_args [lrange $geometric_entity 3 end]
		                # WarnWinText "condition $ID arguments are = $condition_args"
		                set condition_args [lreplace $condition_args 0 0 $geometric_entity_id]
		                # WarnWinText "condition $ID arguments are changed to = $condition_args"
		                set condition_args [lreplace $condition_args 1 1 $ID]
		                # WarnWinText "condition $ID arguments are again changed to = $condition_args"
		                
		                if {$cond == "Surface_Gas_Temperatures"} {
		                        set xyz [GidUtils::GetEntityCenter surface $geometric_entity_id]
		                        GiD_AssignData condition $cond surfaces $condition_args $geometric_entity_id
		                } else {
		                        set xyz [GidUtils::GetEntityCenter line $geometric_entity_id]
		                        GiD_AssignData condition $cond lines $condition_args $geometric_entity_id
		                }
		                set thermocouple_data($ID) $xyz
		                # WarnWinText "thermocouple_ID = $ID, and xyz = $thermocouple_data($ID)"
		                set ID [expr $ID + 1]
		        }
		}
	Fire::PairCompositeSections
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
	set sorted_thermocouple_data_keys [lsort [array names thermocouple_data]]
	set fileHandle [open "[OpenSees::GetProjectPath]/Records/TCouples.txt" w+]
	foreach key $sorted_thermocouple_data_keys {
		set xyz $thermocouple_data($key)
		set x [lindex $xyz 0]; set y [lindex $xyz 1]; set z [lindex $xyz 2];
		puts $fileHandle "&DEVC ID = '$key', QUANTITY='GAS TEMPERATURE', XYZ=$x,$y,$z/"
	}
	close $fileHandle
}
proc Fire::AssignSurfaceCompositeSectionCond {} {
	set condition_name "Line_Composite_Section_Slab"
	set line_list [GiD_Info Conditions $condition_name geometry]
	array unset line_id_list

	foreach line_instance $line_list {
		set id [lindex $line_instance 1]
		set args [lrange $line_instance 3 end]
		WarnWinText "arguments: $args"
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
			WarnWinText "distance vector is: $distance_vect"
			set distance [expr 2*[math::linearalgebra::norm_two $distance_vect]]
			WarnWinText "Which has the distance: $distance"
			set width [expr $width + $distance]
		}
		set width "$width [GiD_Units get model_unit_length]"
		WarnWinText "giving line $line_id a width of $width"
		
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
		
		set slab_protection_index [lsearch $section_type_info "Protection_thickness#UNITS#"]
		set slab_protection_thickness [lindex $section_type_info [expr $slab_protection_index + 1]]
		
		set slab_protection_mat_index [lsearch $section_type_info "protection_material#CB#(1,2,3)"]
		set slab_protection_mat [lindex $section_type_info [expr $slab_protection_mat_index + 1]]
		WarnWinText "old arguments $line_id_list($line_id)"
		set line_id_list($line_id) [lreplace $line_id_list($line_id) end-3 end $width $slab_thickness $slab_protection_thickness $slab_protection_mat]
		WarnWinText "new arguments $line_id_list($line_id)"
		
		GiD_AssignData condition $condition_name lines $line_id_list($line_id)  $line_id
		GiD_AssignData condition $surf_condition_name surfaces $line_id_list($line_id)  $associated_surf_ids

	}
}
proc GetLineHigherEntities { line_ID } {
	set line_info_list [split [GiD_Info list_entities -more line $line_ID] \n]
	WarnWinText "line_info_list = $line_info_list"
	set higher_entity_list [lindex  $line_info_list [expr [llength $line_info_list] - 3]]
	WarnWinText "higher_entity_list = $higher_entity_list"
	WarnWinText "returning = [lrange $higher_entity_list 3 end]"
	return [lrange $higher_entity_list 3 end]
}
proc Fire::GetLineEndPoints { line_ID } {
	set line_data [GiD_Geometry get line $line_ID]
	return [lrange $line_data 2 3]
} 
proc Fire::PairCompositeSections {} {
	Fire::AssignSurfaceCompositeSectionCond
	
	set leader_condition_name "Line_Composite_Section_Slab"
	set line_list [GiD_Info Conditions $leader_condition_name geometry]
	
	array unset leader_line_data_list
	foreach line_instance $line_list {
		set line_id [lindex $line_instance 1]
		set composite_id [lindex $line_instance 4]
		set slab_props [lrange $line_instance end-3 end]
		set pts_xyz [OS_Geom::GetPointCoords $line_id]
		set xyz_i [lrange $pts_xyz 0 2]
		set xyz_f [lrange $pts_xyz 3 5]
		lappend leader_line_data_list($line_id) $composite_id $slab_props $xyz_i $xyz_f
	}
	
	set follower_condition_name "Line_Composite_Section_Beam"
	set line_list [GiD_Info Conditions $follower_condition_name geometry]
	
	array unset follower_line_data_list
	foreach line_instance $line_list {
		set line_id [lindex $line_instance 1]
		# set composite_id [lindex $line_instance 3]
		set args [lrange $line_instance 3 end]
		set pts_xyz [OS_Geom::GetPointCoords $line_id]
		set xyz_i [lrange $pts_xyz 0 2]
		set xyz_f [lrange $pts_xyz 3 5]
		lappend follower_line_data_list($line_id) $args $xyz_i $xyz_f
	}
	
	array unset line_pairs
	
	foreach leader_line [array names leader_line_data_list] {
		set xyz_i_leader [lindex $leader_line_data_list($leader_line) 2]
		set xyz_f_leader [lindex $leader_line_data_list($leader_line) 3]
		
		foreach follower_line [array names follower_line_data_list] {
		        set xyz_i_follower [lindex $follower_line_data_list($follower_line) 1]
		        set xyz_f_follower [lindex $follower_line_data_list($follower_line) 2]
		        set distance_i_i [math::linearalgebra::sub_vect  $xyz_i_follower  $xyz_i_leader]
		        set distance_f_f [math::linearalgebra::sub_vect  $xyz_f_follower  $xyz_f_leader]
		        set delta_x_i [lindex $distance_i_i 0]
		        set delta_y_i [lindex $distance_i_i 1]
		        set delta_x_f [lindex $distance_f_f 0]
		        set delta_y_f [lindex $distance_f_f 1] 
		        set err [expr abs($delta_x_i)  + abs($delta_y_i) + abs($delta_x_f)  + abs($delta_y_f)]
		        if {$err > 1e-5} {
					set distance_i_f [math::linearalgebra::sub_vect  $xyz_i_follower  $xyz_f_leader]
					set distance_f_i [math::linearalgebra::sub_vect  $xyz_f_follower  $xyz_i_leader]
					set delta_x_i [lindex $distance_i_f 0]
					set delta_y_i [lindex $distance_i_f 1]
					set delta_x_f [lindex $distance_f_i 0]
					set delta_y_f [lindex $distance_f_i 1] 
					set err [expr abs($delta_x_i)  + abs($delta_y_i) + abs($delta_x_f)  + abs($delta_y_f)]
		        }
		        if {$err < 1e-5} {
					set composite_id [lindex $leader_line_data_list($leader_line) 0]
					set slab_props [lindex $leader_line_data_list($leader_line) 1]
					WarnWinText "first, args for follower line $follower_line are: $[lindex $follower_line_data_list($follower_line) 0]"
					set args [lreplace [lindex $follower_line_data_list($follower_line) 0] 1 1 $composite_id]
					
					WarnWinText "second, args for follower line $follower_line are: $args"
					set args [lreplace $args end-3 end {*}$slab_props]
					WarnWinText "finally, args for follower line $follower_line are: $args"
					GiD_AssignData condition $follower_condition_name lines $args $follower_line
		        }        
		}
	}
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
proc Fire::AssignCentralElementFlag {} {
	set condition_name "Line_Gas_Temperatures Line_Composite_Section_Beam Surface_Gas_Temperatures"
	foreach cond $condition_name {
		array unset geometry_elements_mesh
		array unset geometry_elements_args
		WarnWinText "condition = $cond"
		set elem_list [GiD_Info Conditions $cond mesh]
		foreach elem $elem_list {
		
				set elem_id [lindex $elem 1]
				set geometric_entity_id [lindex $elem 3]
				set condition_id [lindex $elem 4]
				set args [lrange $elem 3 end]
				WarnWinText "elem_id = $elem_id\ngeometric_parent = $geometric_entity_id\ncond_id = $condition_id\n args = $args"
				lappend geometry_elements_mesh($geometric_entity_id) $elem_id
				set geometry_elements_args($geometric_entity_id) $args
		}
		
		WarnWinText "geometric entities are: [array names geometry_elements_mesh]"
		foreach geometric_entity [array names geometry_elements_mesh] {
			WarnWinText "entity $geometric_entity mesh: $geometry_elements_mesh($geometric_entity)"
			WarnWinText "entity $geometric_entity arguments: $geometry_elements_args($geometric_entity)"
			
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
# should be done AFTER meshing
proc Fire::AssignCompositeConnection {} {
	set nodes_to_collapse ""
	set leader_condition_name "Line_Composite_Section_Slab"
	set leader_node_list [GiD_Info Conditions $leader_condition_name mesh]
	array unset leader_node_array
	foreach leader_node $leader_node_list {
		set node_id [lindex $leader_node 1] 
		set cond_id [lindex $leader_node 4]
		set args [lrange $leader_node 3 end]
		if {![info exists leader_node_array($cond_id)]} {
		        lappend leader_node_array($cond_id) "$args"
		}                
		lappend leader_node_array($cond_id) $node_id
	}
	# foreach key [array names leader_node_array] {
		# WarnWinText "Leader node $key has items: $leader_node_array($key)"
		# WarnWinText "first item of which is [lindex $leader_node_array($key) 0]"
	# }
	
	set follower_condition_name "Line_Composite_Section_Beam"
	set follower_elem_list [GiD_Info Conditions $follower_condition_name mesh]
	array unset follower_node_array
	foreach follower_elem $follower_elem_list {
		set elem_id [lindex $follower_elem 1] 
		set cond_id [lindex $follower_elem 4]
		set elem_info [GiD_Mesh get element $elem_id]
		if {![info exists follower_node_array($cond_id)]} {
		        set follower_node_array($cond_id) ""
		}
		set follower_node_array($cond_id) [LappendUnique $follower_node_array($cond_id) [lindex $elem_info 3]]
		set follower_node_array($cond_id) [LappendUnique $follower_node_array($cond_id) [lindex $elem_info 4]]                
	}
	
	# check if the conditions match
	set leader_conditions [array names leader_node_array]
	set follower_conditions [array names follower_node_array]
	if {[llength $leader_conditions] == [llength $follower_conditions]} {
		set common_conds [FindListCommonItems $leader_conditions $follower_conditions]
		if {[llength $leader_conditions] != [llength $common_conds]} {
		        WarnWinText "ERROR: Conditions applied to leader and follower nodes don't have the same IDs"
		        return -1
		} else {WarnWinText "All good\nleaders: $leader_conditions\nfollowers: $follower_conditions\ncommon: $common_conds"}
	} else {
		WarnWinText "Number of leader and follower conditions inequal"
		WarnWinText "([llength $leader_conditions])leaders: $leader_conditions\n([llength $follower_conditions])followers: $follower_conditions"
		return -1
	}
	
	# pair up nodes and apply connection condition
	array unset node_pairs
	set count 1 
	foreach cond_id $leader_conditions {
		set args [lindex $leader_node_array($cond_id) 0]
		set leader_node_ids [lrange $leader_node_array($cond_id) 1 end]
		set follower_node_ids $follower_node_array($cond_id)
		lappend node_pairs($cond_id) $args
		foreach leader_node $leader_node_ids {
		        set xyz_leader [lindex [GiD_Info Coordinates $leader_node mesh] 0];
		        foreach follower_node $follower_node_ids {
		                set xyz_follower [lindex [GiD_Info Coordinates $follower_node mesh] 0];
		                set distance_vect [math::linearalgebra::sub_vect  $xyz_leader  $xyz_follower]
		                set delta_x [lindex $distance_vect 0]
		                set delta_y [lindex $distance_vect 1]
		                if {abs($delta_x) < 1e-5 && abs($delta_y) < 1e-5} {
		                        if {$leader_node == $follower_node} {
		                                WarnWinText "ERROR: leader and follower nodes have the same ID: $leader_node"
		                                return -1
		                        } else {
		                                # WarnWinText "leader node xyz: $xyz_leader\nfollower node xyz: $xyz_follower"
		                                lappend node_pairs($cond_id) "$leader_node $follower_node"
		                        }
		                }
		        }
		}
		# WarnWinText "For condition id: $cond_id, created: $node_pairs($cond_id)"
		WarnWinText "out of [llength $leader_node_ids] leader nodes and [llength $follower_node_ids] follower nodes created [llength [lrange $node_pairs($cond_id) 1 end]] pairs."
		set condition_type [lindex $args 2]
		
		if {$condition_type == "rigid_link"} {
		        foreach pair [lrange $node_pairs($cond_id) 1 end] {
		                set cond_args "$count [lindex $args 3]"
		                GiD_AssignData condition Point_Rigid_link_master_node Nodes $cond_args [lindex $pair 0]
		                GiD_AssignData condition Point_Rigid_link_slave_nodes Nodes $cond_args [lindex $pair 1] 
		                set count [expr $count + 1]
		        }
		} elseif {$condition_type == "equal_DOF"} {
		        foreach pair [lrange $node_pairs($cond_id) 1 end] {
		                set cond_args_follower "$count [lrange $args 4 end]"
		                GiD_AssignData condition Point_Equal_constraint_master_node Nodes "$count 0 0" [lindex $pair 0]
		                GiD_AssignData condition Point_Equal_constraint_slave_nodes Nodes $cond_args_follower [lindex $pair 1] 
		                set count [expr $count + 1]
		        }
		
		} elseif {$condition_type == "common_nodes"} {
		        foreach pair [lrange $node_pairs($cond_id) 1 end] {
		                set nodes_to_collapse [LappendUnique $nodes_to_collapse $pair] 
		                # WarnWinText "condition $cond_id nodes_to_collapse: $nodes_to_collapse"
		        }
		}
		
	}
	# WarnWinText "nodes_to_collapse: $nodes_to_collapse"
	set cmd [join "GiD_Process Mescape Utilities Collapse Nodes" " "]
	
	foreach node $nodes_to_collapse {
		lappend cmd $node
	}
	lappend cmd escape escape
	# WarnWinText "$cmd"
	eval $cmd
	
}




proc FindListCommonItems { list1 list2 } {
	set common ""
	foreach item $list1 {
		if {$item in $list2} {
		        lappend common $item
		}
	}
	return $common
}

proc LappendUnique { a_list another_list } {
	foreach item $another_list {
		if {!($item in $a_list)} {
		        lappend a_list $item
		}
	}
	return $a_list
}
proc Fire::AssignLineThermalCoupleCondition {} {
	set condition_name {Line_Gas_Temperatures}
	set line_elem_list [GiD_Info Conditions $condition_name mesh]
	array unset lines_and_elems

	#create an array whose keys are element ids and corresponding content is list of elements meshed into
	foreach line_elem $line_elem_list {
		set element_id [lindex $line_elem 1]
		set line_id [lindex $line_elem 3]
		lappend lines_and_elems($line_id) $element_id
	}

	foreach line [array names lines_and_elems] {
		set xyz [GidUtils::GetEntityCenter line $line]
		set elem_ID [GidUtils::GetClosestElement line $xyz $lines_and_elems($line)]
		#thermocouple id is lower case L (for line) followed by geometric line number
		set t_couple_id "L$line"
		#assign hidden condition 'Line_Thermo_Couple' to central element to loop over 
		#it when creating the data file in bas. Much easier to get info about section
		#in bas than here. 
		GiD_AssignData condition Line_Thermo_Couple Elements "$t_couple_id" $elem_ID
	}
}
#method for generating string for the directory of the thermal loading files
proc Fire::GetTempFileDir {line_id} {
	return "\"../Records/BeamL$line_id.dat\""
}