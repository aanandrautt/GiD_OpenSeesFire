namespace eval Joint {
	variable condition_ID 1
	variable constraint_ID [expr $Fire::constraint_ID + 1]
}

proc Joint::ResetIDs { } {
	set Joint::condition_ID 1
	set Joint::constraint_ID [expr $Fire::constraint_ID + 1]
}
proc Joint::PremeshGeneration { } {
	Joint::AssignConditionIDs
	Joint::MatchConditionIDs
}
proc Joint::PostMesh { } {
	Joint::AssignJoints
}
proc Joint::AssignConditionIDs { } {
# variable condition_ID
	W "\n------------------------------------------"
	W "Entering function Joint::AssignConditionIDs at [clock format [clock seconds] -format %H:%M:%S]"
	W "------------------------------------------\n"
	Joint::ResetIDs
	set condition_name "Line_Slab_Joint_Leader"
	foreach cond $condition_name {
		set geometric_entity_list [GiD_Info Conditions $cond geometry]
		foreach geometric_entity $geometric_entity_list {
			set geometric_entity_id [lindex $geometric_entity 1]
			set condition_args [lrange $geometric_entity 3 end]
			set condition_args [lreplace $condition_args 0 0 $geometric_entity_id]
			set condition_args [lreplace $condition_args 1 1 $Joint::condition_ID]
			GiD_AssignData condition $cond lines $condition_args $geometric_entity_id
			set Joint::condition_ID [expr $Joint::condition_ID + 1]
		}
	}

}

proc Joint::PairLinesAndID { leader_lines follower_lines xytolerance ztolerance } {
	W "\n------------------------------------------"
	W "Entering function Joint::PairLinesAndID at [clock format [clock seconds] -format %H:%M:%S]"
	W "------------------------------------------\n"
	
	set line_pairs ""
	set num_of_leaders [llength $leader_lines]
	set num_of_followers [llength $follower_lines]

	if { $num_of_leaders != $num_of_followers } {
		W "WARNING: Inequal number of leader and follower joint lines"
		W "$num_of_leaders leaders and $num_of_followers followers."
	}

	array unset leader_line_data_list
	foreach line_instance $leader_lines {
		set line_id [lindex $line_instance 1]
		set condition_id [lindex $line_instance 4]
		set pts_xyz [OS_Geom::GetPointCoords $line_id]
		set xyz_i [lrange $pts_xyz 0 2]
		set xyz_f [lrange $pts_xyz 3 5]	
		lappend leader_line_data_list($line_id) $xyz_i $xyz_f $condition_id
	}
	
	array unset follower_line_data_list
	foreach line_instance $follower_lines {
		set line_id [lindex $line_instance 1]
		set pts_xyz [OS_Geom::GetPointCoords $line_id]
		set xyz_i [lrange $pts_xyz 0 2]
		set xyz_f [lrange $pts_xyz 3 5]
		lappend follower_line_data_list($line_id) $xyz_i $xyz_f
	}
	
	
	foreach leader_line [array names leader_line_data_list] {
		# where 'f' means endpoint, and 'i' is the begining point of a line.
		set xyz_i_leader [lindex $leader_line_data_list($leader_line) 0]
		set xyz_f_leader [lindex $leader_line_data_list($leader_line) 1]
		
		foreach follower_line [array names follower_line_data_list] {
			# assuming that the first and last points of both follower and leader
			# lines coincide and both extend in the same direction ('i' and 'f'
			# points coincide) so we find the difference between 'i' of each line 
			# and 'f' of each line.
			set xyz_i_follower [lindex $follower_line_data_list($follower_line) 0]
			set xyz_f_follower [lindex $follower_line_data_list($follower_line) 1]
			set distance_i_i [math::linearalgebra::sub_vect  $xyz_i_follower  $xyz_i_leader]
			set distance_f_f [math::linearalgebra::sub_vect  $xyz_f_follower  $xyz_f_leader]
			set delta_x_i [lindex $distance_i_i 0]
			set delta_y_i [lindex $distance_i_i 1]
			set delta_z_i [lindex $distance_i_i 2]
			set delta_x_f [lindex $distance_f_f 0]
			set delta_y_f [lindex $distance_f_f 1] 
			set delta_z_f [lindex $distance_f_f 2] 
			set err [expr abs($delta_x_i)  + abs($delta_y_i) + abs($delta_x_f)  + abs($delta_y_f)]
			# if the summation of the difference in x and y exceeds a given tolerance, then this
			# means that either: these two lines are not a pair, or that the two lines extend in 
			# opposite directions. Assuming the latter, we will find the difference between the 
			# 'i' and 'f' points of each line, and 'f' and 'i' of each line.
			if {$err > $xytolerance} {
				set distance_i_f [math::linearalgebra::sub_vect  $xyz_i_follower  $xyz_f_leader]
				set distance_f_i [math::linearalgebra::sub_vect  $xyz_f_follower  $xyz_i_leader]
				set delta_x_i [lindex $distance_i_f 0]
				set delta_y_i [lindex $distance_i_f 1]
				set delta_z_i [lindex $distance_i_f 2]
				set delta_x_f [lindex $distance_f_i 0]
				set delta_y_f [lindex $distance_f_i 1] 
				set delta_z_f [lindex $distance_f_i 2]
				set err [expr abs($delta_x_i)  + abs($delta_y_i) + abs($delta_x_f)  + abs($delta_y_f)]
			}
			set z_err [expr max(abs($delta_z_i), abs($delta_z_f))]
			# if the error is still large, or if the z difference is over a preset tolerance then 
			# this can only mean that the two lines are NOT a pair so we do nothing for now. 
			# W "leader line: $leader_line and follower line: $follower_line were checked."
			# W "Error = $err, xy-tolerance = $xytolerance\nZ Error = $z_err, z-tolerance = $ztolerance\n"
			if {$err < $xytolerance && $z_err < $ztolerance} {
				# if the error and z difference is less than the tolerance then the two lines are
				# a pair and will be added to the list of pairs.
				lappend line_pairs "$leader_line $follower_line [lindex $leader_line_data_list($leader_line) 2]"
			}  		
		}
	}
	W "For joints, there are $num_of_leaders leader lines, $num_of_followers follower lines, and [llength $line_pairs] line pairs."
	return $line_pairs
}

proc Joint::MatchConditionIDs { {xytolerance 1.0e-4 } {ztolerance 1.0e-4} } {
	W "\n------------------------------------------"
	W "Entering function Joint::MatchConditionIDs at [clock format [clock seconds] -format %H:%M:%S]"
	W "------------------------------------------\n"
	
	
	set leader_lines [GiD_Info Conditions Line_Slab_Joint_Leader geometry]
	set follower_lines [GiD_Info Conditions Line_Slab_Joint_Follower geometry]
	
	set line_pairs_and_id [Joint::PairLinesAndID $leader_lines $follower_lines $xytolerance $ztolerance]

	array unset follower_ids 
	foreach tuple $line_pairs_and_id {
		set follower_ids([lindex $tuple 1]) [lindex $tuple 2]
	}
	
	foreach follower_line $follower_lines {
		set line_id [lindex $follower_line 1]
		set condition_id $follower_ids($line_id)
		set condition_args [lrange $follower_line 3 end]
		set condition_args [lreplace $condition_args 0 0 $line_id]
		set condition_args [lreplace $condition_args 1 1 $condition_id]
		GiD_AssignData condition Line_Slab_Joint_Follower lines $condition_args $line_id
	}
}




# The following command assumes that all conditions have been assigned an ID number, all information 
# was propagated successfully from leader to follower conditions by being paired up. This function 
# operates upon the mesh and thus expects to be called only after the mesh has been created. Similar
# to the function Fire::PairCompositeSections, this function takes a state ('fire' or 'ambient') as well
# as a tolerance for xy. Since this function is only called after the various conditions/geometric 
# entities have been paired up, it does not need to check for difference in z as that has already been
# performed.  
#
proc Joint::AssignJoints { {xytolerance 1.0e-4} } {
	WarnWinText "\n------------------------------------------------------------------------"
	WarnWinText "Entering Joint::AssignJoints" 
	W "Current time is: [clock format [clock seconds] -format %H:%M:%S]"
	WarnWinText "The tolerance for the combined xy directions is given as: $xytolerance"	
	WarnWinText "------------------------------------------------------------------------\n"
	set interval [lindex [GiD_Info intvdata num] 0]
	
	
	set leader_condition_name "Line_Slab_Joint_Leader"
	set follower_condition_name "Line_Slab_Joint_Follower"
 
	set nodes_to_collapse ""
	
	set leader_node_list [GiD_Info Conditions $leader_condition_name mesh]
	array unset leader_node_array
	foreach leader_node $leader_node_list {
		set node_id [lindex $leader_node 1] 
		set cond_id [lindex $leader_node 4]
		set args [lrange $leader_node 3 end]
		# Make sure that the item at index 0 of the condition ID is always
		# the arguments for that condition, follower by the nodes over which
		# the condition was applied. 
		if {![info exists leader_node_array($cond_id)]} {
			lappend leader_node_array($cond_id) "$args"
		}                
		lappend leader_node_array($cond_id) $node_id
	}
	
	set follower_node_list [GiD_Info Conditions $follower_condition_name mesh]
	array unset follower_node_array
	foreach follower_node $follower_node_list {
		set node_id [lindex $follower_node 1] 
		set cond_id [lindex $follower_node 4]
		set args [lrange $follower_node 3 end]
		# Make sure that the item at index 0 of the condition ID is always
		# the arguments for that condition, follower by the nodes over which
		# the condition was applied. 
		if {![info exists follower_node_array($cond_id)]} {
			lappend follower_node_array($cond_id) "$args"
		}                
		lappend follower_node_array($cond_id) $node_id
	}
		
	
	# check if the conditions match
	set leader_conditions [array names leader_node_array]
	set follower_conditions [array names follower_node_array]
	set conds_commons [FindListCommonItems $leader_conditions $follower_conditions]
	set common_conds [lindex $conds_commons 1]
	if {[lindex $conds_commons 0]} {
		W "All leader conditions are common with follower conditions."
	} else {
		set uncommon_conds [lindex $conds_commons 2]
		W "The following conditions are uncommon:\n$uncommon_conds"
		foreach bug $uncommon_conds {
			if {$bug in $leader_conditions} {
				set debug_args [lrange [lindex $leader_node_array($bug) 0] 0 1]
				set nodes_to_debug [lrange $leader_node_array($bug) 1 end]
				lappend debug_args "leader without follower"
			} else {
				set debug_args [lrange [lindex $follower_node_array($bug) 0] 0 1]
				set nodes_to_debug [lrange $follower_node_array($bug) 1 end]
				lappend debug_args "follower without leader"
			}
			foreach bugged_node $nodes_to_debug {
				GiD_IntervalData set 1
				GiD_AssignData condition Line_connectivity_condition_debug Nodes $debug_args $bugged_node
				GiD_IntervalData set $interval
			}
		}
	}

		
		# pair up nodes and apply connection condition
		array unset node_pairs
		#variable constraint_ID
		set count 1 
		foreach cond_id $common_conds {
			set args [lindex $leader_node_array($cond_id) 0]
			set condition_type [lindex $args 2]
			set leader_node_ids [lrange $leader_node_array($cond_id) 1 end]
			set follower_node_ids [lrange $follower_node_array($cond_id) 1 end]
			lappend node_pairs($cond_id) $args
			foreach leader_node $leader_node_ids {
				set xyz_leader [lindex [GiD_Info Coordinates $leader_node mesh] 0];
				foreach follower_node $follower_node_ids {
					
					set xyz_follower [lindex [GiD_Info Coordinates $follower_node mesh] 0];
					# WarnWinText "Follower node $follower_node x y z = $xyz_follower"
					set distance_vect [math::linearalgebra::sub_vect  $xyz_leader  $xyz_follower]
					set delta_x [lindex $distance_vect 0]
					set delta_y [lindex $distance_vect 1]
					if {abs($delta_x) < 1e-5 && abs($delta_y) < 1e-5} {
						if {$leader_node == $follower_node} {
							W "Warning: leader and follower nodes have the same ID: $leader_node"
							set debug_args [lrange $args 0 1]
							lappend debug_args "identical leader and follower"
							GiD_IntervalData set 1
							GiD_AssignData condition Line_connectivity_condition_debug Nodes $debug_args $leader_node
							GiD_IntervalData set $interval
						} else {
							lappend node_pairs($cond_id) "$leader_node $follower_node"
						}
					}
				}
			}
			
			if {$condition_type == "rigid_link"} {
					foreach pair [lrange $node_pairs($cond_id) 1 end] {
							set cond_args "$Joint::constraint_ID [lindex $args 3]"
							GiD_IntervalData set 1
							GiD_AssignData condition Point_Rigid_link_master_node Nodes $cond_args [lindex $pair 0]
							GiD_AssignData condition Point_Rigid_link_slave_nodes Nodes $cond_args [lindex $pair 1]
							GiD_IntervalData set $interval							
							set Joint::constraint_ID [expr $Joint::constraint_ID + 1]
					}
			} elseif {$condition_type == "equal_DOF"} {
					foreach pair [lrange $node_pairs($cond_id) 1 end] {
							GiD_IntervalData set 1
							set cond_args_follower "$Joint::constraint_ID [lrange $args 4 9]"
							GiD_AssignData condition Point_Equal_constraint_master_node Nodes "$Joint::constraint_ID 0 0" [lindex $pair 0]
							GiD_AssignData condition Point_Equal_constraint_slave_nodes Nodes $cond_args_follower [lindex $pair 1]
							GiD_IntervalData set $interval							
							set Joint::constraint_ID [expr $Joint::constraint_ID + 1]
					}
			
			} elseif {$condition_type == "common_nodes"} {
					foreach pair [lrange $node_pairs($cond_id) 1 end] {
							set nodes_to_collapse [LappendUnique $nodes_to_collapse $pair] 
					}
			} elseif {$condition_type == "finite"} {
			W  "condition type is finite!!!"
					foreach pair [lrange $node_pairs($cond_id) 1 end] {
							GiD_IntervalData set 1
						
							GiD_Mesh create element append Line 2 "[lindex $pair 1] [lindex $pair 0]" [lindex $args 10]
							
							GiD_IntervalData set $interval							
							set Joint::constraint_ID [expr $Joint::constraint_ID + 1]
					}
			
			}
			
		}
	if {[llength $nodes_to_collapse] == 0} {
		W "nodes_to_collapse: none"
	} else {
		W "nodes_to_collapse: $nodes_to_collapse"
		set cmd [join "GiD_Process Mescape Utilities Collapse Nodes" " "]
		foreach node $nodes_to_collapse {
			lappend cmd $node
		}
		lappend cmd escape escape
		eval $cmd
	}
}



