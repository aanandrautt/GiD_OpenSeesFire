source methods.tcl

set condition_name {Line_Composite_Section_nodes}
set line_list [GiD_Info Conditions $condition_name geometry]

array unset line_id_list
foreach line_instance $line_list {
	set id [lindex $line_instance 1]
	set args [lrange $line_instance 3 end]
	set args [lreplace $args 0 0 $id]
	set line_id_list($id) $args
}

set surf_condition_name {Surface_Composite_Section}
foreach line_id [array names line_id_list] {
	set associated_surf_ids [GetLineHigherEntities $line_id]
	GiD_AssignData condition $surf_condition_name surfaces $line_id_list($line_id)  $associated_surf_ids
}

array unset master_nodes
set master_node_list [GiD_Info Conditions $condition_name mesh]
foreach node_entity $master_node_list {
	set master_node_id [lindex $node_entity 1]
	set master_cond_args [lrange $node_entity 3 end]
	set node_coords [GiD_Info Coordinates $master_node_id]
	set master_nodes($master_node_id) "$node_coords [list $master_cond_args]"
	WarnWinText "master node has the info: $master_node_id, with coordinates: $master_nodes($master_node_id)"
	WarnWinText "and has the arguments: $master_cond_args"
}

set follower_node_ids ""
set follower_elem_list [GiD_Info Conditions "Line_Composite_Section" mesh]
foreach elem_entity $follower_elem_list {
	set elem_id [lindex $elem_entity 1] 
	set elem_info [GiD_Mesh get element $elem_id]
	set follower_node_ids [LappendUnique $follower_node_ids [lindex $elem_info 3]]
	set follower_node_ids [LappendUnique $follower_node_ids [lindex $elem_info 4]]
}
WarnWinText "follower node IDs are: $follower_node_ids"

array unset follower_nodes
foreach node_id $follower_node_ids {
	set node_coords [GiD_Info Coordinates $node_id]
	set follower_nodes($node_id) $node_coords
	WarnWinText "follower node has the info: $node_id, with coordinates: $follower_nodes($node_id)"
}

foreach master_node [array names master_nodes] {
	foreach follower_node [array names follower_nodes] {
		set xyz_master [lindex $master_nodes($master_node) 0];set xyz_follower [lindex $follower_nodes($follower_node) 0];
		# WarnWinText "master node xyz: $xyz_master\nfollower node xyz: $xyz_follower"
		set distance_vect [math::linearalgebra::sub_vect  $xyz_master  $xyz_follower]
		set delta_x [lindex $distance_vect 0]
		set delta_y [lindex $distance_vect 1]
		if {abs($delta_x) < 1e-5 && abs($delta_y) < 1e-5} {
			if {$master_node == $follower_node} {
				WarnWinText "master and follower nodes have the same ID: $master_node"
			} else {
				lappend master_nodes($master_node) $follower_node
			}
			# WarnWinText "created: $master_nodes($master_node)"
		}
	}
}
set nodes_to_collapse ""
foreach key [array names master_nodes] {
	set cond_type [lindex [lindex $master_nodes($key) 1] 1]
	if {$cond_type == "rigid_link"} {
		set follower_node [lindex $master_nodes($key) end]
		lappend nodes_to_collapse $key $follower_node
		# WarnWinText "collapsed node $key, so node $follower_node should also be gone."
	}
	# WarnWinText "[array get master_nodes $key]"
	# WarnWinText "condition type is: $cond_type"
}
WarnWinText "nodes to collapse: $nodes_to_collapse"
set cmd [join "GiD_Process Mescape Utilities Collapse Nodes" " "]
# set nodes_to_collapse_string [join $nodes_to_collapse " "]
foreach node $nodes_to_collapse {
	lappend cmd $node
}
lappend cmd escape
WarnWinText "$cmd"
eval $cmd

