namespace eval Fire {
}
proc Fire::GenerateThermoCouples {} {
	set ID 1
	array unset thermocouple_data
	set condition_name "Line_Gas_Temperatures Line_Composite_Section_Beam Surface_Gas_Temperatures"
		foreach cond $condition_name {
			set geometric_entity_list [GiD_Info Conditions $cond geometry]
			foreach geometric_entity $geometric_entity_list {
				set geometric_entity_id [lindex $geometric_entity 1]
				set xyz ""
				
				set condition_args [lrange $geometric_entity 3 end]
				WarnWinText "condition $ID arguments are = $condition_args"
				set condition_args [lreplace $condition_args 0 0 $geometric_entity_id]
				WarnWinText "condition $ID arguments are changed to = $condition_args"
				set condition_args [lreplace $condition_args 1 1 $ID]
				WarnWinText "condition $ID arguments are again changed to = $condition_args"
				
				if {$cond == "Surface_Gas_Temperatures"} {
					set xyz [GidUtils::GetEntityCenter surface $geometric_entity_id]
					GiD_AssignData condition $cond surfaces $condition_args $geometric_entity_id
				} else {
					set xyz [GidUtils::GetEntityCenter line $geometric_entity_id]
					GiD_AssignData condition $cond lines $condition_args $geometric_entity_id
				}
				set thermocouple_data($ID) $xyz
				WarnWinText "thermocouple_ID = $ID, and xyz = $thermocouple_data($ID)"
				set ID [expr $ID + 1]
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
			
			} elseif {$cond == "Line_Gas_Temperatures"}{
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


