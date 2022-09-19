namespace eval PProcess {
	variable elem_cond_list
	variable time 
	variable struct_time 
	namespace export ResetLists
	proc ResetLists { } {
		set PProcess::elem_cond_list ""
		set PProcess::time ""
		variable struct_time ""
	}
}
 
proc PProcess::ListBeamConditionIDs { } {
	ResetLists 
	set current_interval [lindex [GiD_Info intvdata num] 0]
	set num_of_intervals [lindex [GiD_Info intvdata num] 1]
	set elems_w_cond ""
	set elems_wo_cond ""
	set read_time 0
	set condition_name "Line_Gas_Temperatures Line_Composite_Section_Beam" 
	for {set interval 1} {$interval <= $num_of_intervals} {incr interval} {
		GiD_IntervalData set $interval
		foreach cond $condition_name {
			set elem_list [GiD_Info Conditions $cond mesh]
			foreach elem $elem_list {
				set elem_ID [lindex $elem 1]
				set cond_ID [lindex $elem 4]
				lappend elems_w_cond $elem_ID
				lappend PProcess::elem_cond_list "$elem_ID $cond_ID"
				if {!$read_time} {
					PProcess::GetHTTime $cond_ID
					PProcess::GetStructTime
					set read_time 1
				}
			}	
		}
	}
	GiD_IntervalData set $current_interval
	set elems_wo_cond [lindex [FindListCommonItems $elems_w_cond [GiD_Mesh list -element_type Line element]] 2]
	foreach elem $elems_wo_cond {
		lappend PProcess::elem_cond_list "$elem -1"
	}
	set PProcess::elem_cond_list [lsort -integer -index 0 $PProcess::elem_cond_list]
	W "Element condition list: $PProcess::elem_cond_list"
	W "Time: $PProcess::time"
	W "Struct. Time: $PProcess::struct_time"
}

proc PProcess::WriteHTOutput { } {
	set HT_res_dir [file join [OpenSees::GetProjectPath] "Records" "Thermal_load" ]
	set output_dir [file join [OpenSees::GetProjectPath] "OpenSees" "DispBeamColumn_temperatures.out"]
	set file_handle [open $output_dir w+]
	set common_time [lindex [FindListCommonItems $PProcess::time $PProcess::struct_time] 1]
	set output_string ""
	foreach time_step $PProcess::struct_time {
		lappend output_string $time_step
		foreach elem_cond $PProcess::elem_cond_list {
			set elem [lindex $elem_cond 0]
			set cond [lindex $elem_cond 1]
			if {$cond > 0} {
				if {$time_step in $common_time} {
					lappend output_string {*}[PProcess::GetHTResults $cond $time_step]
				} else {
					lappend output_string {*}[lrepeat 5 0]
				}
			} else {
				lappend output_string {*}[lrepeat 5 0]
			}
		}
		puts $file_handle $output_string
		W "Wrote data for time: $time_step"
		set output_string ""
	}
	close $file_handle
}	

proc PProcess::GetHTTime { ID } {
	set HT_res_dir [file join [OpenSees::GetProjectPath] "Records" "Thermal_load" "BeamColumn$ID.dat"]
	set file_handle [open $HT_res_dir r]
	while {[gets $file_handle line] >= 0} {
		lappend PProcess::time [lindex $line 0]
	}
	close $file_handle
}

proc PProcess::GetStructTime { } {
	set res_dir [file join [OpenSees::GetProjectPath] "OpenSees" "Node_displacements.out"]
	set file_handle [open $res_dir r]
	while {[gets $file_handle line] >= 0} {
		lappend PProcess::struct_time [lindex $line 0]
	}
	close $file_handle
}


proc PProcess::GetHTResults { ID time } {
	set HT_res_dir [file join [OpenSees::GetProjectPath] "Records" "Thermal_load" "BeamColumn$ID.dat"]
	set file_handle [open $HT_res_dir r]
	while {[gets $file_handle line] >= 0 && [lindex $line 0] <= $time} {
		if {[lindex $line 0] == $time} {
			if {[expr [llength $line] - 1] == 15} {
				set web [PProcess::Mean [lrange $line 1 5]]
				set botFlange [PProcess::Mean [lrange $line 6 10]]
				set topFlange [PProcess::Mean [lrange $line 11 15]]
				set section_avg [PProcess::Mean [lrange $line 1 15]]
				set bot_top_diff [expr $botFlange - $topFlange]
				close $file_handle
				return "$botFlange $web $topFlange $section_avg $bot_top_diff"
			} elseif {[expr [llength $line] - 1] == 25} { 
				set web [PProcess::Mean [lrange $line 1 5]]
				set botFlange [PProcess::Mean [lrange $line 6 10]]
				set topFlange [PProcess::Mean [lrange $line 11 15]]
				set section_avg [PProcess::Mean [lrange $line 1 25]]
				set bot_top_diff [expr $botFlange - $topFlange]
				close $file_handle
				return "$botFlange $web $topFlange $section_avg $bot_top_diff"
			}
		}
	}
	W "could not find time = $time"
	return [lrepeat 5 0]
}
proc PProcess::Mean { a_list } {
	set length [llength $a_list]
	set sum 0
	foreach item $a_list {
		set sum [expr $sum + $item]
	}
	return [expr $sum/$length]
}

proc PProcess::WritePostFile { } {
	set output_dir [file join [OpenSees::GetProjectPath] "OpenSees" "Beam_temps.out"]

}

proc PProcess::WriteFakeNodalDispFile { } {
	set output_dir [file join [OpenSees::GetProjectPath] "OpenSees" "Node_displacements.out"]
	set file_handle [open $output_dir w+]
	set num_o_nodes [GiD_Info Mesh NumNodes]
	set node_zeros [lrepeat $num_o_nodes 0]
	foreach time_step $PProcess::time {
		puts $file_handle "$time_step $node_zeros"
		W "Wrote fake displacements for time: $time_step"
	}
	close $file_handle
}

proc PProcess::FactorFireTime { factor {addition 0} } {
	set initial_dir [pwd]
	set HT_res_dir [file join [OpenSees::GetProjectPath] "Records" "Thermal_load" ]
	cd $HT_res_dir
	set all_files [glob *.dat]
	foreach fileName $all_files {
		set file_handle [open $fileName r]
		set temp_file_handle [open $fileName.temp w+]
		while {[gets $file_handle line] >= 0} {
			set new_time [expr [lindex $line 0]*$factor + $addition]
			set new_line [lreplace #$line 0 0 $new_time]
			puts $temp_file_handle $new_line
		}
		close $file_handle
		close $temp_file_handle
		file rename -force $fileName.temp $fileName
	}
	cd $initial_dir
}

proc PProcess::FactorFireTimeCases { factor {addition 0} } {
	set cases [lindex [GetCases] 0]
	foreach case $cases {
		PProcess::FactorFireTimeForCase $factor $addition $case
	}
}

proc PProcess::FactorFireTimeForCase { factor {addition 0} {case "case-0"}} {
	set initial_dir [pwd]
	set HT_res_dir [file join [OpenSees::GetProjectPath] "Records" "cases" "$case" "Thermal_load" ]
	cd $HT_res_dir
	set all_files [glob *.dat]
	foreach fileName $all_files {
		set file_handle [open $fileName r]
		set temp_file_handle [open $fileName.temp w+]
		while {[gets $file_handle line] >= 0} {
			set new_time [expr [lindex $line 0]*$factor + $addition]
			set new_line [lreplace #$line 0 0 $new_time]
			puts $temp_file_handle $new_line
		}
		close $file_handle
		close $temp_file_handle
		file rename -force $fileName.temp $fileName
	}
	cd $initial_dir
}
