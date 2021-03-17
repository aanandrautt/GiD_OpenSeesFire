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
