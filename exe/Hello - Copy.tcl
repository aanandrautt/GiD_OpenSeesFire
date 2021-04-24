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
	
	set elems_w_cond ""
	set elems_wo_cond ""
	set read_time 0
	set condition_name "Line_Gas_Temperatures Line_Composite_Section_Beam" 
	set composite_line_list [GiD_Info Conditions Line_Composite_Section_Slab geometry]
	
	foreach cond $condition_name {
		set elem_list [GiD_Info Conditions $cond mesh]
		foreach elem $elem_list {
			set elem_ID [lindex $elem 1]
			set cond_ID [lindex $elem 4]
			if {"$elem_ID -1" in $PProcess::elem_cond_list} {
				W "the item "$elem_ID -1" is in the elem cond list."
				# set PProcess::elem_cond_list [lremove $PProcess::elem_cond_list [lsearch $PProcess::elem_cond_list]]
			}
			lappend elems_w_cond $elem_ID
			W "element $elem_ID has condition $cond with ID: $cond_ID."
			W "and it has the props: [GiD_Mesh get element $elem_ID]\n"
			lappend PProcess::elem_cond_list "$elem_ID $cond_ID"
			if {!$read_time} {
				PProcess::GetHTTime $cond_ID
				PProcess::GetStructTime
				set read_time 1
			}
		}	
	}
	W "all elems: [lsort -integer [GiD_Mesh list -element_type Line element]]"
	W "cond elem: [lsort -integer $elems_w_cond]"
	foreach item [FindListCommonItems $elems_w_cond "[GiD_Mesh list -element_type Line element]"] {
		W [lsort -integer $item]
	}
	set elems_wo_cond [lindex [FindListCommonItems $elems_w_cond [GiD_Mesh list -element_type Line element]] 2]
	W "Elements with condition are: [lsort -integer $elems_w_cond]"
	W "Elements without condition are: [lsort -integer $elems_wo_cond]"
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
	set last_time_offset 0
	foreach time_step $PProcess::struct_time {
		lappend output_string $time_step
		foreach elem_cond $PProcess::elem_cond_list {
			set elem [lindex $elem_cond 0]
			set cond [lindex $elem_cond 1]
			if {$cond > 0} {
				if {$time_step in $common_time} {
					set result [PProcess::GetHTResults $cond $time_step $last_time_offset]
					set last_time_offset [lindex $result 5]
					lappend output_string {*}[lrange $result 0 4]
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
}

proc PProcess::GetStructTime { } {
	set res_dir [file join [OpenSees::GetProjectPath] "OpenSees" "Node_displacements.out"]
	set file_handle [open $res_dir r]
	while {[gets $file_handle line] >= 0} {
		lappend PProcess::struct_time [lindex $line 0]
	}
}


proc PProcess::GetHTResults { ID time offset } {
	set HT_res_dir [file join [OpenSees::GetProjectPath] "Records" "Thermal_load" "BeamColumn$ID.dat"]
	set file_handle [open $HT_res_dir r]
	seek $file_handle $offset
	# set result ""
	while {[gets $file_handle line] >= 0 && [lindex $line 0] <= $time} {
		W "HT file time is: [lindex $line 0], requiredtime is: $time"
		if {[lindex $line 0] == $time} {
		W "time is okay. line length is: [llength $line]"
			if {[expr [llength $line] - 1] == 15} {
			W "stepping into here"
				set web [PProcess::Mean [lrange $line 1 5]]
				set botFlange [PProcess::Mean [lrange $line 6 10]]
				set topFlange [PProcess::Mean [lrange $line 11 15]]
				set section_avg [PProcess::Mean [lrange $line 1 15]]
				set bot_top_diff [expr $botFlange - $topFlange]
				W "file is telling us: [tell $file_handle]"
				return "$botFlange $web $topFlange $section_avg $bot_top_diff [tell $file_handle]"
				W "Current results is $result"
				return $result
			} elseif {[expr [llength $line] - 1] == 21} { 
			W "stepping into the wrong one"
				return -1
			} elseif {[lindex $line 0] > 100} {
				return -1
				continue
			} else {
			W "stepping into a worse one"
				return -1
			}
		}
	}
	W "could not find time = $time"
	# return ERROR
	# return "[lrepeat 5 0] 0"
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