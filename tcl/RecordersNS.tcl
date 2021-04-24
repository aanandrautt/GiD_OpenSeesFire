namespace eval Recorders {
}
proc Recorders::GetQuadElems { } {
	return [lsort -integer [GiD_Mesh list -element_type Quadrilateral element]]
}
proc Recorders::ReturnStar { } {
	return *
} 
