set line_list [GiD_Info Mesh elements linear]
set problem_lines ""
foreach line $line_list {

# WarnWinText "[GiD_Mesh get element $line]" 
	set info [GiD_Info list_entities Elements $line]
	set index [expr [lsearch $info "material:"] + 1]
	if {[lindex $info $index] > 0} {

	} else {
		# WarnWinText "Element $line has material: '[lindex $info $index]', which is a problem."
		lappend problem_lines $line
		
	}
}
WarnWinText "These elements have incorrect materials assigned to them:\n$problem_lines"
# GiD_Process 'View SelectEntities Elements {*}$problem_lines
foreach bug $problem_lines {
GiD_Mesh delete element $bug
}