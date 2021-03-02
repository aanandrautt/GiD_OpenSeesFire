set condition_name {Line_Gas_Temperatures}
set line_elem_list [GiD_Info Conditions $condition_name mesh]
array unset lines_and_elems
set material_list [GiD_Info materials]

WarnWinText "line_elem_list: $line_elem_list"

foreach line_elem $line_elem_list {
	set element_id [lindex $line_elem 1]
	set line_id [lindex $line_elem 3]
	lappend lines_and_elems($line_id) $element_id
}

WarnWinText "Array names (line IDs) [array names lines_and_elems]" 

foreach line [array names lines_and_elems] {
	WarnWinText "Line $line is meshed into elements: $lines_and_elems($line)"
	set xyz [GidUtils::GetEntityCenter line $line]
	set elem_ID [GidUtils::GetClosestElement line $xyz $lines_and_elems($line)]
	WarnWinText "Selected middle element: $elem_ID"
	set t_couple_id "l$line"
	WarnWinText "thermocouple ID is: $t_couple_id"
	GiD_AssignData condition Line_Thermo_Couple Elements "$t_couple_id" $elem_ID
	# GiD_AssignData condition $condition_name Elements $new_values $element_id
	# set elem_ID [lindex $lines_and_elems($line) 0]
	set elem_info_sublist [GiD_Info Mesh Elements line $elem_ID]
	WarnWinText "Element information sublist is: $elem_info_sublist"
	set elem_mat_ID [lindex $elem_info_sublist 3]
	WarnWinText "and the 4th item, and thus material (beam-column designation) ID, in this sublist is: $elem_mat_ID"
	set elem_mat [lindex $material_list [expr $elem_mat_ID - 1]]
	WarnWinText "Which corresponds to an element of type: $elem_mat"
	set sec_name [GiD_AccessValue get materials $elem_mat "Section"]
	WarnWinText "Which has section: $sec_name"
	set sec_info [GiD_Info materials $sec_name]
	# foreach prop $sec_info {
		# WarnWinText "$prop"
	# }
}