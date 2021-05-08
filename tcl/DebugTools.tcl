namespace eval DebugTools {
} 
# set nodes_information_array
proc DebugTools::ListAbsDiff { list1 list2 } {
	if {[llength $list1] == [llength $list2]} {
		set answer ""
		for {set i 0} {$i < [llength $list1]} {incr i} {
		        lappend answer [expr [lindex $list1 $i] - [lindex $list2 $i]]
		}
		set answer_sum 0
		for {set i 0} {$i < [llength $list1]} {incr i} {
		        set answer_sum [expr $answer_sum + abs([lindex $answer $i])]
		}
		return $answer_sum
	} else {
		return TCL_ERROR
	}
}

proc DebugTools::PerformTest { lastNode } {
	set nodes_paired_list ""

	set nodes_list [lsort -integer [GiD_Mesh list node 1:$lastNode] ]
	set problem_size [llength $nodes_list]
	set current_node 0

	foreach node $nodes_list {
		set nodes_information_array($node) [lrange [GiD_Mesh get node $node] 1 3]
	}

	foreach node $nodes_list {
		incr current_node
		W "node $current_node out of $problem_size"
		set node_tuple $node
		foreach other_node $nodes_list {
		        if {$node != $other_node} {
		                set diff [DebugTools::ListAbsDiff $nodes_information_array($node) $nodes_information_array($other_node)]
		                if {$diff < 1e-6} {
		                        lappend node_tuple $other_node
		                }
		        }
		}
		lappend nodes_paired_list $node_tuple
	}
	foreach pair $nodes_paired_list {
		W $pair
	}
	return $nodes_paired_list
}

proc WriteTestToFile { lastNode } {
	set GiDProjectDir [OpenSees::GetProjectPath]
	set fileHandle [open "$GiDProjectDir/OpenSees/Colocational_nodes.txt" w+]
	set fileHandle2 [open "$GiDProjectDir/OpenSees/Suspect_nodes.txt" w+]
	set node_pairs [DebugTools::PerformTest $lastNode]
	foreach pair $node_pairs {
		puts $fileHandle $pair
		if {[llength $pair] > 2} {
		        puts $fileHandle2 $pair
		}
		
	}
	
	close $fileHandle
	close $fileHandle2
}

proc DebugTools::GetBadNodesInfo {} {
	set GiDProjectDir [OpenSees::GetProjectPath]
	set fileHandle [open "$GiDProjectDir/OpenSees/Suspect_nodes.txt" r]
	set file_lines [split [read $fileHandle] "\n"]
	close $fileHandle
	set i 1
	set nodes_to_collapse ""
	foreach line $file_lines {
		set node_ID [lindex $line 0]
		set layer_list [split [lindex [GiD_Mesh get node $node_ID] 0] "//"]
		set layer [lindex $layer_list end]
		set parent_layer [lindex $layer_list 2]
		W "line $i, node $node_ID. In layer: $layer under $parent_layer"
		lappend nodes_to_collapse $node_ID
		incr i
	}
	
}