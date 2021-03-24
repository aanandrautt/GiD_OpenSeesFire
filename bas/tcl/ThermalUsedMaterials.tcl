proc ThermalLoadTag { Condition SecTag } {

	append LoadTag "$Condition" "$SecTag"
	return $LoadTag
	
}

proc ThermalClearUsedMaterials { } {

	global ThermalUsedMaterialsList
	set ThermalUsedMaterialsList " "

	return 0
}

proc ThermalAddUsedMaterials { MatID } {

	global ThermalUsedMaterialsList
	lappend ThermalUsedMaterialsList $MatID

	return 0
}

proc ThermalCheckUsedMaterials { MatID } {

	global ThermalUsedMaterialsList
	set pos [lsearch $ThermalUsedMaterialsList $MatID]

	return $pos
}

proc ThermalRemoveUsedMaterials { MatID } {

	global ThermalUsedMaterialsList
	set pos [lsearch $ThermalUsedMaterialsList $MatID]
	set ThermalUsedMaterialsList [lreplace $ThermalUsedMaterialsList $pos $pos]

	return $pos
}
