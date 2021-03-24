namespace eval Fire {
}

proc Fire::GenerateLineTCouples {} {
	set condition_name {Line_Gas_Temperatures}
	set line_list [GiD_Info Conditions $condition_name geometry]
	array unset geometric_entities_ids
	foreach geometric_entity $line_list {
	set id [lindex $geometric_entity 1]
	set args [lrange $geometric_entity 3 end]
	lappend geometric_entities_ids($id) $args
	}
	set geometric_entity_list [array names geometric_entities_ids]
	set fileHandle [open "[OpenSees::GetProjectPath]/Records/TCouples.txt" w+]
    set parameters 0.5
	foreach line_entity_id $geometric_entity_list {
	set xyz [GiD_Info Parametric line $line_entity_id coord {*}$parameters]
		set x [lindex $xyz 0]; set y [lindex $xyz 1]; set z [lindex $xyz 2];
		puts $fileHandle "&DEVC ID = 'L$line_entity_id', QUANTITY='GAS TEMPERATURE', XYZ=$x,$y,$z/"
	}
	close $fileHandle
	WarnWinText "Created TCouples.txt at:[OpenSees::GetProjectPath]/Records/TCouples.txt"
}



