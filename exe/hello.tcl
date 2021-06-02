proc getMat { entity_ID {entity_type Lines} } {
	set entity_info [GiD_Info list_entities $entity_type $entity_ID]
	set material_ID_index [expr [lsearch $entity_info "material:"] + 1]
	set material_ID [lindex $entity_info $material_ID_index]
	set index [expr $material_ID - 1]
	W [lindex [GiD_Info materials] $index]

}