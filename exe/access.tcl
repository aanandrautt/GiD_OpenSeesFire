set condition_name "Line_Composite_Section_Slab"
set line_list [GiD_Info Conditions $condition_name geometry]
array unset line_id_list

foreach line_instance $line_list {
	set id [lindex $line_instance 1]
	set args [lrange $line_instance 3 end]
	WarnWinText "arguments: $args"
	set line_id_list($id) $args
}

set surf_condition_name "Surface_Composite_Section"
set material_list [GiD_Info material]
GiD_UnAssignData condition $surf_condition_name surfaces all

foreach line_id [array names line_id_list] {
	# set associated_surf_ids [GetLineHigherEntities $line_id]
	set associated_surf_ids [GidUtils::GetEntityHigherEntities line $line_id] 
	set width 0
	foreach surf $associated_surf_ids {
		set xyz_surf [GidUtils::GetEntityCenter surface $surf]
		set xyz_line [GidUtils::GetEntityCenter line $line_id]
		set distance_vect [math::linearalgebra::sub_vect  $xyz_line  $xyz_surf]
		WarnWinText "distance vector is: $distance_vect"
		set distance [expr 2*[math::linearalgebra::norm_two $distance_vect]]
		WarnWinText "Which has the distance: $distance"
		set width [expr $width + $distance]
	}
	WarnWinText "giving line $line_id a width of $width"
	GiD_AssignData condition $surf_condition_name surfaces $line_id_list($line_id)  $associated_surf_ids
	set info [GiD_Info list_entities surface $associated_surf_ids]
	# WarnWinText "surface info:\n$info"
	set element_type_index [lsearch $info "material:"]
	WarnWinText "index = $element_type_index"
	set element_type_num [lindex $info [expr $element_type_index +1]]
	WarnWinText "getting material: $element_type_num"
	set element_type_name [lindex [.central.s info materials] [expr $element_type_num-1]]
	WarnWinText "Which corresponds to $element_type_name"
	set element_type_info [GiD_Info materials $element_type_name]
	WarnWinText "and has the info:$element_type_info"
	
	set section_type_num [lsearch $element_type_info "Type#MAT#(Section_Force-Deformation,User_Materials)"]
	WarnWinText "section type appears as index $section_type_num"
	set section_type_name [lindex $element_type_info  [expr $section_type_num+1]]
	# set section_type_num [lindex $info 6]
	WarnWinText "getting section: $section_type_name"
	# set section_type_name [lindex [.central.s info materials] [expr $section_type_num-1]]
	# WarnWinText "Which corresponds to $section_type_name"
	set section_type_info [GiD_Info materials $section_type_name]
	WarnWinText "and has the info:$section_type_info"
	set slab_thickness_index [lsearch $section_type_info "Slab_thickness#UNITS#"]
	set slab_thickness [lindex $section_type_info [expr $slab_thickness_index + 1]]
	WarnWinText "slab thickness has the index $slab_thickness_index and thickness = $slab_thickness"
	
	set slab_protection_index [lsearch $section_type_info "Protection_thickness#UNITS#"]
	set slab_protection_thickness [lindex $section_type_info [expr $slab_protection_index + 1]]
	WarnWinText "slab protection thickness has the index $slab_protection_index and protection thickness = $slab_protection_thickness"
	
	set slab_protection_mat_index [lsearch $section_type_info "protection_material#CB#(1,2,3)"]
	set slab_protection_mat [lindex $section_type_info [expr $slab_protection_mat_index + 1]]
	WarnWinText "slab protection material has the index $slab_protection_mat_index and protection material = $slab_protection_mat"	
	
	
}

