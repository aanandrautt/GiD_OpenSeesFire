set nodes {}

proc readFileList { fileName } {
	set alist ""
	set in_file_handle [open $fileName r+]
	while {[gets $in_file_handle line] >= 0} {
			lappend alist $line
	}
	close $in_file_handle
	return $alist
}
proc getCoordinates { nodeList } {
	foreach node $nodeList {
		W [GiD_Mesh get node $node coordinates] 
	}
}