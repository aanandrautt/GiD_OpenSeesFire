namespace eval DBC {}

proc DBC::CheckSection { event args } {

	switch $event {

		SYNC {

			set GDN [lindex $args 0]
			set STRUCT [lindex $args 1]
			set QUESTION [lindex $args 2]

			set ChosenSection [DWLocalGetValue $GDN $STRUCT $QUESTION]
			set Activethermal [DWLocalGetValue $GDN $STRUCT "Activate_Thermal"]

			if {![catch {GiD_AccessValue get materials $ChosenSection "Section:"}]} {
				set SecType [GiD_AccessValue get materials $ChosenSection "Section:"]
				#SecType is the value of the question: Section: of the chosen Section from the combo box!

				if { $SecType != "Fiber" && $SecType != "SectionAggregator" && $SecType != "ElasticSection" && $SecType != "FiberCustom" && $SecType != "FiberBuiltUpSections" && $Activethermal==0} {
					WarnWinText "Uncompatible Section $ChosenSection ($SecType section) selected for Displacement-Based beam-column elements."
					WarnWinText "It has been changed to Fiber section."
					# Change the value of the field "Section:" to Fiber
					DWLocalSetValue $GDN $STRUCT $QUESTION "Fiber"
				} elseif { [Fire::CompatibleThermalSections $SecType]==-1 && $Activethermal==1} {
				
					WarnWinText "Uncompatible Thermal Section $ChosenSection ($SecType section) selected for Displacement-Based beam-column elements."
					WarnWinText "It has been changed to Fiber section."
					# Change the value of the field "Section:" to Fiber
					DWLocalSetValue $GDN $STRUCT $QUESTION "Fiber"					
				
				}
				
			} else {
				WarnWinText "Uncompatible Section selected for Displacement-Based Beam Column Element"
				WarnWinText "It has been changed to Fiber Section"
				DWLocalSetValue $GDN $STRUCT $QUESTION "Fiber"
			}
		}

	}

	return ""
}