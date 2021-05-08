namespace eval Transform {
	namespace export ResetArray
	variable transformation_tags
	variable current_transform_tag
	variable flattenedTransforms
	proc ResetArray { } {
		variable transformation_tags
		set Transform::current_transform_tag 7
		set Transform::flattenedTransforms ""
		array unset Transform::transformation_tags
		array set transformation_tags {0 "1 2 3 4 5 6"}
	}
}

proc Transform::PopulateTagsArray { } { 
	WarnWinText "\n----------------------------------------------------------"
	WarnWinText "Entering function: Transform::PopulateTagsArray"
	WarnWinText "----------------------------------------------------------\n"
	
	ResetArray
	Transform::PrintTransformTags
	set lineElemsMats [GiD_Info materials(Beam-Column_Elements)]
	foreach elem $lineElemsMats { 
		set elem_rotation [GiD_AccessValue get material $elem local_axis_rotation]
		set elem_transform [GiD_AccessValue get material $elem Geometric_transformation#CB#(Linear,P-Delta,Corotational)]
		
		if {[info exists Transform::transformation_tags($elem_rotation)]} {
			set tag_list $Transform::transformation_tags($elem_rotation)
		} else {
			set tag_list "-1 -1 -1 -1 -1 -1"
		}
		if {$elem_transform == "Linear"} {
			set start_index 0
			if {[lindex $tag_list $start_index] < 0} {
				set tag_list [lreplace $tag_list $start_index [expr $start_index + 1] $Transform::current_transform_tag [expr $Transform::current_transform_tag + 1]]
				set Transform::current_transform_tag [expr $Transform::current_transform_tag + 2]
			} 
		} elseif {$elem_transform == "P-Delta"} {
			set start_index 2
			if {[lindex $tag_list $start_index] < 0} {
				set tag_list [lreplace $tag_list $start_index [expr $start_index + 1] $Transform::current_transform_tag [expr $Transform::current_transform_tag + 1]]
				set Transform::current_transform_tag [expr $Transform::current_transform_tag + 2]
			} 
		} elseif {$elem_transform == "Corotational"} {
			set start_index 4
			if {[lindex $tag_list $start_index] < 0} {
				set tag_list [lreplace $tag_list $start_index [expr $start_index + 1] $Transform::current_transform_tag [expr $Transform::current_transform_tag + 1]]
				set Transform::current_transform_tag [expr $Transform::current_transform_tag + 2]
			} 
		} else {
			W "ERROR: transformation type unknown for material $elem"
		}
		set Transform::transformation_tags($elem_rotation) $tag_list
	}
	Transform::CalcTransforms
	Transform::FlattenTransforms
	set num [Transform::GetNumOfTransforms]
	W $num
	for {set i 1} {$i <= $num} {incr i} {
		W [Transform::ReturnTransformSyntax $i]
	}

	
}

proc Transform::PrintTransformTags { } {
	W "current tag: $Transform::current_transform_tag"
	W "Printing array:"
	foreach angle [array names Transform::transformation_tags] {
		W "Angle $angle: $Transform::transformation_tags($angle)"
	}
	W "\n" 
}

proc Transform::CalcTransforms { } {
	set pi 3.1415926535897931
	foreach transform_angle [array names Transform::transformation_tags] {
		variable transformation_tags
		set angle_rad [expr $transform_angle*$pi/180]
		set cosine [expr cos($angle_rad)]
		set sine [expr sin($angle_rad)]
		set vertical "[Transform::round [expr -1*$cosine]] [Transform::round [expr -1*$sine]] 0"
		set nonvertical "0 0 1"
		lappend Transform::transformation_tags($transform_angle) $vertical $nonvertical
	}
}

proc Transform::round { a_number {decimals 3} } {
	set multiplier [expr 1e$decimals]
	return [expr double(round($multiplier*$a_number))/$multiplier]
}

proc Transform::GetNumOfTransforms { } {
	return [expr $Transform::current_transform_tag - 1]
}
proc Transform::FlattenTransforms {  } {
	variable flattenedTransforms
	foreach transform_angle [array names Transform::transformation_tags] { 
		for {set i 0} {$i < 6} {incr i} {
			if {$i < 2} {
				set type Linear
			} elseif {$i < 4} {
				set type PDelta
			} else {
				set type Corotational
			}
			
			set index [lindex $Transform::transformation_tags($transform_angle) $i]
			if {$index > 0} {
				if {fmod($index,2)} {
					lappend Transform::flattenedTransforms "geomTransf $type $index  [lindex $Transform::transformation_tags($transform_angle) 6]"
				} else {
					lappend Transform::flattenedTransforms "geomTransf $type $index  [lindex $Transform::transformation_tags($transform_angle) 7]"
				}
			}
		}
	}
	set Transform::flattenedTransforms [lsort -integer -index 2 $Transform::flattenedTransforms]
}
proc Transform::PrintFlattenedTransform { } {
	foreach pair $Transform::flattenedTransforms {
		W $pair 
		W "of which part 1 is: [lindex $pair 0], and part 2 is: [lindex $pair 1]\n"
	}
}
proc Transform::ReturnTransformSyntax { transform_tag } {
	set transform_index [expr $transform_tag - 1]
	if {!fmod($transform_index,2)} { 
		set syntax "[lindex $Transform::flattenedTransforms $transform_index]; #Vertical" 
	} else { 
		set syntax "[lindex $Transform::flattenedTransforms $transform_index]; #Non-vertical" 
	}
	return $syntax
}

proc Transform::ReturnTransformTag { original_tag angle } {
	return [lindex $Transform::transformation_tags($angle) [expr $original_tag - 1]]
}
