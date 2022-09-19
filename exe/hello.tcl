proc commands {} {
 W "getMat, getSec, getProp fixQuadConnectivity, calcVonMises\n, Transform::PopulateTagsArray, FactorResultsTime { dT }"
 W "FindElementWOMat, FindElem { ID },\nPProcess::FactorFireTime {factor {addition 0}},\nPProcess::FactorFireTimeCases { factor {addition 0} },\nPProcess::FactorFireTimeForCase { factor {addition 0} {case \"case-0\"}}"
}
proc getMat { entity_ID {entity_type Lines} { display 1 }} {
	set entity_info [GiD_Info list_entities $entity_type $entity_ID]
	set material_ID_index [expr [lsearch $entity_info "material:"] + 1]
	set material_ID [lindex $entity_info $material_ID_index]
	set index [expr $material_ID - 1]
	set Mat [lindex [GiD_Info materials] $index]
	if {$display} {
		if {$Mat != ""} {
			W $Mat
		} else {
			W "$entity_type $entity_ID does not have a material assigned to it."
		}
	}
	return $Mat
}
proc getSec { entity_ID {entity_type Lines} { display 1 }} {
	set section [GiD_AccessValue get material [getMat $entity_ID $entity_type 0] Type]
	if {$display} {
		W $section
	}
	return $section
}

proc getNumOfElem { elemName } {
	set mat_ID [lsearch [GiD_Info materials] "$elemName"]
	set n [llength [GiD_Mesh list -material [expr $mat_ID + 1] element]]
	return $n
}

proc getProp { entity_ID prop {entity_type Lines} { display 1 }} {
	set property [GiD_AccessValue get material [getMat $entity_ID $entity_type 0] $prop]
		
	set temp [GidConvertValueUnit $property]
	set temp [ParserNumberUnit $temp theProperty PropertyUnit]
	
	
	if {$display} {
		W "the property is: $theProperty, and its unit is: $PropertyUnit"
	}
	return "$theProperty$PropertyUnit $theProperty $PropertyUnit"
}

proc getSecProp { entity_ID prop {entity_type Lines} { display 1 } } {
	set sec [getSec $entity_ID $entity_type 0]
	set property [GiD_AccessValue get material $sec $prop]
	set ok [catch {
		set temp [GidConvertValueUnit $property]
		set temp [ParserNumberUnit $temp theProperty PropertyUnit]
	}]
	 if {$ok} {
		W "Error caught!"
		set theProperty $property
		set PropertyUnit ""
	}
	
	if {$display} {
		W "the property is: $theProperty, and its unit is: $PropertyUnit"
	}
	return "$theProperty$PropertyUnit $theProperty $PropertyUnit"
} 

proc fixQuadConnectivity {} {
	set list_of_quad_elems [GiD_Mesh list -element_type Quadrilateral element]
	W "Fixing quad element connectivity..."
	foreach quad_elem $list_of_quad_elems {
		# W "Quad element: $quad_elem"
		
		set original_nodes [lrange [GiD_Mesh get element $quad_elem] end-3 end] 
		# W "Has nodes:$original_nodes"
		
		set xyz1 [GiD_Mesh get node [lindex $original_nodes 0] coordinates]
		set x1 [lindex $xyz1 0]
		set y1 [lindex $xyz1 1]
		set z1 [lindex $xyz1 2]
		
		set xyz2 [GiD_Mesh get node [lindex $original_nodes 1] coordinates]
		set x2 [lindex $xyz2 0]
		set y2 [lindex $xyz2 1]
		set z2 [lindex $xyz2 2]
		
		set xyz4 [GiD_Mesh get node [lindex $original_nodes 3] coordinates]
		set x4 [lindex $xyz4 0]
		set y4 [lindex $xyz4 1]
		set z4 [lindex $xyz4 2]
		
		
		set L12	[expr sqrt(pow($x2 - $x1,2)+pow($y2 - $y1,2)+pow($z2 - $z1,2))]
		set L14	[expr sqrt(pow($x4 - $x1,2)+pow($y4 - $y1,2)+pow($z4 - $z1,2))]
		
		
		set v12x [expr ($x2-$x1)/$L12]
		set v12y [expr ($y2-$y1)/$L12]
		set v12z [expr ($z2-$z1)/$L12]
		# W "L12 = $L12, v12x = $v12x, v12y = $v12y, and v12z = $v12z"
		set v14x [expr ($x4-$x1)/$L14]
		set v14y [expr ($y4-$y1)/$L14]
		set v14z [expr ($z4-$z1)/$L14]
		
		# W "L14 = $L14, v14x = $v14x, v14y = $v14y, and v14z = $v14z"
		set modified 0
		# vector 1-2 to positive z
		if {abs($v12x) < 1e-3 && abs($v12y) < 1e-3 && abs($v12z-1) < 1e-3} {
			set new_nodes "[lindex $original_nodes 3] [lindex $original_nodes 0] [lindex $original_nodes 1] [lindex $original_nodes 2]"
			GiD_Mesh edit element $quad_elem Quadrilateral 4 $new_nodes
			set modified 1
		# vector 1-2 to positive z
		} elseif {abs($v12x) < 1e-3 && abs($v12y) < 1e-3 && abs($v12z+1) < 1e-3} {
			set new_nodes "[lindex $original_nodes 1] [lindex $original_nodes 2] [lindex $original_nodes 3] [lindex $original_nodes 0]"
			GiD_Mesh edit element $quad_elem Quadrilateral 4 $new_nodes
			set modified 1
			
		} elseif {abs($v14x) < 1e-3 && abs($v14y) < 1e-3 && abs($v14z+1) < 1e-3} {
			set new_nodes "[lindex $original_nodes 2] [lindex $original_nodes 3] [lindex $original_nodes 0] [lindex $original_nodes 1]"
			GiD_Mesh edit element $quad_elem Quadrilateral 4 $new_nodes
			set modified 1
			
		} else { W "No adjustment required for element $quad_elem.\n\n"}
		if {$modified} {W "Adjusted element $quad_elem.\n\n" }
	}
	W "Finished fixing quad element connectivity. All quad elements may now be post processed without issue."
}
proc calcVonMises { layer } {
	set GPs "1 2 3 4"
	foreach GP $GPs {
		W "Calculating VM stresses for layer $layer, GP $GP"
		set input_file [file join [OpenSees::GetProjectPath] "OpenSees" "ShellDKGQ_stress_Layer$layer\_GP$GP.out"]
		set output_file [file join [OpenSees::GetProjectPath] "OpenSees" "ShellDKGQ_VM_stress_Layer$layer\_GP$GP.out"]
		
		set in_file_handle [open $input_file r+]
		set out_file_handle [open $output_file w+]
		
		
		while {[gets $in_file_handle line] >= 0} {
			set output_line ""
			set line_length [llength $line]
			set i 0
			while {$i < $line_length} {
				if {$i == 0} {
					lappend output_line [lindex $line 0]
					incr i 1
				}
				
				set stresses [lrange $line $i [expr $i+2]]

				set s11 [lindex $stresses 0]
				set s22 [lindex $stresses 1]
				set s12 [lindex $stresses 2]
				# W "i = $i"
				# W "stresses are: $stresses"
				# W "s11 = $s11, s22 = $s22, and s12 = $s12\n"
				set q [expr sqrt(0.5*(pow($s11-$s22,2)+pow($s22,2)+pow(-$s11,2)+6*pow($s12,2)))]
				lappend output_line $q
				incr i 5
			}
			puts $out_file_handle $output_line
		}
		close $in_file_handle
		close $out_file_handle
	}
	W "Finished calculating VM stresses for layer $layer.\n"
}


proc getElemArea { elem_ID } {
	set connectivity [GiD_Mesh get element $elem_ID connectivities]
	set xyz "";
	foreach node $connectivity {
		lappend xyz [GiD_Mesh get node $node coordinates]
	}
	set vec1 [math::linearalgebra::sub_vect [lindex $xyz 1] [lindex $xyz 0]]
	set vec2 [math::linearalgebra::sub_vect [lindex $xyz 2] [lindex $xyz 1]]
	set vec3 [math::linearalgebra::sub_vect [lindex $xyz 3] [lindex $xyz 0]]
	set vec4 [math::linearalgebra::sub_vect [lindex $xyz 2] [lindex $xyz 3]]
	
	set triangle1 [math::linearalgebra::scale_vect 0.5 [math::linearalgebra::crossproduct $vec1 $vec2]]
	set triangle2 [math::linearalgebra::scale_vect 0.5 [math::linearalgebra::crossproduct $vec4 $vec3]]
	set rectangle [math::linearalgebra::add_vect $triangle1 $triangle2]
	
	return [math::linearalgebra::norm_two $rectangle]
}

proc getElemNodalAreas { elem_ID } {
	set connectivity [GiD_Mesh get element $elem_ID connectivities]
	set xyz "";
	foreach node $connectivity {
		lappend xyz [GiD_Mesh get node $node coordinates]
	}
	set vec12 [ScaleVector 0.5 [math::linearalgebra::sub_vect [lindex $xyz 1] [lindex $xyz 0]]]
	set vec14 [ScaleVector 0.5 [math::linearalgebra::sub_vect [lindex $xyz 3] [lindex $xyz 0]]]
	
	set vec21 [ScaleVector 0.5 [math::linearalgebra::sub_vect [lindex $xyz 0] [lindex $xyz 1]]]
	set vec23 [ScaleVector 0.5 [math::linearalgebra::sub_vect [lindex $xyz 2] [lindex $xyz 1]]]
	
	set vec32 [ScaleVector 0.5 [math::linearalgebra::sub_vect [lindex $xyz 1] [lindex $xyz 2]]]
	set vec34 [ScaleVector 0.5 [math::linearalgebra::sub_vect [lindex $xyz 3] [lindex $xyz 2]]]
	
	set vec41 [ScaleVector 0.5 [math::linearalgebra::sub_vect [lindex $xyz 0] [lindex $xyz 3]]]
	set vec43 [ScaleVector 0.5 [math::linearalgebra::sub_vect [lindex $xyz 2] [lindex $xyz 3]]]
	
	set node1A [math::linearalgebra::norm_two [math::linearalgebra::crossproduct $vec12 $vec14]]
	set node2A [math::linearalgebra::norm_two [math::linearalgebra::crossproduct $vec23 $vec21]]
	set node3A [math::linearalgebra::norm_two [math::linearalgebra::crossproduct $vec34 $vec32]]
	set node4A [math::linearalgebra::norm_two [math::linearalgebra::crossproduct $vec41 $vec43]]
	
	return "$node1A $node2A $node3A $node4A"
}

proc ScaleVector { scale vect } {
 return [math::linearalgebra::scale_vect $scale $vect]
}

proc FactorResultsTime { dT } {
	set initial_dir [pwd]
	set res_dir [file join [OpenSees::GetProjectPath] "OpenSees" ]
	cd $res_dir
	set all_files [glob *.out]
	foreach fileName $all_files {
		set file_handle [open $fileName r]
		W "Working on $fileName"
		set temp_file_handle [open $fileName.temp w+]
		set prev_time 0
		while {[gets $file_handle line] >= 0} {
			set current_time [lindex $line 0]
			# W "previous time is: $prev_time\nprevious time + timestep: [expr $prev_time + $dT - 1e-15]\ncurrent time is: $current_time"
			if {[expr $current_time] >= [expr $prev_time + $dT - 1e-15] || $current_time == 0 || $current_time == 1} {
				# W "\nFound that current time is larger than previous time + timestep."
				# W "Writing line for time: $current_time"
				set new_line $line
				puts $temp_file_handle $new_line
				set prev_time $current_time
				# W "set previous time to: $prev_time"
			}

			# W "\n\n"
		}
		close $file_handle
		close $temp_file_handle
		file rename -force $fileName.temp $fileName
		W "Finished working on $fileName"
	}
	W "All .out files have been modified to conform to a time step of $dT."
	cd $initial_dir
}
proc closeAll {} {
	foreach chan [file channels] {close $chan}
}
proc FindElementWOMat { } {
	foreach elem [lsort -integer [GiD_Mesh list -element_type Line element]] {
		if {[getMat $elem element 0] == ""} {
			W "Line $elem does not have a material."
		}
	} 
	foreach elem [lsort -integer [GiD_Mesh list -element_type Quadrilateral element]] {
		if {[getMat $elem element 0] == ""} {
			W "Quad $elem does not have a material."
		}
	}
	W "Checked all line and quad elements." 
}

proc FindElem { ID } {
	
	set info [GiD_Mesh get element $ID]
	if {$info != ""} {
		set layer [lindex $info 0]
		set type [lindex $info 1]
		set n_nodes [lindex $info 2]
		set nodes [lrange $info 3 end]
		set xyz ""
		foreach node $nodes {
			lappend xyz [GiD_Mesh get node $node coordinates]
		}
		W "Element $ID is located in layer: $layer"
		W "it is a $type element, and has $n_nodes nodes"
		W "these nodes are: $nodes"
		W "And they have the following coorindates:"
		foreach coord $xyz {
			W $coord
		} 
	} else { 
		W "element $ID info could not be ertrieved.\nDouble-check that element exists."
	}
}

proc GetCases { {print 0 } } {
	set GiDProjectDir [OpenSees::GetProjectPath]
	set cases_data_file [file join "$GiDProjectDir" "Records" "cases.dat" ]
	set cases_data_file_handle [open $cases_data_file r]
	set first_line 1; # boolean to ignore the first line
	set cases ""
	set HT_times ""
	set FE_times ""
	set FE_time_steps ""
	while { [gets $cases_data_file_handle line] >= 0 } {
		if { !$first_line } {
			lappend cases [lindex $line 0]
			lappend HT_times [lindex $line 1]
			lappend FE_times [lindex $line 2]
			lappend FE_time_steps [lindex $line 3]
			if $print {
				W "case: [lindex $line 0], HT time: [lindex $line 1], FE time: [lindex $line 2], FE time step: [lindex $line 3]"
			}
		} else {
			set first_line 0
		}
	}
	close $cases_data_file_handle
	
	return [list "$cases" "$HT_times" "$FE_times" "$FE_time_steps"]
}

proc GetDuplicateMasterNodes {} {
	# Message in line number 263. Error: For each Equal constraint ID group, only one master node can be selected.
	set interval [lindex [GiD_Info intvdata num] 0]
	
	set equal_dof_master_nodes [GiD_Info Conditions Point_Equal_constraint_master_node mesh]
	set rigid_link_master_nodes [GiD_Info Conditions Point_Rigid_link_master_node mesh]
	set master_nodes [concat $equal_dof_master_nodes $rigid_link_master_nodes]
	array unset master_nodes_arr
	array unset duplicate_master_cond
	
	foreach node_data $master_nodes {
		set node_id [lindex $node_data 1]
		set cond_id [lindex $node_data 3]
		lappend master_nodes_arr($cond_id) $node_id
	}
	foreach cond_id [array names master_nodes_arr] {
		if { [llength $master_nodes_arr($cond_id)] > 1 } {
			lappend duplicate_master_cond($cond_id) {*}$master_nodes_arr($cond_id)
		}
	}
	GiD_IntervalData set 1
	set i 1
	foreach cond_id [array names duplicate_master_cond] {
		set debug_info "$i $cond_id"
		lappend debug_info "double master node condition"
		GiD_AssignData condition Line_connectivity_condition_debug Nodes $debug_info $duplicate_master_cond($cond_id)
		set i [expr $i + 1]
	}
	GiD_IntervalData set $interval
}
