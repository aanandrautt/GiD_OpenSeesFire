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
	set section [GiD_AccessValue get material [getMat $entity_ID $entity_type 0] Section]
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
		set temp [GidConvertValueUnit $property];
		set temp [ParserNumberUnit $temp theProperty PropertyUnit]
	}]
	 if {$ok} {
		# we don't need an error - simply the property does not have a unit
		set theProperty $property
		set PropertyUnit ""
	}
	
	if {$display} {
		W "the property is: $theProperty, and its unit is: $PropertyUnit"
	}
	return "$theProperty$PropertyUnit $theProperty $PropertyUnit"
} 

##############################getting parametric protection thicknesses###################
proc getGeometryCond { condition_name { entity_ID -1}} {
	if {$entity_ID < 0} {
		return [GiD_Info conditions $condition_name geometry]
	} else {
		return [lindex [GiD_Info conditions $condition_name geometry $entity_ID] 0]
	}
}

proc getCondProp { condition_name property_index entity_ID } {
	set cond_info [getGeometryCond $condition_name $entity_ID] 
	
	 return [lindex $cond_info [expr $property_index + 3]]
}

proc getMatData { material_name material_property } {
	return [lrange [GiD_AccessValue get material $material_name $material_property] 2 end]
}

proc getProtectionThickness { entity_ID } {
	set protection_mat [getCondProp Parametric_SFRM_material 1 $entity_ID]
	return [lrange [getMatData $protection_mat thickness] 2 end]
}

proc getParametricThicknesses { entity_ID } {
	set parametric_mat [getCondProp Parametric_SFRM_material 0 $entity_ID]
	return [lrange [getMatData $parametric_mat thicknesses] 2 end]
}
##############################getting parametric protection thicknesses###################
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

proc fixQuadConnectivityGlobal { } {
	# Ensures that all quad elements are connected to nodes counter-clockwise starting with
	# node with lowest x and y (bottom left corner)
	set list_of_quad_elems [GiD_Mesh list -element_type Quadrilateral element]
	W "Fixing quad element connectivity..."
	foreach quad_elem $list_of_quad_elems {
		# W "Quad element: $quad_elem"
		array unset node_coordinates
		set original_nodes [lrange [GiD_Mesh get element $quad_elem] end-3 end]
		foreach node_ $original_nodes {
			set xyz [GiD_Mesh get node $node_ coordinates]
			lappend node_coordinates($node_) {*}$xyz
		}
		#
		#	top nodes 
		#	_________________
		#	|				|
		#	|				|
		#------------------------------
		#	|				|
		#	|				|
		#	_________________
		#	bottom nodes
		set y_ordered_nodes [SortListByIndices $original_nodes [SortArrayByValue node_coordinates $original_nodes 1]]
		set bottom_nodes [lrange $y_ordered_nodes 0 1]
		set top_nodes [lrange $y_ordered_nodes 2 end]
		#------------------------------
		#	|		|		|
		#	|		|		|
		#	________|_________
		#	first	|	second
		#	node	|	node
		#  first nodes
		set first_nodes [SortListByIndices $bottom_nodes [SortArrayByValue node_coordinates $bottom_nodes 0]]
		
		#	last nodes
		#	fourth		third
		#	node	|	node
		#	________|_________
		#	|		|		|
		#	|		|		|
		#------------------------------
		set last_nodes [SortListByIndices $top_nodes [SortArrayByValue node_coordinates $top_nodes 0] 1]
		set ordered_nodes [concat $first_nodes $last_nodes]
		GiD_Mesh edit element $quad_elem Quadrilateral 4 $ordered_nodes
		
	}
	W "Finished fixing quad connectivities."
}

proc fixQuadConnectivityElement { element_id } {
	# Ensures that given quad element is connected to nodes counter-clockwise starting with
	# node with lowest x and y (bottom left corner)
	set list_of_quad_elems [GiD_Mesh list -element_type Quadrilateral element $element_id]
	W "Fixing quad element connectivity..."
	foreach quad_elem $list_of_quad_elems {
		# W "Quad element: $quad_elem"
		array unset node_coordinates
		set original_nodes [lrange [GiD_Mesh get element $quad_elem] end-3 end]
		W "Original nodes: $original_nodes"
		foreach node_ $original_nodes {
			set xyz [GiD_Mesh get node $node_ coordinates]
			lappend node_coordinates($node_) {*}$xyz
			W "node $node_ (x,y,z) = $node_coordinates($node_)"
		}
		#
		#	top nodes 
		#	_________________
		#	|				|
		#	|				|
		#------------------------------
		#	|				|
		#	|				|
		#	_________________
		#	bottom nodes
		set y_ordered_nodes [SortListByIndices $original_nodes [SortArrayByValue node_coordinates $original_nodes 1]]
		W "Y-ordered nodes: $y_ordered_nodes"
		set bottom_nodes [lrange $y_ordered_nodes 0 1]
		set top_nodes [lrange $y_ordered_nodes 2 end]
		W "Bottom nodes: $bottom_nodes\nTop nodes: $top_nodes"
		#------------------------------
		#	|		|		|
		#	|		|		|
		#	________|_________
		#	first	|	second
		#	node	|	node
		#  first nodes
		set first_nodes [SortListByIndices $bottom_nodes [SortArrayByValue node_coordinates $bottom_nodes 0]]
		
		#	last nodes
		#	fourth		third
		#	node	|	node
		#	________|_________
		#	|		|		|
		#	|		|		|
		#------------------------------
		set last_nodes [SortListByIndices $top_nodes [SortArrayByValue node_coordinates $top_nodes 0] 1]
		W "First nodes: $first_nodes\nLast nodes: $last_nodes"
		set ordered_nodes [concat $first_nodes $last_nodes]
		W "Ordered nodes: $ordered_nodes"
		GiD_Mesh edit element $quad_elem Quadrilateral 4 $ordered_nodes
	}
}								
#set y_ordered_nodes [SortListByIndices $original_nodes [SortArrayByValue passed_array     keys_to_sort     			]
 #set y_ordered_nodes [SortListByIndices $original_nodes [SortArrayByValue node_coordinates [array names node_coordinates] 1]]
proc SortArrayByValue { passed_array keys_to_sort { value_index 0 }} {
	# sorts the given keys_to_sort of an array based on the value_index
	# the array holds at value_index for each key. Returns a sorted index
	#---------------------------------------------------------------------
	# an array is a collection of variables so must use this
	# command to pass it to a function
	upvar $passed_array an_array
	set order ""
	set values ""
	foreach key $keys_to_sort {
		lappend values [lindex $an_array($key) $value_index]
	}
	return [lsort -real -indices -increasing $values]
}

proc SortListByIndices { a_list indices { reverse 0 }}	{
	# sorts the given list based on a given list of indices. Basically like
	# fancy indexing in python: a_list[2, 3, 1]
	# reverse returns the reverse of the given index. Needed for sorting
	# nodes without further complicating SortArrayByValue
	#---------------------------------------------------------------------
	set sorted_list ""
	foreach index $indices {
		lappend sorted_list [lindex $a_list $index]
	}
	if {$reverse} {
		return [lreverse $sorted_list] 
	} else {
		return $sorted_list
	}
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


# Currently ONLY works for very simply I sections!
proc CreateHTDatFile { {directory 0} } {
	if {$directory == 0} {
		set directory [file join [OpenSees::GetProjectPath] "Records"] 
	}
	append directory  "/HT.dat"
	W "Writing HT data to: $directory"
	set fileHandle [open $directory  w+]
	# print header
	puts $fileHandle "ID composite slab protection_material tf tw h b dp dps ts bs plt FireExposure tFinal dt hfire hamb {section_material}"
	
	foreach cond "Line_Gas_Temperatures" {
		# The following function is very important, but should not be called from
		# here, but rather from the function to create the many HT files after 
		# each transition to different fire protection layout
		# Fire::AssignBeamProtection
		array unset HT_data
		set geometric_entity_list [GiD_Info Conditions $cond geometry]
		foreach entity $geometric_entity_list {
			set condition_args [lrange $entity 3 end]
			set entity_ID [lindex $entity 1]
			set ID [lindex $condition_args 1]

			# get fire protection properties
			
			set dp [lindex [GidConvertValueUnit [lindex $condition_args 5]] 0]
			set protection_material [lindex $condition_args 4]
			if {![string is double $protection_material]} {
			set protection_material [GiD_AccessValue get material $protection_material protection_material]
			}
			# get section properties
			set tf [lindex [GidConvertValueUnit [lindex [getSecProp $entity_ID Flange_thickness_tf Lines 0] 0]] 0]
			set tw [lindex [GidConvertValueUnit [lindex [getSecProp $entity_ID Web_thickness_tw Lines 0] 0]] 0]
			set h [lindex [GidConvertValueUnit [lindex [getSecProp $entity_ID Height_h Lines 0] 0]] 0]
			set b [lindex [GidConvertValueUnit [lindex [getSecProp $entity_ID Flange_width_b Lines 0] 0]] 0]
			
			set composite 0
			set slab 0
			set dps 0
			set ts 0
			set bs 0
			set plt 0
			if {$cond == "Gas_Temperatures" } {
				set composite 0
				set slab 0
				set dps 0
				set ts 0
				set bs 0
				set plt 0
			}
			set FireExposure [GiD_AccessValue get gendata Exposure_type]
			if {$FireExposure == "standard_fire"} {
				set FireExposure 1
			} elseif {$FireExposure == "Hydrocarbon"} {
				set FireExposure 2
			} elseif {$FireExposure == "FDS"} {
				set FireExposure 3
			} else {
				set FireExposure 4
			}
			
			set tFinal [lindex [GidConvertValueUnit [GiD_AccessValue get gendata fire_duration]] 0]
			set dt [lindex [GidConvertValueUnit [GiD_AccessValue get gendata HT_time_step]] 0]
			
			set override_default_h [GiD_AccessValue get gendata override_default_h]
			if {$override_default_h} {
				set hfire [GiD_AccessValue get gendata convective_h_fire]
				set hamb [GiD_AccessValue get gendata convective_h_ambient]
			} else {
				set hfire [lindex $condition_args 3]
				set hamb [GiD_AccessValue get gendata convective_h_ambient]
			}
			set section_material [GiD_AccessValue get material [getSec $entity_ID Lines 0] heat_transfer]
			if {$section_material == "carbon_steel"} {
				set section_material 1
			} else {
				set section_material 2
			}						
	
			
			#W "ID composite slab protection_material tf tw h b dp dps ts bs plt FireExposure tFinal dt hfire hamb {section_material}"
			puts $fileHandle "$ID\t$composite\t$slab\t$protection_material\t$tf\t$tw\t$h\t$b\t$dp\t$dps\t$ts\t$bs\t$plt\t$FireExposure\t$tFinal\t$dt\t$hfire\t$hamb\t$section_material"
		}
	}
	
	close $fileHandle
}

proc GetParametricFP {} {
	set fp_materials [GiD_Info materials(Fire_Protection_Materials)]
	set parametric_fp ""
	foreach material $fp_materials {
		if {[GiD_AccessValue get material $material Material] == "parametric_SFRM"} {
				lappend parametric_fp $material
			}					
	}
	return $parametric_fp
}

proc GetPFPMaterialAndElements { } {
	array unset parametric_data
	foreach cond "Line_Parametric_SFRM" {
		set geometric_entity_list [GiD_Info Conditions $cond geometry]
		foreach entity_info $geometric_entity_list {
			set entity_ID [lindex $entity_info 1]
			set parametric_FP [lindex $entity_info 3]
			lappend parametric_data($parametric_FP) $entity_ID
		}
	
	}
	
	set list_of_PFP_materials ""
	set list_of_PFP_material_elements ""
	set list_of_PFP_info ""
	foreach pfp_mat [array names parametric_data] {
		lappend list_of_PFP_materials $pfp_mat
		lappend list_of_PFP_material_elements $parametric_data($pfp_mat)
		lappend list_of_PFP_info "$pfp_mat $parametric_data($pfp_mat)"
	}
	
	#TODO: CHANGE THE ARRAY TO A LIST: {{key, value}, {key, value},... 
	# but only do this AFTER you finish the loops because using the
	# array allows us to keep the material name unique
	set result ""
	lappend result $list_of_PFP_materials; # index 0 returns only materials list
	lappend result $list_of_PFP_material_elements ; # index 1 returns only elements list
	lappend result $list_of_PFP_info ; # index 2 returns list of lists each containing both materials and elements
	return $result
}
}

proc GetMaxNumOfParametricFPThicknesses { parametric_material_list } {
	set max_num_thicknesses 0
	foreach pfp_mat $parametric_material_list {
		set thicknesses [GiD_AccessValue get material $pfp_mat thicknesses]
		set max_num_thicknesses [expr max([lindex $thicknesses 1], $max_num_thicknesses)]
	}
	return $max_num_thicknesses
}
proc GetPFPProps { pfp_mat } {
	set thicknesses [lrange [GiD_AccessValue get material $pfp_mat thicknesses] 2 end]
	set mat_id [GiD_AccessValue get material $pfp_mat protection_material]
	return [list $mat_id "$thicknesses"]
}
proc BuildCasesDirectoryStructure { } { 
	set num_fires [GiD_AccessValue get gendata num_of_fire_cases]
	set list_of_pfps [lindex  [GetPFPMaterialAndElements] 0]
	set max_num_thicknesses [GetMaxNumOfParametricFPThicknesses $list_of_pfps]
	set max_num_thicknesses [expr max(1, $max_num_thicknesses)]
	set num_of_cases [expr $max_num_thicknesses*$num_fires]
	set directories ""
	for {set i 0} {$i < $num_of_cases} {incr i} {
		lappend directories [file join [OpenSees::GetProjectPath] "Records" "cases" "case-$i" ] 
	}
	foreach directory $directories {
		file mkdir $directory
	}
	return $directories
}
proc AppendListUntilLength { a_list length } {
	set list_len [llength $a_list]
	if {$list_len == $length} {
		return $a_list
	} elseif {$list_len > $length} {
		W "WARNING: a_list passed has $list_len but will be truncated to $length elements."
		return [lrange $a_list 0 $length]
	}
	set last_elem [lindex $a_list end]
	for {set i 0 } {$i < [expr $length - $list_len]} {incr i} {
		lappend a_list $last_elem
	}
	return $a_list
}
proc CreatePFPLayouts { } {
	set PFP_materials [lindex [GetPFPMaterialAndElements] 0]
	set max_num_thicknesses [GetMaxNumOfParametricFPThicknesses $PFP_materials]
	set pfp_layouts ""
	set PFP_materials_elements [lindex [GetPFPMaterialAndElements] 2]
	foreach pfp_mat_info $PFP_materials_elements {
		set pfp_mat [lindex $pfp_mat_info 0]
		set elements [lrange $pfp_mat_info 1 end]
		set mat_id [lindex [GetPFPProps $pfp_mat] 0]
		set thicknesses [lindex [GetPFPProps $pfp_mat] 1]
		set thicknesses [AppendListUntilLength $thicknesses $max_num_thicknesses]
		lappend pfp_layouts [list $pfp_mat $mat_id "$thicknesses" "$elements"]
	}
	return $pfp_layouts
}


# MATERIAL: Standard_SFRM
# COMMENT: \n\tPredefined SFRM material properties with temperature\n\tdependent values for density, conductivity, and heat\n\tcapacity. 
# COMMENT: \n\tMaterials are:\n\t1. CAFCO-300\n\t2. Carboline Type-5MD\n\t3. Tyfo WR-AFP\n\t4. Carboline\n\t5. Monokote MK-5\n\n\t\Details of material properties in section 5.3.3 of:\n\tOrabi, MA (2021) State of the Art Large Scale Simulation of Buildings in Fire: The Case of WTC7\n\n
# QUESTION: Material:#CB#(Standard_SFRM)
# VALUE: Standard_SFRM
# QUESTION: protection_material#CB#(1,2,3,4,5)
# VALUE: 5
# TKWIDGET: TK_UpdateInfoBar
# END MATERIAL


# BOOK: Fire_Protection

# CONDITION: Line_SFRM
# CONDTYPE: over lines
# CONDMESHTYPE: over body elements
# CANREPEAT: no
# COMMENT: Apply a specific thickness of SFRM material.\n
# QUESTION: SFRM_Material#MAT#(Fire_Protection_Materials,User_Materials)
# VALUE: Standard_SFRM
# QUESTION: thickness#UNITS#
# VALUE: 0mm
# TKWIDGET: TK_ActiveIntervalinLoads
# END CONDITION

# pfp_layouts = [list $pfp_mat $mat_id "$thicknesses" "$elements"]

proc CreateParametricHTFiles { pfp_layouts } {
	set directories [BuildCasesDirectoryStructure]
	W [lindex $directories 0]
	set num_cases [llength $directories]
	set PFP_materials [lindex [GetPFPMaterialAndElements] 0]
	set num_pfp_materials [llength $PFP_materials]
	set max_num_thicknesses [GetMaxNumOfParametricFPThicknesses $PFP_materials]
	set num_fires [GiD_AccessValue get gendata num_of_fire_cases] 
	for {set j 0} {$j < $num_fires} {incr j} {
		for {set i 0} {$i < $max_num_thicknesses } {incr i} {
			W "Creating data for case: [expr $j*$max_num_thicknesses + $i] out of $num_cases"
			set directory [lindex $directories [expr $j*$max_num_thicknesses + $i]]
			
			
			foreach layout $pfp_layouts {
				
				# create a standard fire protection material
				set pfp_mat_name [lindex $layout 0]
				append pfp_mat_name "_[expr $j*$max_num_thicknesses + $i]"
				# if a material with the same name exists:
				if {[catch [GiD_Info material $pfp_mat_name]]} {
					GiD_CreateData delete material $pfp_mat_name
				}
				
				GiD_CreateData create material Standard_SFRM $pfp_mat_name "Standard_SFRM [lindex $layout 1]"
				set thicknesses [lindex $layout 2]
				set thickness [lindex $thicknesses $i]mm
				set condition_data "$pfp_mat_name $thickness"
				
				set elements [lindex $layout 3]
				GiD_AssignData condition Line_SFRM lines $condition_data $elements
			}
			Fire::AssignBeamProtection
			CreateHTDatFile $directory
		}
	}

}
