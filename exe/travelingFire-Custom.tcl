proc start {{nodes 1} {t_max 2000} {dT 5}} {
	W "Getting fire properties for all time steps."
	array set fire_vars {}
	for {set t  0} {$t <= $t_max} {incr t $dT} {
		 set fire_vars($t) "[list [getFireCentroid $t]] [getFireSize $t] [getMaxTemp [getFireSize $t]]" 
		# W "centroid: [getFireCentroid $t]\nsize:[getFireSize $t]\nMax temp:[getMaxTemp [getFireSize $t]]\n\n"
		# W "fire variables at time $t (centroid, size, max temp): $fire_vars($t)\n\n"
	}
	W "Got fire properties for all time steps."
	if {$nodes == 1} { 
		W "Getting temperatures of all nodes."
		array set node_results {}
		set all_nodes [GiD_Mesh List node]
		foreach time_step [array names fire_vars] {
		set node_results($time_step) ""
			set centroid [lindex $fire_vars($time_step) 0]
			set size [lindex $fire_vars($time_step) 1]
			set max_temp [lindex $fire_vars($time_step) 2]
			W "here"
			foreach node $all_nodes {
				set xyz [GiD_Mesh get node $node coordinates]
				set dist [getDistance $centroid $xyz]
				set temp [getTemp $dist $size $max_temp]
				lappend node_results($time_step) $temp $temp $temp
			}
		}
		W "writing output file."
		set initial_dir [pwd]
		set res_dir [file join [OpenSees::GetProjectPath] "OpenSees" ]
		cd $res_dir
		set out_file_handle [open Node_displacements.out w+]
		foreach node [lsort -integer [array names node_results]] {
			puts $out_file_handle "$node $node_results($node)"
		}
		close $out_file_handle
	} elseif {$nodes == 2} {

		PProcess::GetStructTime
		
		array set fire_vars_2 {}
		foreach t $PProcess::struct_time {
			set fire_vars_2($t) "[list [getFireCentroid $t]] [getFireSize $t] [getMaxTemp [getFireSize $t]]" 
		}
		array set node_results {}
		set all_nodes [GiD_Mesh List node]
		foreach time_step $PProcess::struct_time {
		set node_results($time_step) ""
			set centroid [lindex $fire_vars_2($time_step) 0]
			set size [lindex $fire_vars_2($time_step) 1]
			set max_temp [lindex $fire_vars_2($time_step) 2]
			foreach node $all_nodes {
				set xyz [GiD_Mesh get node $node coordinates]
				set dist [getDistance $centroid $xyz]
				set temp [getTemp $dist $size $max_temp]
				lappend node_results($time_step) $temp
			}
		}
		W "writing output file."
		set initial_dir [pwd]
		set res_dir [file join [OpenSees::GetProjectPath] "OpenSees" ]
		cd $res_dir
		set out_file_handle [open Node_temperatures.out w+]
		foreach node [lsort -integer [array names node_results]] {
			puts $out_file_handle "$node $node_results($node)"
		}
		close $out_file_handle
			
	
	}	else {
		set initial_dir [pwd]
	}
	W "Getting temperatures of thermocouples."
	# producing temperature files for thermocouples 
	set res_dir [file join [OpenSees::GetProjectPath] "Records"]
	cd $res_dir
	
	array unset thermocouple_data
	set condition_name "Line_Gas_Temperatures Surface_Gas_Temperatures Line_Composite_Section_Slab"
	foreach cond $condition_name {
		set geometric_entity_list [GiD_Info Conditions $cond geometry]
		foreach geometric_entity $geometric_entity_list {
			set geometric_entity_id [lindex $geometric_entity 1]
			set condition_id [lindex $geometric_entity 4]
			set xyz ""
			if {$cond == "Surface_Gas_Temperatures"} {
				set xyz [GidUtils::GetEntityCenter surface $geometric_entity_id]
			} else {
				set xyz [GidUtils::GetEntityCenter line $geometric_entity_id]
			}
			set thermocouple_data($condition_id) $xyz
		}
	}
	set sorted_thermocouples [lsort -integer [array names thermocouple_data]]
	
	foreach thermocouple_ID $sorted_thermocouples {
		set thermocouple_file_handle [open "FDS$thermocouple_ID.dat" w+]
		set xyz $thermocouple_data($thermocouple_ID)
		foreach time_step [lsort -integer [array names fire_vars]] {
			set centroid [lindex $fire_vars($time_step) 0]
			set size [lindex $fire_vars($time_step) 1]
			set max_temp [lindex $fire_vars($time_step) 2]
			
			set dist [getDistance $centroid $xyz]
			set temp [getTemp $dist $size $max_temp]
			puts $thermocouple_file_handle "$time_step $temp"
		}
		close $thermocouple_file_handle
	}
	W "Finished printing temperatures of all thermocouples."
	cd $initial_dir
	
	
	
	W "Finished generating traveling fire results."
}



proc getDistance { fireCentroid xyz } {
	# W "centroid: $fireCentroid, and xyz: $xyz"
	set vect_to_pt [math::linearalgebra::sub $fireCentroid $xyz]
	set dist_to_pt [math::linearalgebra::norm_two $vect_to_pt]
	return $dist_to_pt
}

proc quadraticEq { x {a 1} {b 0} {c 0} } {
	return [expr $a*pow($x,2.0) + $b*$x + $c]
}

proc linearEq { x {a 1} {b 1} } {
	return [expr $a*$x + $b]
}
proc getFireCentroid { t } {
	set fireVelocity 0.001; # m/s
	set x 0
	set y [expr max(min(-1 + $fireVelocity*$t,1),-1)]
	set z 1
	return "$x $y $z"
} 
proc getFireSize { t } {
	return [quadraticEq $t -4e-7 0.0012 0.1]
}
proc getMaxTemp { size } {
	set factor [expr min(1,pow($size,2) + 0.5)]
	return [expr 1000*$factor]
}
proc getTemp { distance fire_size max_temp } {
	set ratio [expr $distance/$fire_size]
	if {$ratio <= 1} {
		# the point is inside the direct fire region
		return [expr (-0.2*$ratio + 1)*$max_temp]
	} else {
		# the point is outside the fire region
		return [expr max((exp(1-$ratio) - 0.2)*$max_temp,20)]
	}
}