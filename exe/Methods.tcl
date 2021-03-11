proc GetSurfLines { surf_id } {
	set surf_info [GiD_Geometry get surface $surf_id]
	set num_of_lines [lindex $surf_info 2]
	set first_line 9
	set lines ""
	for {set i $first_line} {$i < $first_line + $num_of_lines} {incr i} {
		lappend lines [lindex [lindex $surf_info $i] 0]
	}
	return $lines
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

proc GetLineHigherEntities { line_ID } {
	set line_info_list [split [GiD_Info list_entities -more line $line_ID] \n]
	set higher_entity_list [lindex  $line_info_list [expr [llength $line_info_list] - 3]]
	return [lrange $higher_entity_list 3 end]
}

proc GetLineElemNodes { elem_id } {
	set line_elem_info [GiD_Mesh get element $elem_id]
	return [lrange 3 end]
} 

proc GetCondEntitiesAsArray { condition_name over } {
	set entity_list [GiD_Info Conditions $condition_name $over]
	array unset container_array
	foreach item $entity_list {
		set id [lindex $item 1]
		set args [lrange $item 3 end]
		set container_array($id) $args
	}
	return [array get container_array]
}

proc LappendUnique { a_list item } {
	if {!($item in $a_list)} {
		lappend a_list $item
	}
	return $a_list
}