*if(IntvData(Parametric_cases,int)==1)
set Lincr $case_step_size
*format "%d"
set Nsteps [expr $case_total_time/$case_step_size]
*else
*format "%g"
set Lincr *LoadIncr
*format "%d"
set Nsteps *steps
*endif
set committedSteps 1
set LoadCounter 0


set strIni {}
*if(strcmp(IntvData(Convergence_criterion),"Norm_Unbalance")==0)
variable testTypeStatic NormUnbalance
*elseif(strcmp(IntvData(Convergence_criterion),"Norm_Displacement_Increment")==0)
variable testTypeStatic NormDispIncr
*elseif(strcmp(IntvData(Convergence_criterion),"Energy_Increment")==0)
variable testTypeStatic EnergyIncr
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Norm_Unbalance")==0)
variable testTypeStatic RelativeNormUnbalance
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Norm_Displacement_Increment")==0)
variable testTypeStatic RelativeNormDispIncr
*elseif(strcmp(IntvData(Convergence_criterion),"Total_Relative_Norm_Displacement_Increment")==0)
variable testTypeStatic RelativeTotalNormDispIncr
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Energy_Increment")==0)
variable testTypeStatic RelativeEnergyIncr
*elseif(strcmp(IntvData(Convergence_criterion),"Fixed_Number_of_Iterations")==0)
variable testTypeStatic FixedNumIter
*endif
*format "%g"
variable TolStatic *IntvData(Tolerance,real)
variable maxNumIterStatic *IntvData(Max_Iterations_per_Step,int)
*if(strcmp(IntvData(Solution_algorithm),"Full_Newton-Raphson")==0)
variable algorithmTypeStatic Newton
*if(IntvData(Use_initial_stiffness_iterations,int)==1)
set strIni "/Ini"
*endif
*elseif(strcmp(IntvData(Solution_algorithm),"Modified_Newton-Raphson")==0)
variable algorithmTypeStatic ModifiedNewton
*if(IntvData(Use_initial_stiffness_iterations,int)==1)
set strIni "/Ini"
*endif
*elseif(strcmp(IntvData(Solution_algorithm),"Newton-Raphson_with_line_search")==0)
variable algorithmTypeStatic NewtonLineSearch
*elseif(strcmp(IntvData(Solution_algorithm),"Broyden")==0)
variable algorithmTypeStatic Broyden
*elseif(strcmp(IntvData(Solution_algorithm),"BFGS")==0)
variable algorithmTypeStatic BFGS
*elseif(strcmp(IntvData(Solution_algorithm),"KrylovNewton")==0)
variable algorithmTypeStatic KrylovNewton
*if(IntvData(Use_initial_stiffness_iterations,int)==1)
set strIni "/Ini"
*endif
*endif

for {set i 1} { $i <= $Nsteps } {incr i 1} {
    set t [format "%7.5f" [expr [getTime] + $Lincr]]
*if(PrintTime==1)
    puts -nonewline "(*IntvNum) $algorithmTypeStatic$strIni LF $t "
*endif
    set AnalOk [analyze 1]
    if {$AnalOk !=0} {
        break
    } else {
        set LoadCounter [expr $LoadCounter+1.0]
        set committedSteps [expr $committedSteps+1]
    }
}

if {$AnalOk != 0} {; # if analysis fails, alternative algorithms and substepping is applied
    set firstFail 1
    set AnalOk 0
    set Nk 1
    set returnToInitStepFlag 0
*if(IntvData(Tolerance_relaxation,int)==1)
    set InitialTolFlag 1
    set returnToInitTolFlag 0
    set ChangeToleranceFlag 0
    set SkipFirstLoopForTolRelaxFlag 1
*endif
    while {$LoadCounter < $Nsteps && $AnalOk == 0} {
        if {($Nk==2.0 && $AnalOk==0) || ($Nk==1 && $AnalOk==0)} {
            set Nk 1
            if {$returnToInitStepFlag} {
                puts "\nBack to initial step\n"
                set returnToInitStepFlag 0
            }
*if(IntvData(Tolerance_relaxation,int)==1)
            if {$returnToInitTolFlag} {
                if {!$InitialTolFlag} {
                    puts "\nBack to initial error tolerance\n"
*format "%g"
                    set TolStatic [expr $TolStatic/*IntvData(Relaxation_factor,real)]
                    set InitialTolFlag 1
*if(strcmp(IntvData(Convergence_criterion),"Norm_Unbalance")==0)
*format "%d"
                    test NormUnbalance $TolStatic *IntvData(Max_Iterations_per_Step,int) *LoggingFlag
*elseif(strcmp(IntvData(Convergence_criterion),"Norm_Displacement_Increment")==0)
*format "%d"
                    test NormDispIncr $TolStatic *IntvData(Max_Iterations_per_Step,int) *LoggingFlag
*elseif(strcmp(IntvData(Convergence_criterion),"Energy_Increment")==0)
*format "%d"
                    test EnergyIncr $TolStatic *IntvData(Max_Iterations_per_Step,int) *LoggingFlag
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Norm_Unbalance")==0)
*format "%d"
                    test RelativeNormUnbalance $TolStatic *IntvData(Max_Iterations_per_Step,int) *LoggingFlag
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Norm_Displacement_Increment")==0)
*format "%d"
                    test RelativeNormDispIncr $TolStatic *IntvData(Max_Iterations_per_Step,int) *LoggingFlag
*elseif(strcmp(IntvData(Convergence_criterion),"Total_Relative_Norm_Displacement_Increment")==0)
*format "%d"
                    test RelativeTotalNormDispIncr $TolStatic *IntvData(Max_Iterations_per_Step,int) *LoggingFlag
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Energy_Increment")==0)
*format "%d"
                    test RelativeEnergyIncr $TolStatic *IntvData(Max_Iterations_per_Step,int) *LoggingFlag
*elseif(strcmp(IntvData(Convergence_criterion),"Fixed_Number_of_Iterations")==0)
*format "%d"
                    test FixedNumIter *IntvData(Max_Iterations_per_Step,int) *LoggingFlag
*endif
                }
            } else {
                if {$InitialTolFlag && $ChangeToleranceFlag && !$SkipFirstLoopForTolRelaxFlag} {
*format "%g"
                    puts "Tolerance is multiplied by *IntvData(Relaxation_factor,real)\n"
*format "%g"
                    set TolStatic [expr $TolStatic***IntvData(Relaxation_factor,real)]
                    set InitialTolFlag 0
*if(strcmp(IntvData(Convergence_criterion),"Norm_Unbalance")==0)
*format "%d"
                    test NormUnbalance $TolStatic *IntvData(Max_Iterations_per_Step,int) *LoggingFlag
*elseif(strcmp(IntvData(Convergence_criterion),"Norm_Displacement_Increment")==0)
*format "%d"
                    test NormDispIncr $TolStatic *IntvData(Max_Iterations_per_Step,int) *LoggingFlag
*elseif(strcmp(IntvData(Convergence_criterion),"Energy_Increment")==0)
*format "%d"
                    test EnergyIncr $TolStatic *IntvData(Max_Iterations_per_Step,int) *LoggingFlag
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Norm_Unbalance")==0)
*format "%d"
                    test RelativeNormUnbalance $TolStatic *IntvData(Max_Iterations_per_Step,int) *LoggingFlag
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Norm_Displacement_Increment")==0)
*format "%d"
                    test RelativeNormDispIncr $TolStatic *IntvData(Max_Iterations_per_Step,int) *LoggingFlag
*elseif(strcmp(IntvData(Convergence_criterion),"Total_Relative_Norm_Displacement_Increment")==0)
*format "%d"
                    test RelativeTotalNormDispIncr $TolStatic *IntvData(Max_Iterations_per_Step,int) *LoggingFlag
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Energy_Increment")==0)
*format "%d"
                    test RelativeEnergyIncr $TolStatic *IntvData(Max_Iterations_per_Step,int) *LoggingFlag
*elseif(strcmp(IntvData(Convergence_criterion),"Fixed_Number_of_Iterations")==0)
*format "%d"
                    test FixedNumIter *IntvData(Max_Iterations_per_Step,int) *LoggingFlag
*endif
                }
            }
            set SkipFirstLoopForTolRelaxFlag 0
*endif
            if {$firstFail == 0} { # for the first time only, do not repeat previous failed step
                integrator LoadControl $Lincr; # reset to original increment
                set t [format "%7.5f" [expr [getTime] + $Lincr]]
*if(PrintTime==1)
                puts -nonewline "(*IntvNum) $algorithmTypeStatic$strIni LF $t "
*endif
                set AnalOk [analyze 1]; # zero for convergence
            } else {
                set AnalOk 1
                set firstFail 0
            }
            if {$AnalOk == 0} {
                set LoadCounter [expr $LoadCounter+1.0/$Nk]
                set committedSteps [expr $committedSteps+1]
            }
        }; # end if Nk=1
        # substepping /2
        if {($AnalOk !=0 && $Nk==1) || ($AnalOk==0 && $Nk==4.0)} {
            set Nk 2.0; # reduce step size
            set continueFlag 1
            puts "\nInitial step is divided by 2\n"
            set LincrReduced [expr $Lincr/$Nk]
            integrator LoadControl $LincrReduced
            for {set ik 1} {$ik <=$Nk} {incr ik 1} {
                if {$continueFlag==0} {
                    break
                }
                set t [format "%7.5f" [expr [getTime] + $LincrReduced]]
*if(PrintTime==1)
                puts -nonewline "(*IntvNum) $algorithmTypeStatic$strIni LF $t "
*endif
                set AnalOk [analyze 1]; # zero for convergence
                if {$AnalOk == 0} {
                    set LoadCounter [expr $LoadCounter+1.0/$Nk]
                    set committedSteps [expr $committedSteps+1]
                } else {
                    set continueFlag 0
                }
            }
            if {$AnalOk == 0} {
                set returnToInitStepFlag 1
            }
        }; # end if Nk=2.0
*if(IntvData(Tolerance_relaxation,int)==1)
*if(strcmp(IntvData(Tolerance_relaxation_after_failed_substepping_of),"/2")==0)
        if {$AnalOk != 0 } {
            if {$InitialTolFlag} {
                set Nk 1; # back to initial step - tolerance relaxation
                set AnalOk 0
                set returnToInitStepFlag 1
                set ChangeToleranceFlag 1
                set returnToInitTolFlag 0
            }
        } else {
            if {!$InitialTolFlag} {
                set Nk 1
                set returnToInitTolFlag 1
            }
        }
*endif
*endif
        # substepping /4
        if {($AnalOk !=0 && $Nk==2.0) || ($AnalOk==0 && $Nk==8.0)} {
            set Nk 4.0; # reduce step size
            set continueFlag 1
            puts "\nInitial step is divided by 4\n"
            set LincrReduced [expr $Lincr/$Nk]
            integrator LoadControl $LincrReduced
            for {set ik 1} {$ik <=$Nk} {incr ik 1} {
                if {$continueFlag==0} {
                    break
                }
                set t [format "%7.5f" [expr [getTime] + $LincrReduced]]
*if(PrintTime==1)
                puts -nonewline "(*IntvNum) $algorithmTypeStatic$strIni LF $t "
*endif
                set AnalOk [analyze 1]; # zero for convergence
                if {$AnalOk == 0} {
                    set LoadCounter [expr $LoadCounter+1.0/$Nk]
                    set committedSteps [expr $committedSteps+1]
                } else {
                    set continueFlag 0
                }
            }
            if {$AnalOk == 0} {
                set returnToInitStepFlag 1
            }
        }; # end if Nk=4
*if(IntvData(Tolerance_relaxation,int)==1)
*if(strcmp(IntvData(Tolerance_relaxation_after_failed_substepping_of),"/4")==0)
        if {$AnalOk != 0 } {
            if {$InitialTolFlag} {
                set Nk 1; # back to initial step - tolerance relaxation
                set AnalOk 0
                set returnToInitStepFlag 1
                set ChangeToleranceFlag 1
                set returnToInitTolFlag 0
            }
        } else {
            if {!$InitialTolFlag} {
                set Nk 1
                set returnToInitTolFlag 1
            }
        }
*endif
*endif
        # substepping /8
        if {$AnalOk !=0 && $Nk==4.0 || ($Nk == 16.0 && $AnalOk == 0)} {
            set Nk 8.0; # reduce step size
            set continueFlag 1
            puts "\nInitial step is divided by 8\n"
            set LincrReduced [expr $Lincr/$Nk]
            integrator LoadControl $LincrReduced
            for {set ik 1} {$ik <=$Nk} {incr ik 1} {
                if {$continueFlag==0} {
                    break
                }
                set t [format "%7.5f" [expr [getTime] + $LincrReduced]]
*if(PrintTime==1)
                puts -nonewline "(*IntvNum) $algorithmTypeStatic$strIni LF $t "
*endif
                set AnalOk [analyze 1]; # zero for convergence
                if {$AnalOk == 0} {
                    set LoadCounter [expr $LoadCounter+1.0/$Nk]
                    set committedSteps [expr $committedSteps+1]
                } else {
                    set continueFlag 0
                }
            }
            if {$AnalOk == 0} {
                set returnToInitStepFlag 1
            }
        }; # end if Nk=8
*if(IntvData(Tolerance_relaxation,int)==1)
*if(strcmp(IntvData(Tolerance_relaxation_after_failed_substepping_of),"/8")==0)
        if {$AnalOk != 0 } {
            if {$InitialTolFlag} {
                set Nk 1; # back to initial step - tolerance relaxation
                set AnalOk 0
                set returnToInitStepFlag 1
                set ChangeToleranceFlag 1
                set returnToInitTolFlag 0
            }
        } else {
            if {!$InitialTolFlag} {
                set Nk 1
                set returnToInitTolFlag 1
            }
        }
*endif
*endif
        # substepping /16
        if {($Nk == 8 && $AnalOk!=0)} {
            set Nk 16.0; # reduce step size
            set continueFlag 1
            puts "\nInitial step is divided by 16\n"
            set LincrReduced [expr $Lincr/$Nk]
            integrator LoadControl $LincrReduced
            for {set ik 1} {$ik <=$Nk} {incr ik 1} {
                if {$continueFlag==0} {
                    break
                }
                set t [format "%7.5f" [expr [getTime] + $LincrReduced]]
*if(PrintTime==1)
                puts -nonewline "(*IntvNum) $algorithmTypeStatic$strIni LF $t "
*endif
                set AnalOk [analyze 1]; # zero for convergence
                if {$AnalOk == 0} {
                    set LoadCounter [expr $LoadCounter+1.0/$Nk]
                    set committedSteps [expr $committedSteps+1]
                } else {
                    set continueFlag 0
                }
            }
            if {$AnalOk == 0} {
                set returnToInitStepFlag 1
            }
        }; # end if Nk=16
*if(IntvData(Tolerance_relaxation,int)==1)
*if(strcmp(IntvData(Tolerance_relaxation_after_failed_substepping_of),"/16")==0)
        if {$AnalOk != 0 } {
            if {$InitialTolFlag} {
                set Nk 1; # back to initial step - tolerance relaxation
                set AnalOk 0
                set returnToInitStepFlag 1
                set ChangeToleranceFlag 1
                set returnToInitTolFlag 0
            }
        } else {
            if {!$InitialTolFlag} {
                set Nk 1
                set returnToInitTolFlag 1
            }
        }
*endif
*endif
    }; # end while loop
}; # end if AnalOk

if {$AnalOk == 0} {
    puts "\nAnalysis completed SUCCESSFULLY"
    puts "Committed steps : $committedSteps\n"
} else {
    puts "\nAnalysis FAILED"
    puts "Committed steps : $committedSteps\n"
}