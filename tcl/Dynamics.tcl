namespace eval Dynamics {

}
proc Dynamics::AutoMass { } {
	set autoMass [GiD_AccessValue get gendata Activate_auto_mass]
	if $autoMass {
		Dynamics::AssignNodalMass	
	}
}
proc Dynamics::CalcNodalMass { entity_ID {entity_type Elements} } {
	set mass_density [GiD_AccessValue get material [Dynamics::getMat $entity_ID $entity_type 0] Mass_density]
	set temp [GidConvertValueUnit $mass_density]
	set temp [ParserNumberUnit $temp theMassDensity DensityUnit]
	set nodal_areas [Dynamics::getElemNodalAreas $entity_ID]
	set thickness [Dynamics::getThickness [Dynamics::getSec $entity_ID]]
	set mass_per_area [expr $theMassDensity*$thickness]
	return [Dynamics::ScaleVector $mass_per_area $nodal_areas]
}
proc Dynamics::AssignNodalMass {} {
	set mass_Unit 1kg
	set temp [GidConvertValueUnit $mass_Unit]
	set temp [ParserNumberUnit $temp dummy mass_Unit]
	array unset node_list
	set list_of_quad_elems [GiD_Mesh list -element_type Quadrilateral element]
	foreach quad $list_of_quad_elems {
		set nodes [GiD_Mesh get element $quad connectivities]
		set masses [Dynamics::CalcNodalMass $quad]
		for {set i 0} {$i < 4} {incr i} {
			set node [lindex $nodes $i]
			if {[info exists node_list($node)]} {
				set node_list($node) [expr [lindex $masses $i] + $node_list($node)]
			} else {
				set node_list($node) [lindex $masses $i]
			}
		}
	}
	
	foreach node [array names node_list] {
		set mass $node_list($node)$mass_Unit
		set arguments [list ":" $mass $mass $mass 0$mass_Unit 0$mass_Unit 0$mass_Unit]
		GiD_AssignData condition Point_Mass nodes $arguments $node
	}
}

proc Dynamics::getElemArea { elem_ID } {
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


proc Dynamics::getElemNodalAreas { elem_ID } {
	set connectivity [GiD_Mesh get element $elem_ID connectivities]
	set xyz "";
	foreach node $connectivity {
		lappend xyz [GiD_Mesh get node $node coordinates]
	}
	set vec12 [Dynamics::ScaleVector 0.5 [math::linearalgebra::sub_vect [lindex $xyz 1] [lindex $xyz 0]]]
	set vec14 [Dynamics::ScaleVector 0.5 [math::linearalgebra::sub_vect [lindex $xyz 3] [lindex $xyz 0]]]
	
	set vec21 [Dynamics::ScaleVector 0.5 [math::linearalgebra::sub_vect [lindex $xyz 0] [lindex $xyz 1]]]
	set vec23 [Dynamics::ScaleVector 0.5 [math::linearalgebra::sub_vect [lindex $xyz 2] [lindex $xyz 1]]]
	
	set vec32 [Dynamics::ScaleVector 0.5 [math::linearalgebra::sub_vect [lindex $xyz 1] [lindex $xyz 2]]]
	set vec34 [Dynamics::ScaleVector 0.5 [math::linearalgebra::sub_vect [lindex $xyz 3] [lindex $xyz 2]]]
	
	set vec41 [Dynamics::ScaleVector 0.5 [math::linearalgebra::sub_vect [lindex $xyz 0] [lindex $xyz 3]]]
	set vec43 [Dynamics::ScaleVector 0.5 [math::linearalgebra::sub_vect [lindex $xyz 2] [lindex $xyz 3]]]
	
	set node1A [math::linearalgebra::norm_two [math::linearalgebra::crossproduct $vec12 $vec14]]
	set node2A [math::linearalgebra::norm_two [math::linearalgebra::crossproduct $vec23 $vec21]]
	set node3A [math::linearalgebra::norm_two [math::linearalgebra::crossproduct $vec34 $vec32]]
	set node4A [math::linearalgebra::norm_two [math::linearalgebra::crossproduct $vec41 $vec43]]
	
	return "$node1A $node2A $node3A $node4A"
}

proc Dynamics::ScaleVector { scale vect } {
 return [math::linearalgebra::scale_vect $scale $vect]
}

proc Dynamics::getMat { entity_ID {entity_type Lines} { display 0 }} {
	set entity_info [GiD_Info list_entities $entity_type $entity_ID]
	set material_ID_index [expr [lsearch $entity_info "material:"] + 1]
	set material_ID [lindex $entity_info $material_ID_index]
	set index [expr $material_ID - 1]
	set Mat [lindex [GiD_Info materials] $index]
	if {$display} {
		W $Mat
	}
	return $Mat
}

proc Dynamics::getSec { entity_ID {entity_type Elements} { display 0 }} {
	set section [GiD_AccessValue get material [getMat $entity_ID $entity_type 0] Type]
	if {$display} {
		W $section
	}
	return $section
}

proc Dynamics::getThickness { section } {
	set section_type [GiD_AccessValue get material $section Section:]
	if {$section_type == "LayeredShellSteel"} {
		set t [GiD_AccessValue get material $section Thickness]
		set temp [GidConvertValueUnit $t]
		set temp [ParserNumberUnit $temp thickness dummy]
		return $thickness
	} elseif {$section_type == "LayeredShell"} {
		set t [GiD_AccessValue get material $section Slab_thickness]
		set temp [GidConvertValueUnit $t]
		set temp [ParserNumberUnit $temp thickness dummy]
		return $thickness
	} else {
		W "cannot get the thickness of section $section because it is of type $section_type."
	}
}