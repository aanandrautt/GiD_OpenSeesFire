namespace eval Fire {
}
proc Fire::GenerateThermoCouples {} {
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
		set args [lreplace $args 0 0 $id]
		set line_id_list($id) $args
	}

	set surf_condition_name "Surface_Composite_Section"
	foreach line_id [array names line_id_list] {
		# set associated_surf_ids [GetLineHigherEntities $line_id]
		set associated_surf_ids [GidUtils::GetEntityHigherEntities line $line_id] 
		GiD_AssignData condition $surf_condition_name surfaces $line_id_list($line_id)  $associated_surf_ids
	}
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
		# set args [lrange $line_instance 4 end]
		set pts_xyz [OS_Geom::GetPointCoords $line_id]
		set xyz_i [lrange $pts_xyz 0 2]
		set xyz_f [lrange $pts_xyz 3 5]
		lappend leader_line_data_list($line_id) $composite_id $xyz_i $xyz_f
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
		set xyz_i_leader [lindex $leader_line_data_list($leader_line) 1]
		set xyz_f_leader [lindex $leader_line_data_list($leader_line) 2]
		
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
		                set args [lreplace [lindex $follower_line_data_list($follower_line) 0] 1 1 $composite_id]
						WarnWinText "args for line $follower_line are: $args"
		                GiD_AssignData condition $follower_condition_name lines $args $follower_line
		        }        
		}
	}
}

proc Fire::AssignCentralElementFlag {} {
	array unset geometry_elements
	set condition_name "Line_Gas_Temperatures Line_Composite_Section_Beam Surface_Gas_Temperatures"
	foreach cond $condition_name {
		set elem_list [GiD_Info Conditions $cond mesh]
		foreach elem $elem_list {
		        set elem_id [lindex $line_elem 1]
		        set geometric_entity_id [lindex $line_elem 3]
		        lappend geometry_elements($geometric_entity_id) $elem_id
		}
		foreach geometric_entity [array names geometry_elements] {
		        if {$cond == "Surface_Gas_Temperatures"} {
		                set xyz [GidUtils::GetEntityCenter surface $geometric_entity]
		                set central_elem_id [GidUtils::GetClosestElement surface $xyz $geometry_elements($geometric_entity)]
		                # GiD_AssignData condition Line_Thermo_Couple Elements "$t_couple_id" $elem_ID 
		                Line 56 is still incomplete; i need to get the condition arguments and then assign the central element boolean to 1.
		        } elseif {$cond == "Line_Composite_Section_Beam"} {
		                Here I need to go to the surface that is connected to this particular composite beam and get its section properties, or
		                assign a unique condition to it to make it easy to find and navigate. 
		        
		        } elseif {$cond == "Line_Gas_Temperatures"} {
		                This should be the easiest. 
		        
		        }
		}
	
	}
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


