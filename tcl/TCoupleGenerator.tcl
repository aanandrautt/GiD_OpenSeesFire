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
# proc Fire::GenerateLineTCouplesOriginal {} {
	# set condition_name {Line_Gas_Temperatures}
	# set line_list [GiD_Info Conditions $condition_name geometry]
	# array unset geometric_entities_ids
	# foreach geometric_entity $line_list {
	# set id [lindex $geometric_entity 1]
	# set args [lrange $geometric_entity 3 end]
	# lappend geometric_entities_ids($id) $args
	# }
	# set geometric_entity_list [array names geometric_entities_ids]
	# array unset thermocouple_parameters
	
    # set parameters 0.5
	# foreach line_entity_id $geometric_entity_list {
		# set xyz [GidUtils::GetEntityCenter line $line_entity_id]
		# lappend thermocouple_parameters(L$line_entity_id) $xyz
	# }
	# set sorted_thermocouple_parameters [lsort [array names thermocouple_parameters]]
	
	# set fileHandle [open "[OpenSees::GetProjectPath]/Records/TCouples.txt" w+]
	# foreach thermocouple $sorted_thermocouple_parameters {
		# set xyz [lindex $thermocouple_parameters($thermocouple) 0]
		# set x [lindex $xyz 0]; set y [lindex $xyz 1]; set z [lindex $xyz 2];
		# puts $fileHandle "&DEVC ID = '$thermocouple', QUANTITY='GAS TEMPERATURE', XYZ=$x,$y,$z/"
	# }
	# close $fileHandle
# }

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

