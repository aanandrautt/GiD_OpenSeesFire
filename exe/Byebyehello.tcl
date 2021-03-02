set condition_name {Line_Gas_Temperatures}
set line_list [GiD_Info Conditions $condition_name geometry]
set material_list [GiD_Info materials]

array unset geometric_entities_ids
foreach line_instance $line_list {
	set id [lindex $line_instance 1]
	set args [lrange $line_instance 3 end]
	lappend geometric_entities_ids($id) $args
}
WarnWinText "list of lines:"
foreach lineID [array names geometric_entities_ids] {
	WarnWinText "[GiD_Info list_entities Lines $lineID]"
	set xyz [GidUtils::GetEntityCenter line $lineID]
	WarnWinText "xyz = $xyz"
	# [GiD_Info Mesh Elements line -sublist]
	set element_id [GidUtils::GetClosestElement line $xyz $lineID]
	WarnWinText "element of ID: $element_id\n\n"
}


# -np- WarnWinText "[GiD_AccessValue -index get materials 65 "Section:"]"
# ->-np- WarnWinText "[lindex [GiD_Info materials] 64]"