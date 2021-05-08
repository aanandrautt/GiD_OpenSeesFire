namespace eval MeshRepair {
} 

proc MeshRepair::MatchMesh { } {
	WarnWinText "\n----------------------------------------------------------"
	WarnWinText "Entering function: MeshRepair::MatchMesh"
	WarnWinText "----------------------------------------------------------\n"
	set leader_condition_name "Line_Composite_Section_Slab_AMBIENT"
	set follower_condition_name "Line_Composite_Section_Beam_AMBIENT"

	array unset leader_line_array
	array unset leader_line_nodes_array
	array unset follower_line_array
	set leader_line_info_list [GiD_Info conditions $leader_condition_name geometry]
	set num_of_leader_lines [llength $leader_line_info_list]
	foreach line $leader_line_info_list {
		set line_id [lindex $line 1]
		set composite_id [lindex $line 4]
		set pts_xyz [OS_Geom::GetPointCoords $line_id]
		array set leader_line_array [list $line_id "$composite_id"]
	}

	set leader_line_node_list [GiD_Info conditions $leader_condition_name mesh]
	set num_of_leader_line_nodes [llength $leader_line_node_list]
	foreach node $leader_line_node_list {
		set node_id [lindex $node 1]
		set line_id [lindex $node 3]
		lappend leader_line_nodes_array($line_id) $node_id 
	}

	foreach leader_line [array names leader_line_nodes_array] {
		set num_of_nodes [llength $leader_line_nodes_array($leader_line)]
		lappend leader_line_array($leader_line) $num_of_nodes
	}

	set commons [FindListCommonItems [array names leader_line_nodes_array] [array names leader_line_array]]
	set unmeshed_line_list [lindex $commons 2]
	if {[llength $unmeshed_line_list] > 0} {
		W "WARNING: There are [llength $unmeshed_line_list] unmeshed lines with $leader_condition_name condition."
		foreach line $unmeshed_line_list {
			lappend leader_line_array($line) 0
			# GiD_UnAssignData condition $leader_condition_name lines $line
		}
		W "\n\nPlease remesh.\n\n"
	}

	set follower_line_info_list [GiD_Info Conditions $follower_condition_name geometry]
	set num_of_follower_lines [llength $follower_line_info_list]
	foreach line $follower_line_info_list {
		set line_id [lindex $line 1]
		set composite_id [lindex $line 4]
		set follower_line_array($composite_id) $line_id
	}
	set lines_to_remesh ""
	foreach leader_line [lsort -integer [array names leader_line_array]] {
		set num_of_nodes [lindex $leader_line_array($leader_line) 1]
		set composite_id [lindex $leader_line_array($leader_line) 0]
		if  {[info exists follower_line_array($composite_id)]} {
			set follower_elem_id $follower_line_array($composite_id)
		} else {
			set follower_elem_id -1
		}
		# W "there should be: $num_of_nodes nodes for line with composite id: $composite_id and line number: $follower_elem_id"
		if {$num_of_nodes > 0 && $follower_elem_id > 0} {
			lappend lines_to_remesh "[expr $num_of_nodes - 1] $follower_elem_id"
		}
	} 
	W $lines_to_remesh
	return $lines_to_remesh
}
proc MeshRepair::ReassignMeshDivisions { aList } {
	WarnWinText "\n----------------------------------------------------------"
	WarnWinText "Entering function: MeshRepair::ReassignMeshDivisions"
	WarnWinText "----------------------------------------------------------\n"
	foreach pair $aList {
		GiD_MeshData structured lines num_divisions [lindex $pair 0] [lindex $pair 1]
	}
	
	
}