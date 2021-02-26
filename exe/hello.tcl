set condition_name {Line_Gas_Temperatures}
set line_list [GiD_Info Conditions $condition_name geometry]
array unset geometric_entities_ids
#WarnWinText "$line_list"
# WarnWinText "first item is: [lindex $line_list 0]"
foreach geometric_entity $line_list {
set id [lindex $geometric_entity 1]
set args [lrange $geometric_entity 3 end]
WarnWinText "args are: $args"
lappend geometric_entities_ids($id) $args
}
set geometric_entity_list [array names geometric_entities_ids]
WarnWinText "element IDs are: $geometric_entity_list"
WarnWinText "ID 0: [lindex $geometric_entity_list 0]"
WarnWinText "ID 1: [lindex $geometric_entity_list 1]"
#WarnWinText "The whole array is: [array get geometric_entities_ids]"
WarnWinText "[OpenSees::GetProjectPath]"
set fileHandle [open "[OpenSees::GetProjectPath]/TCouples.txt" w+]
set parameters
foreach line_entity_id $geometric_entity_list {
    set xyz [GiD_Info Parametric line $line_entity_id coord {*}$parameters]
	set x [lindex $xyz 0]; set y [lindex $xyz 1]; set z [lindex $xyz 2];
    WarnWinText "for line $line_entity_id (x,y,z) = $xyz"
    puts $fileHandle "&DEVC ID = 'L$line_entity_id', QUANTITY='GAS TEMPERATURE', XYZ=$x,$y,$z/"
}
close $fileHandle




