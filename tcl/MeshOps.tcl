proc GiD_Event_BeforeMeshGeneration { element_size } {
	set time_start [clock seconds]	
	WarnWinText ".....Starting pre-meshing commands at [clock format $time_start -format %H:%M:%S].....\n\n"
	SourceHello
	Fire::ResetIDs
	set current_interval [lindex [GiD_Info intvdata num] 0]
	set num_of_intervals [lindex [GiD_Info intvdata num] 1]
	WarnWinText "Current interval is: $current_interval"
	for {set interval 1} {$interval <= $num_of_intervals} {incr interval} {
		GiD_IntervalData set $interval
		WarnWinText "Changed interval to $interval"
		WarnWinText "\n-----Interval: $interval-----"
		Fire::AssignConditionIds
		WarnWinText "\n-----Interval: $interval-----"
		Fire::AssignSurfaceCompositeSectionCond
		WarnWinText "\n-----Interval: $interval-----"
		Fire::PairCompositeSections fire 0.00001 1.0
		Fire::PairCompositeSections ambient 0.00001 1.0
		WarnWinText "\n-----Interval: $interval-----"
		Joint::PremeshGeneration

		WarnWinText "\n-----Ran all functions in interval: $interval-----"
	}
	GiD_IntervalData set $current_interval
	W "Returned to original interval: $current_interval"
	set time_end [clock seconds]
	set PreMeshTime [expr $time_end-$time_start]
	WarnWinText "\n\n.....Finished all pre-meshing commands at [clock format $time_end -format %H:%M:%S]....."
	W ".....Premeshing commands took $PreMeshTime seconds.....\n\n"
}
proc GiD_Event_AfterMeshGeneration { fail } { 	
	PostMeshing $fail
}
# proc AfterMeshGeneration is the legacy name of the post meshing function

proc PostMeshing { fail } {
	if {!$fail} {
		set time_start [clock seconds]
		set pairs ""
		WarnWinText ".....Starting post-meshing commands at [clock format $time_start -format %H:%M:%S].....\n\n"
		set current_interval [lindex [GiD_Info intvdata num] 0]
		set num_of_intervals [lindex [GiD_Info intvdata num] 1]
		WarnWinText "Current interval is: $current_interval"
		for {set interval 1} {$interval <= $num_of_intervals} {incr interval} {
			GiD_IntervalData set $interval
			WarnWinText "Changed interval to $interval"
			WarnWinText "\n-----Interval: $interval-----"
			append pairs [MeshRepair::MatchMesh] 
			Fire::AssignCompositeConnection ambient 0.00001
			WarnWinText "\n-----Interval: $interval-----"
			Fire::AssignCentralElementFlag
			WarnWinText "constraint ID = [expr $Fire::constraint_ID - 1]\ncondition ID = [expr $Fire::condition_ID - 1]\ncomposite ID = [expr $Fire::composite_ID - 1]                                         "
			WarnWinText "\n-----Ran all functions in interval: $interval-----"
		}
		GiD_IntervalData set 1
		W "\n-----Interval: 1-----"
		W "Assigning nodal masses corresponding to quad element\n if Automass is turned on in gen data starting at [clock format [clock seconds] -format %H:%M:%S]"
		Dynamics::AutoMass
		W "Finished assigning mass information to nodes at [clock format [clock seconds] -format %H:%M:%S]."
		W "Starting postmesh Joint assignments starting at [clock format [clock seconds] -format %H:%M:%S]"
		#Joint::PostMesh
		Joint::AssignJoints
		W "Finished postmesh Joint assignments starting at [clock format [clock seconds] -format %H:%M:%S]"
		GiD_IntervalData set $current_interval
		W "Returned to original interval: $current_interval"
		W "\nCreating geometric transforms at [clock format [clock seconds] -format %H:%M:%S]."
		Transform::PopulateTagsArray
		W "\nFinished creating transforms and populting the corresponding array at [clock format [clock seconds] -format %H:%M:%S].\n"
		MeshRepair::ReassignMeshDivisions $pairs
		W "\nFinished reassigning mesh divisions to beam-column elements at [clock format [clock seconds] -format %H:%M:%S].\n"
		set time_end [clock seconds]
		set PostMeshTime [expr $time_end-$time_start]
		WarnWinText "\n\n.....Finished all post-meshing commands at [clock format $time_end -format %H:%M:%S]....."
		W ".....Post-meshing commands took $PostMeshTime seconds.....\n\n"
	}
}