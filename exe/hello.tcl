proc commands {} {
 W "getMat, fixQuadConnectivity, calcVonMises, PProcess::FactorFireTime {factor {addition 0}}, Transform::PopulateTagsArray"
}
proc getMat { entity_ID {entity_type Lines} } {
	set entity_info [GiD_Info list_entities $entity_type $entity_ID]
	set material_ID_index [expr [lsearch $entity_info "material:"] + 1]
	set material_ID [lindex $entity_info $material_ID_index]
	set index [expr $material_ID - 1]
	W [lindex [GiD_Info materials] $index]

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