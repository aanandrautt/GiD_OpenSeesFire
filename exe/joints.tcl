namespace eval Joint {
	variable condition_ID 1
	variable joint_ID 1
	variable constraint_ID [expr $Fire::constraint_ID + 1]
}

proc Joint::ResetIDs { } {
	set Joint::condition_ID 1
	set Joint::joint_ID 1
	set Joint::constraint_ID [expr $Fire::constraint_ID + 1]
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
	W "There are $num_of_leaders leader lines, $num_of_followers follower lines, and [llength [array names line_pairs]] line pairs."
	W $line_pairs
	return $line_pairs
}

proc Joint::MatchJointIDs { {xytolerance 1.0e-4 } {ztolerance 1.0e-4} } {
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