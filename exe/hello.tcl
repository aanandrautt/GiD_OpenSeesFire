# set line_list [GiD_Info Mesh elements linear]
set line_list [lsort -integer [GiD_Info Mesh Elements Linear]]
set problem_lines ""
set materials_list [GiD_Info materials]
array unset materials_array

# W "line list is $line_list"
foreach line $line_list {
# WarnWinText "[GiD_Mesh get element $line]" 
	set info [GiD_Info list_entities Elements $line]
	set index [expr [lsearch $info "material:"] + 1]
	
	if {$index > 0} {
		set mat_index [expr [lindex $info $index] - 1]
	} else {
		set mat_index -1
	}
	if {$mat_index > 0} {
		set material_name [lindex $materials_list $mat_index]
		# W "Element $line has material index: $mat_index, which has name: '$material_name'"
		set materials_array($material_name) [LappendUnique  materials_array($material_name) $line]
	} else {
		# W "Element $line has material: '[lindex $info $index]', which is a problem."
		lappend problem_lines $line
	}
}

foreach mat [array names materials_array] {
	W [GiD_Info materials $mat]
	# W $mat
}
WarnWinText "These elements have incorrect materials assigned to them:\n$problem_lines"
# GiD_Process 'View SelectEntities Elements {*}$problem_lines
# foreach bug $problem_lines {
# GiD_Mesh delete element $bug
# }
#W [foreach elem [GiD_Info materials(Beam-Column_Elements)] {W "$elem\n"}]