wipe
wipeHT 
set mode auto
set variables {ID composite slab protection_material tf tw h b dp dps ts bs plt FireExposure tFinal dt hfire hamb section_material}
puts "argc = $argc"
puts "number of variables = [llength $variables]"
if {$mode == "auto"} { 
	# we use llength variables - 1 because we added "section_material" and we do not want to break compatibility with older versions
	# if section_material is not given then it will be assigned the default value of 1
	if {$argc >= [expr [llength $variables] - 1]} {
		lassign $argv {*}$variables
	} else {
		puts "Script requires [llength $variables] arguments. Only $argc arguments were given. Aborting analysis."
		return -1
	}
}
file mkdir log
file mkdir Thermal_load
logFile "log/log$ID.log"
set phaseChangeCoeff 0

puts "This is job number $ID"
foreach arg $variables {
	puts "$arg = [subst $$arg]"
}
# puts "received secondinput = [lindex $argv 1]"


while {$okay && $i < [llength $values]} {
	set item [lindex $values $i]
	set okay [expr $item < 1 && $item >= 0]
	incr i
}

if {!$okay} {
	puts "one the dimensions {tf tw b dp dps ts} exceeds 1 m or is negative which is unreasonable. Continue anyway? {y/n}\n" 
	gets stdin continue
	if {$continue == "y" || $continue == "Y" } {
		puts "Continuing with the anlaysis.\n"
	} else { 
		puts "Received $continue. Aborting analysis.\n"
		return -1
	}
}

# meshing parameters
# minimum element sizes
# x direction (width)
set f_min_x 0.025
# y direction (thickness)
set f_min_y 0.015


set f_elemx [expr max(50,int(0.5*($b/$f_min_x))]

set f_elemy [expr max(50,int(0.5*$h/$f_min_y))]



puts "mesh: dfx, dfy = $f_elemx, $f_elemy"



#defined for RC Block by [Anand Kumar (anandk.iitj@gmail.com) 2023]

#length dimension
set centrex111 [expr $b*0.5] 

#hight dimension    
set centrey111 [expr $h*0.5]

HeatTransfer 2D;

#Defining HeatTransfer Material with Material tag 1.

# for compatibility with older versions of HTscript that do not define section_material
if { ($section_material == "") || ($section_material == 3) } {
	HTMaterial ConcreteEC2 3 0.0;
} else {
	HTMaterial aluminum 1;
}

HTMaterial SFRM 2 $protection_material;
puts "Creating entities for Concrete section"


puts "first set"
HTEntity Block 1 $centrex111 $centrey111 $b $h;


puts "creating mesh controls"

# HTMesh $meshTag $EntityTag $MaterialTag {-phaseChange 1 or 0} {-MeshCtrls $eleSizeX <$eleSizeY $eleSizeZ..>} {-NumCtrl $f_elemx $f_elemy}
 
HTMesh      1         1 		 3 			-phaseChange 		1 		-NumCtrl 	$f_elemx 	$f_elemy


puts "meshing"
HTMeshAll


SetInitialT 293.15
HTConstants 1 $hfire 293.15 0.85 0.85
HTConstants 2 $hamb 293.15 0.85 0.85

# thermal load assignment 
set fileName "FDS$ID.dat"

if {$FireExposure == 1} {
	FireModel standard 1
	puts "standard fire exposure."
	
} elseif {$FireExposure == 2} {
	FireModel hydroCarbon 1
	puts "Hydro carbon fire exposure." 
 
} elseif {$FireExposure == 3} {
	FireModel	UserDefined	1	-file	$fileName -type 1
	puts "User-defined fire exposure."
	
} elseif {$FireExposure == 4} {
	set fileName "user.dat"
	FireModel	UserDefined	1	-file	$fileName -type 1
	puts "User-defined fire exposure."
} else {
	puts "unknown fire exposure type. Aborting analysis." 
	return -1
	
}

HTPattern fire 1 model 1 {
			HeatFluxBC -HTEntity 1 -face 1 2 3 -type -ConvecAndRad -HTConstants 1
		}
		

HTPattern AmbientBC 2 {
		HeatFluxBC -HTEntity 1 -face 4 -type -ConvecAndRad -HTConstants 2
	}
	
puts "creating nodesets and recorders"
set a 0.0526315789473

#Temperature point (1st column -20 points)
set T1 101
HTNodeSet $T1 -Entity 1 -Locx 0.0   -Locy 0.0 
set T2 102                          
HTNodeSet $T2 -Entity 1 -Locx 0.0   -Locy [expr 1.0*$h*$a]
set T3 103                          
HTNodeSet $T3 -Entity 1 -Locx 0.0   -Locy [expr 2.0*$h*$a]
set T4 104                          
HTNodeSet $T4 -Entity 1 -Locx 0.0   -Locy [expr 3.0*$h*$a]
set T5 105                          
HTNodeSet $T5 -Entity 1 -Locx 0.0   -Locy [expr 4.0*$h*$a]
set T6 106                          
HTNodeSet $T6 -Entity 1 -Locx 0.0   -Locy [expr 5.0*$h*$a]
set T7 107                          
HTNodeSet $T7 -Entity 1 -Locx 0.0   -Locy [expr 6.0*$h*$a]
set T8 108                          
HTNodeSet $T8 -Entity 1 -Locx 0.0   -Locy [expr 7.0*$h*$a]
set T9 109                          
HTNodeSet $T9 -Entity 1 -Locx 0.0   -Locy [expr 8.0*$h*$a]
set T10 110
HTNodeSet $T10 -Entity 1 -Locx 0.0  -Locy [expr 9.0*$h*$a]
set T11 111
HTNodeSet $T11 -Entity 1 -Locx 0.0  -Locy [expr 10.0*$h*$a]
set T12 112
HTNodeSet $T12 -Entity 1 -Locx 0.0  -Locy [expr 11.0*$h*$a]
set T13 113
HTNodeSet $T13 -Entity 1 -Locx 0.0  -Locy [expr 12.0*$h*$a]
set T14 114
HTNodeSet $T14 -Entity 1 -Locx 0.0  -Locy [expr 13.0*$h*$a]
set T15 115
HTNodeSet $T15 -Entity 1 -Locx 0.0  -Locy [expr 14.0*$h*$a]
set T16 116
HTNodeSet $T16 -Entity 1 -Locx 0.0  -Locy [expr 15.0*$h*$a]
set T17 117
HTNodeSet $T17 -Entity 1 -Locx 0.0  -Locy [expr 16.0*$h*$a]
set T18 118
HTNodeSet $T18 -Entity 1 -Locx 0.0  -Locy [expr 17.0*$h*$a]
set T19 119
HTNodeSet $T19 -Entity 1 -Locx 0.0  -Locy [expr 18.0*$h*$a]
set T20 120
HTNodeSet $T20 -Entity 1 -Locx 0.0  -Locy [expr 19.0*$h*$a]


#Temperature point (2st column -20 points)
set T21 201
HTNodeSet $T21 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy 0.0 
set T22 202                                            
HTNodeSet $T22 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 1.0*$h*$a]
set T23 203                                            
HTNodeSet $T23 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 2.0*$h*$a]
set T24 204                                            
HTNodeSet $T24 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 3.0*$h*$a]
set T25 205                                            
HTNodeSet $T25 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 4.0*$h*$a]
set T26 206                                            
HTNodeSet $T26 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 5.0*$h*$a]
set T27 207                                            
HTNodeSet $T27 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 6.0*$h*$a]
set T28 208                                            
HTNodeSet $T28 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 7.0*$h*$a]
set T29 209                                            
HTNodeSet $T29 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 8.0*$h*$a]
set T30 210                                            
HTNodeSet $T30 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 9.0*$h*$a]
set T31 211                                            
HTNodeSet $T31 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 10.0*$h*$a]
set T32 212                                            
HTNodeSet $T32 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 11.0*$h*$a]
set T33 213                                            
HTNodeSet $T33 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 12.0*$h*$a]
set T34 214                                            
HTNodeSet $T34 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 13.0*$h*$a]
set T35 215                                            
HTNodeSet $T35 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 14.0*$h*$a]
set T36 216                                            
HTNodeSet $T36 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 15.0*$h*$a]
set T37 217                                            
HTNodeSet $T37 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 16.0*$h*$a]
set T38 218                                            
HTNodeSet $T38 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 17.0*$h*$a]
set T39 219                                            
HTNodeSet $T39 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 18.0*$h*$a]
set T40 220                                            
HTNodeSet $T40 -Entity 1 -Locx [expr 1.0*$b*$a]   -Locy [expr 19.0*$h*$a]

#Temperature point (3st column -20 points)
set T41 301                    
HTNodeSet $T41 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy 0.0 
set T42 302                                              
HTNodeSet $T42 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 1.0*$h*$a]
set T43 303                                              
HTNodeSet $T43 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 2.0*$h*$a]
set T44 304                                              
HTNodeSet $T44 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 3.0*$h*$a]
set T45 305                                              
HTNodeSet $T45 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 4.0*$h*$a]
set T46 306                                              
HTNodeSet $T46 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 5.0*$h*$a]
set T47 307                                              
HTNodeSet $T47 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 6.0*$h*$a]
set T48 308                                              
HTNodeSet $T48 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 7.0*$h*$a]
set T49 309                                              
HTNodeSet $T49 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 8.0*$h*$a]
set T50 310                                              
HTNodeSet $T50 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 9.0*$h*$a]
set T51 311                                              
HTNodeSet $T51 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 10.0*$h*$a]
set T52 312                                              
HTNodeSet $T52 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 11.0*$h*$a]
set T53 313                                              
HTNodeSet $T53 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 12.0*$h*$a]
set T54 314                                              
HTNodeSet $T54 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 13.0*$h*$a]
set T55 315                                              
HTNodeSet $T55 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 14.0*$h*$a]
set T56 316                                              
HTNodeSet $T56 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 15.0*$h*$a]
set T57 317                                              
HTNodeSet $T57 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 16.0*$h*$a]
set T58 318                                              
HTNodeSet $T58 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 17.0*$h*$a]
set T59 319                                              
HTNodeSet $T59 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 18.0*$h*$a]
set T60 320                                              
HTNodeSet $T60 -Entity 1 -Locx [expr 2.0*$b*$a]     -Locy [expr 19.0*$h*$a]

#Temperature point (4th column -20 points)
set T61   401
HTNodeSet $T61 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy 0.0 
set T62   402                                             
HTNodeSet $T62 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 1.0*$h*$a]
set T63   403                                             
HTNodeSet $T63 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 2.0*$h*$a]
set T64   404                                             
HTNodeSet $T64 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 3.0*$h*$a]
set T65   405                                             
HTNodeSet $T65 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 4.0*$h*$a]
set T66   406                                             
HTNodeSet $T66 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 5.0*$h*$a]
set T67   407                                             
HTNodeSet $T67 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 6.0*$h*$a]
set T68   408                                             
HTNodeSet $T68 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 7.0*$h*$a]
set T69   409                                             
HTNodeSet $T69 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 8.0*$h*$a]
set T70   410                                             
HTNodeSet $T70 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 9.0*$h*$a]
set T71   411                                             
HTNodeSet $T71 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 10.0*$h*$a]
set T72   412                                             
HTNodeSet $T72 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 11.0*$h*$a]
set T73   413                                             
HTNodeSet $T73 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 12.0*$h*$a]
set T74   414                                             
HTNodeSet $T74 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 13.0*$h*$a]
set T75   415                                             
HTNodeSet $T75 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 14.0*$h*$a]
set T76   416                                             
HTNodeSet $T76 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 15.0*$h*$a]
set T77   417                                             
HTNodeSet $T77 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 16.0*$h*$a]
set T78   418                                             
HTNodeSet $T78 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 17.0*$h*$a]
set T79   419                                             
HTNodeSet $T79 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 18.0*$h*$a]
set T80   420                                             
HTNodeSet $T80 -Entity 1 -Locx [expr 3.0*$b*$a]      -Locy [expr 19.0*$h*$a]

#Temperature point (5st column -20 points)
set T81   501
HTNodeSet $T81 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy 0.0 
set T82   502                                          
HTNodeSet $T82 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 1.0*$h*$a]
set T83   503                                          
HTNodeSet $T83 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 2.0*$h*$a]
set T84   504                                          
HTNodeSet $T84 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 3.0*$h*$a]
set T85   505                                          
HTNodeSet $T85 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 4.0*$h*$a]
set T86   506                                          
HTNodeSet $T86 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 5.0*$h*$a]
set T87   507                                          
HTNodeSet $T87 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 6.0*$h*$a]
set T88   508                                          
HTNodeSet $T88 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 7.0*$h*$a]
set T89   509                                          
HTNodeSet $T89 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 8.0*$h*$a]
set T90   510                                          
HTNodeSet $T90 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 9.0*$h*$a]
set T91   511                                          
HTNodeSet $T91 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 10.0*$h*$a]
set T92   512                                          
HTNodeSet $T92 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 11.0*$h*$a]
set T93   513                                          
HTNodeSet $T93 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 12.0*$h*$a]
set T94   514                                          
HTNodeSet $T94 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 13.0*$h*$a]
set T95   515                                          
HTNodeSet $T95 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 14.0*$h*$a]
set T96   516                                          
HTNodeSet $T96 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 15.0*$h*$a]
set T97   517                                          
HTNodeSet $T97 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 16.0*$h*$a]
set T98   518                                          
HTNodeSet $T98 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 17.0*$h*$a]
set T99   519                                          
HTNodeSet $T99 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 18.0*$h*$a]
set T100  520                                          
HTNodeSet $T100 -Entity 1 -Locx [expr 4.0*$b*$a]   -Locy [expr 19.0*$h*$a]

#Temperature point (6th column -20 points)
set T101   601
HTNodeSet $T101 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy 0.0 
set T102   602                                         
HTNodeSet $T102 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 1.0*$h*$a]
set T103   603                                         
HTNodeSet $T103 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 2.0*$h*$a]
set T104   604                                         
HTNodeSet $T104 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 3.0*$h*$a]
set T105   605                                         
HTNodeSet $T105 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 4.0*$h*$a]
set T106   606                                         
HTNodeSet $T106 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 5.0*$h*$a]
set T107   607                                         
HTNodeSet $T107 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 6.0*$h*$a]
set T108   608                                         
HTNodeSet $T108 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 7.0*$h*$a]
set T109   609                                         
HTNodeSet $T109 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 8.0*$h*$a]
set T110   610                                         
HTNodeSet $T110 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 9.0*$h*$a]
set T111   611                                         
HTNodeSet $T111 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 10.0*$h*$a]
set T112   612                                         
HTNodeSet $T112 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 11.0*$h*$a]
set T113   613                                         
HTNodeSet $T113 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 12.0*$h*$a]
set T114   614                                         
HTNodeSet $T114 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 13.0*$h*$a]
set T115   615                                         
HTNodeSet $T115 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 14.0*$h*$a]
set T116   616                                         
HTNodeSet $T116 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 15.0*$h*$a]
set T117   617                                         
HTNodeSet $T117 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 16.0*$h*$a]
set T118   618                                         
HTNodeSet $T118 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 17.0*$h*$a]
set T119   619                                         
HTNodeSet $T119 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 18.0*$h*$a]
set T120   620                                         
HTNodeSet $T120 -Entity 1 -Locx [expr 5.0*$b*$a]  -Locy [expr 19.0*$h*$a]

#Temperature point (7th column -20 points)
set T121   701
HTNodeSet $T121 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy 0.0 
set T122   702                                         
HTNodeSet $T122 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 1.0*$h*$a]
set T123   703                                         
HTNodeSet $T123 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 2.0*$h*$a]
set T124   704                                         
HTNodeSet $T124 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 3.0*$h*$a]
set T125   705                                         
HTNodeSet $T125 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 4.0*$h*$a]
set T126   706                                         
HTNodeSet $T126 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 5.0*$h*$a]
set T127   707                                         
HTNodeSet $T127 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 6.0*$h*$a]
set T128   708                                         
HTNodeSet $T128 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 7.0*$h*$a]
set T129   709                                         
HTNodeSet $T129 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 8.0*$h*$a]
set T130   710                                         
HTNodeSet $T130 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 9.0*$h*$a]
set T131   711                                         
HTNodeSet $T131 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 10.0*$h*$a]
set T132   712                                         
HTNodeSet $T132 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 11.0*$h*$a]
set T133   713                                         
HTNodeSet $T133 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 12.0*$h*$a]
set T134   714                                         
HTNodeSet $T134 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 13.0*$h*$a]
set T135   715                                         
HTNodeSet $T135 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 14.0*$h*$a]
set T136   716                                         
HTNodeSet $T136 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 15.0*$h*$a]
set T137   717                                         
HTNodeSet $T137 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 16.0*$h*$a]
set T138   718                                         
HTNodeSet $T138 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 17.0*$h*$a]
set T139   719                                         
HTNodeSet $T139 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 18.0*$h*$a]
set T140   720                                         
HTNodeSet $T140 -Entity 1 -Locx [expr 6.0*$b*$a]  -Locy [expr 19.0*$h*$a]

#Temperature point (8th column -20 points)
set T141   801
HTNodeSet $T141 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy 0.0 
set T142   802                                          
HTNodeSet $T142 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 1.0*$h*$a]
set T143   803                                          
HTNodeSet $T143 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 2.0*$h*$a]
set T144   804                                          
HTNodeSet $T144 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 3.0*$h*$a]
set T145   805                                          
HTNodeSet $T145 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 4.0*$h*$a]
set T146   806                                          
HTNodeSet $T146 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 5.0*$h*$a]
set T147   807                                          
HTNodeSet $T147 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 6.0*$h*$a]
set T148   808                                          
HTNodeSet $T148 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 7.0*$h*$a]
set T149   809                                          
HTNodeSet $T149 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 8.0*$h*$a]
set T150   810                                          
HTNodeSet $T150 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 9.0*$h*$a]
set T151   811                                          
HTNodeSet $T151 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 10.0*$h*$a]
set T152   812                                          
HTNodeSet $T152 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 11.0*$h*$a]
set T153   813                                          
HTNodeSet $T153 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 12.0*$h*$a]
set T154   814                                          
HTNodeSet $T154 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 13.0*$h*$a]
set T155   815                                          
HTNodeSet $T155 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 14.0*$h*$a]
set T156   816                                          
HTNodeSet $T156 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 15.0*$h*$a]
set T157   817                                          
HTNodeSet $T157 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 16.0*$h*$a]
set T158   818                                          
HTNodeSet $T158 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 17.0*$h*$a]
set T159   819                                          
HTNodeSet $T159 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 18.0*$h*$a]
set T160   820                                          
HTNodeSet $T160 -Entity 1 -Locx [expr 7.0*$b*$a]   -Locy [expr 19.0*$h*$a]

#Temperature point (9th column -20 points)
set T161   901
HTNodeSet $T161 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy 0.0 
set T162   902                                            
HTNodeSet $T162 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 1.0*$h*$a]
set T163   903                                            
HTNodeSet $T163 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 2.0*$h*$a]
set T164   904                                            
HTNodeSet $T164 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 3.0*$h*$a]
set T165   905                                            
HTNodeSet $T165 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 4.0*$h*$a]
set T166   906                                            
HTNodeSet $T166 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 5.0*$h*$a]
set T167   907                                            
HTNodeSet $T167 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 6.0*$h*$a]
set T168   908                                            
HTNodeSet $T168 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 7.0*$h*$a]
set T169   909                                            
HTNodeSet $T169 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 8.0*$h*$a]
set T170   910                                            
HTNodeSet $T170 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 9.0*$h*$a]
set T171   911                                            
HTNodeSet $T171 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 10.0*$h*$a]
set T172   912                                            
HTNodeSet $T172 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 11.0*$h*$a]
set T173   913                                            
HTNodeSet $T173 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 12.0*$h*$a]
set T174   914                                            
HTNodeSet $T174 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 13.0*$h*$a]
set T175   915                                            
HTNodeSet $T175 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 14.0*$h*$a]
set T176   916                                            
HTNodeSet $T176 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 15.0*$h*$a]
set T177   917                                            
HTNodeSet $T177 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 16.0*$h*$a]
set T178   918                                            
HTNodeSet $T178 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 17.0*$h*$a]
set T179   919                                            
HTNodeSet $T179 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 18.0*$h*$a]
set T180   920                                            
HTNodeSet $T180 -Entity 1  -Locx [expr 8.0*$b*$a]    -Locy [expr 19.0*$h*$a]
						   
#Temperature point (10th column -20 points)
set T181   1001
HTNodeSet $T181 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy 0.0 
set T182   1002                                          
HTNodeSet $T182 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 1.0*$h*$a]
set T183   1003                                          
HTNodeSet $T183 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 2.0*$h*$a]
set T184   1004                                          
HTNodeSet $T184 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 3.0*$h*$a]
set T185   1005                                          
HTNodeSet $T185 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 4.0*$h*$a]
set T186   1006                                          
HTNodeSet $T186 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 5.0*$h*$a]
set T187   1007                                          
HTNodeSet $T187 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 6.0*$h*$a]
set T188   1008                                          
HTNodeSet $T188 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 7.0*$h*$a]
set T189   1009                                          
HTNodeSet $T189 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 8.0*$h*$a]
set T190   1010                                          
HTNodeSet $T190 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 9.0*$h*$a]
set T191   1011                                          
HTNodeSet $T191 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 10.0*$h*$a]
set T192   1012                                          
HTNodeSet $T192 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 11.0*$h*$a]
set T193   1013                                          
HTNodeSet $T193 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 12.0*$h*$a]
set T194   1014                                          
HTNodeSet $T194 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 13.0*$h*$a]
set T195   1015                                          
HTNodeSet $T195 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 14.0*$h*$a]
set T196   1016                                          
HTNodeSet $T196 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 15.0*$h*$a]
set T197   1017                                          
HTNodeSet $T197 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 16.0*$h*$a]
set T198   1018                                          
HTNodeSet $T198 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 17.0*$h*$a]
set T199   1019                                          
HTNodeSet $T199 -Entity 1 -Locx [expr 9.0*$b*$a]    -Locy [expr 18.0*$h*$a]
set T200   1020                                          
HTNodeSet $T200 -Entity 1 -Locx [expr 3.0*$b*$a]    -Locy [expr 19.0*$h*$a]

#Temperature 9oint (11th column -20 points)
set T201   1101
HTNodeSet $T201 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy 0.0 
set T202   1102                                           
HTNodeSet $T202 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 1.0*$h*$a]
set T203   1103                                           
HTNodeSet $T203 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 2.0*$h*$a]
set T204   1104                                           
HTNodeSet $T204 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 3.0*$h*$a]
set T205   1105                                           
HTNodeSet $T205 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 4.0*$h*$a]
set T206   1106                                           
HTNodeSet $T206 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 5.0*$h*$a]
set T207   1107                                           
HTNodeSet $T207 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 6.0*$h*$a]
set T208   1108                                           
HTNodeSet $T208 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 7.0*$h*$a]
set T209   1109                                           
HTNodeSet $T209 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 8.0*$h*$a]
set T210   1110                                           
HTNodeSet $T210 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 9.0*$h*$a]
set T211   1111                                           
HTNodeSet $T211 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 10.0*$h*$a]
set T212   1112                                           
HTNodeSet $T212 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 11.0*$h*$a]
set T213   1113                                           
HTNodeSet $T213 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 12.0*$h*$a]
set T214   1114                                           
HTNodeSet $T214 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 13.0*$h*$a]
set T215   1115                                           
HTNodeSet $T215 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 14.0*$h*$a]
set T216   1116                                           
HTNodeSet $T216 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 15.0*$h*$a]
set T217   1117                                           
HTNodeSet $T217 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 16.0*$h*$a]
set T218   1118                                           
HTNodeSet $T218 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 17.0*$h*$a]
set T219   1119                                           
HTNodeSet $T219 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 18.0*$h*$a]
set T220   1120                                           
HTNodeSet $T220 -Entity 1 -Locx [expr 10.0*$b*$a]    -Locy [expr 19.0*$h*$a]

#Temperature point (12th column -20 points)
set T221   1201
HTNodeSet $T221 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy 0.0 
set T222   1202                                           
HTNodeSet $T222 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 1.0*$h*$a]
set T223   1203                                           
HTNodeSet $T223 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 2.0*$h*$a]
set T224   1204                                           
HTNodeSet $T224 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 3.0*$h*$a]
set T225   1205                                           
HTNodeSet $T225 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 4.0*$h*$a]
set T226   1206                                           
HTNodeSet $T226 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 5.0*$h*$a]
set T227   1207                                           
HTNodeSet $T227 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 6.0*$h*$a]
set T228   1208                                           
HTNodeSet $T228 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 7.0*$h*$a]
set T229   1209                                           
HTNodeSet $T229 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 8.0*$h*$a]
set T230   1210                                           
HTNodeSet $T230 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 9.0*$h*$a]
set T231   1211                                           
HTNodeSet $T231 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 10.0*$h*$a]
set T232   1212                                           
HTNodeSet $T232 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 11.0*$h*$a]
set T233   1213                                           
HTNodeSet $T233 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 12.0*$h*$a]
set T234   1214                                           
HTNodeSet $T234 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 13.0*$h*$a]
set T235   1215                                           
HTNodeSet $T235 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 14.0*$h*$a]
set T236   1216                                           
HTNodeSet $T236 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 15.0*$h*$a]
set T237   1217                                           
HTNodeSet $T237 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 16.0*$h*$a]
set T238   1218                                           
HTNodeSet $T238 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 17.0*$h*$a]
set T239   1219                                           
HTNodeSet $T239 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 18.0*$h*$a]
set T240   1220                                           
HTNodeSet $T240 -Entity 1 -Locx [expr 11.0*$b*$a]    -Locy [expr 19.0*$h*$a]

#Temperature point (13th column -20 points)
set T241   1301
HTNodeSet $T241 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy 0.0 
set T242   1302                                          
HTNodeSet $T242 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 1.0*$h*$a]
set T243   1303                                          
HTNodeSet $T243 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 2.0*$h*$a]
set T244   1304                                          
HTNodeSet $T244 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 3.0*$h*$a]
set T245   1305                                          
HTNodeSet $T245 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 4.0*$h*$a]
set T246   1306                                          
HTNodeSet $T246 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 5.0*$h*$a]
set T247   1307                                          
HTNodeSet $T247 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 6.0*$h*$a]
set T248   1308                                          
HTNodeSet $T248 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 7.0*$h*$a]
set T249   1309                                          
HTNodeSet $T249 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 8.0*$h*$a]
set T250   1310                                          
HTNodeSet $T250 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 9.0*$h*$a]
set T251   1311                                          
HTNodeSet $T251 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 10.0*$h*$a]
set T252   1312                                          
HTNodeSet $T252 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 11.0*$h*$a]
set T253   1313                                          
HTNodeSet $T253 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 12.0*$h*$a]
set T254   1314                                          
HTNodeSet $T254 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 13.0*$h*$a]
set T255   1315                                          
HTNodeSet $T255 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 14.0*$h*$a]
set T256   1316                                          
HTNodeSet $T256 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 15.0*$h*$a]
set T257   1317                                          
HTNodeSet $T257 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 16.0*$h*$a]
set T258   1318                                          
HTNodeSet $T258 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 17.0*$h*$a]
set T259   1319                                          
HTNodeSet $T259 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 18.0*$h*$a]
set T260   1320                                          
HTNodeSet $T260 -Entity 1 -Locx [expr 12.0*$b*$a]   -Locy [expr 19.0*$h*$a]

#Temperature point (14th column -20 points)
set T261   1401
HTNodeSet $T261 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy 0.0 
set T262   1402                                          
HTNodeSet $T262 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 1.0*$h*$a]
set T263   1403                                          
HTNodeSet $T263 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 2.0*$h*$a]
set T264   1404                                          
HTNodeSet $T264 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 3.0*$h*$a]
set T265   1405                                          
HTNodeSet $T265 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 4.0*$h*$a]
set T266   1406                                          
HTNodeSet $T266 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 5.0*$h*$a]
set T267   1407                                          
HTNodeSet $T267 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 6.0*$h*$a]
set T268   1408                                          
HTNodeSet $T268 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 7.0*$h*$a]
set T269   1409                                          
HTNodeSet $T269 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 8.0*$h*$a]
set T270   1410                                          
HTNodeSet $T270 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 9.0*$h*$a]
set T271   1411                                          
HTNodeSet $T271 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 10.0*$h*$a]
set T272   1412                                          
HTNodeSet $T272 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 11.0*$h*$a]
set T273   1413                                          
HTNodeSet $T273 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 12.0*$h*$a]
set T274   1414                                          
HTNodeSet $T274 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 13.0*$h*$a]
set T275   1415                                          
HTNodeSet $T275 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 14.0*$h*$a]
set T276   1416                                          
HTNodeSet $T276 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 15.0*$h*$a]
set T277   1417                                          
HTNodeSet $T277 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 16.0*$h*$a]
set T278   1418                                          
HTNodeSet $T278 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 17.0*$h*$a]
set T279   1419                                          
HTNodeSet $T279 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 18.0*$h*$a]
set T280   1420                                          
HTNodeSet $T280 -Entity 1 -Locx [expr 13.0*$b*$a]   -Locy [expr 19.0*$h*$a]

#Temperature point (15th column -20 points)
set T281   1501
HTNodeSet $T281 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy 0.0 
set T282   1502                                            
HTNodeSet $T282 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 1.0*$h*$a]
set T283   1503                                            
HTNodeSet $T283 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 2.0*$h*$a]
set T284   1504                                            
HTNodeSet $T284 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 3.0*$h*$a]
set T285   1505                                            
HTNodeSet $T285 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 4.0*$h*$a]
set T286   1506                                            
HTNodeSet $T286 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 5.0*$h*$a]
set T287   1507                                            
HTNodeSet $T287 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 6.0*$h*$a]
set T288   1508                                            
HTNodeSet $T288 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 7.0*$h*$a]
set T289   1509                                            
HTNodeSet $T289 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 8.0*$h*$a]
set T290   1510                                            
HTNodeSet $T290 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 9.0*$h*$a]
set T291   1511                                            
HTNodeSet $T291 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 10.0*$h*$a]
set T292   1512                                            
HTNodeSet $T292 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 11.0*$h*$a]
set T293   1513                                            
HTNodeSet $T293 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 12.0*$h*$a]
set T294   1514                                            
HTNodeSet $T294 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 13.0*$h*$a]
set T295   1515                                            
HTNodeSet $T295 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 14.0*$h*$a]
set T296   1516                                            
HTNodeSet $T296 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 15.0*$h*$a]
set T297   1517                                            
HTNodeSet $T297 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 16.0*$h*$a]
set T298   1518                                            
HTNodeSet $T298 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 17.0*$h*$a]
set T299   1519                                            
HTNodeSet $T299 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 18.0*$h*$a]
set T300   1520                                            
HTNodeSet $T300 -Entity 1 -Locx [expr 14.0*$b*$a]     -Locy [expr 19.0*$h*$a]

#Temperature point (16th column -20 points)
set T301   1601
HTNodeSet $T301 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy 0.0 
set T302   1602                                             
HTNodeSet $T302 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 1.0*$h*$a]
set T303   1603                                             
HTNodeSet $T303 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 2.0*$h*$a]
set T304   1604                                             
HTNodeSet $T304 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 3.0*$h*$a]
set T305   1605                                             
HTNodeSet $T305 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 4.0*$h*$a]
set T306   1606                                             
HTNodeSet $T306 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 5.0*$h*$a]
set T307   1607                                             
HTNodeSet $T307 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 6.0*$h*$a]
set T308   1608                                             
HTNodeSet $T308 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 7.0*$h*$a]
set T309   1609                                             
HTNodeSet $T309 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 8.0*$h*$a]
set T310   1610                                             
HTNodeSet $T310 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 9.0*$h*$a]
set T311   1611                                             
HTNodeSet $T311 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 10.0*$h*$a]
set T312   1612                                             
HTNodeSet $T312 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 11.0*$h*$a]
set T313   1613                                             
HTNodeSet $T313 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 12.0*$h*$a]
set T314   1614                                             
HTNodeSet $T314 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 13.0*$h*$a]
set T315   1615                                             
HTNodeSet $T315 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 14.0*$h*$a]
set T316   1616                                             
HTNodeSet $T316 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 15.0*$h*$a]
set T317   1617                                             
HTNodeSet $T317 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 16.0*$h*$a]
set T318   1618                                             
HTNodeSet $T318 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 17.0*$h*$a]
set T319   1619                                             
HTNodeSet $T319 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 18.0*$h*$a]
set T320   1620                                             
HTNodeSet $T320 -Entity 1 -Locx [expr 15.0*$b*$a]      -Locy [expr 19.0*$h*$a]

#Temperature point (17th column -20 points)
set T321   1701
HTNodeSet $T321 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy 0.0 
set T322   1702                                             
HTNodeSet $T322 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 1.0*$h*$a]
set T323   1703                                             
HTNodeSet $T323 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 2.0*$h*$a]
set T324   1704                                             
HTNodeSet $T324 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 3.0*$h*$a]
set T325   1705                                             
HTNodeSet $T325 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 4.0*$h*$a]
set T326   1706                                             
HTNodeSet $T326 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 5.0*$h*$a]
set T327   1707                                             
HTNodeSet $T327 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 6.0*$h*$a]
set T328   1708                                             
HTNodeSet $T328 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 7.0*$h*$a]
set T329   1709                                             
HTNodeSet $T329 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 8.0*$h*$a]
set T330   1710                                             
HTNodeSet $T330 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 9.0*$h*$a]
set T331   1711                                             
HTNodeSet $T331 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 10.0*$h*$a]
set T332   1712                                             
HTNodeSet $T332 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 11.0*$h*$a]
set T333   1713                                             
HTNodeSet $T333 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 12.0*$h*$a]
set T334   1714                                             
HTNodeSet $T334 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 13.0*$h*$a]
set T335   1715                                             
HTNodeSet $T335 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 14.0*$h*$a]
set T336   1716                                             
HTNodeSet $T336 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 15.0*$h*$a]
set T337   1717                                             
HTNodeSet $T337 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 16.0*$h*$a]
set T338   1718                                             
HTNodeSet $T338 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 17.0*$h*$a]
set T339   1719                                             
HTNodeSet $T339 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 18.0*$h*$a]
set T340   1720                                             
HTNodeSet $T340 -Entity 1 -Locx [expr 16.0*$b*$a]      -Locy [expr 19.0*$h*$a]

#Temperature point (18th column -20 points)
set T341   1801
HTNodeSet $T341 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy 0.0 
set T342  1802                                            
HTNodeSet $T342 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 1.0*$h*$a]
set T343   1803                                           
HTNodeSet $T343 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 2.0*$h*$a]
set T344   1804                                           
HTNodeSet $T344 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 3.0*$h*$a]
set T345   1805                                           
HTNodeSet $T345 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 4.0*$h*$a]
set T346   1806                                           
HTNodeSet $T346 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 5.0*$h*$a]
set T347   1807                                           
HTNodeSet $T347 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 6.0*$h*$a]
set T348   1808                                           
HTNodeSet $T348 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 7.0*$h*$a]
set T349   1809                                           
HTNodeSet $T349 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 8.0*$h*$a]
set T350   1810                                           
HTNodeSet $T350 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 9.0*$h*$a]
set T351   1811                                           
HTNodeSet $T351 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 10.0*$h*$a]
set T352   1812                                           
HTNodeSet $T352 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 11.0*$h*$a]
set T353   1813                                           
HTNodeSet $T353 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 12.0*$h*$a]
set T354   1814                                           
HTNodeSet $T354 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 13.0*$h*$a]
set T355   1815                                           
HTNodeSet $T355 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 14.0*$h*$a]
set T356   1816                                           
HTNodeSet $T356 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 15.0*$h*$a]
set T357   1817                                           
HTNodeSet $T357 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 16.0*$h*$a]
set T358   1818                                           
HTNodeSet $T358 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 17.0*$h*$a]
set T359   1819                                           
HTNodeSet $T359 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 18.0*$h*$a]
set T360   1820                                           
HTNodeSet $T360 -Entity 1 -Locx [expr 17.0*$b*$a]    -Locy [expr 19.0*$h*$a]

#Temperature point (19th column -20 points)
set T361   1901
HTNodeSet $T361 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy 0.0 
set T362   1902                                            
HTNodeSet $T362 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 1.0*$h*$a]
set T363   1903                                            
HTNodeSet $T363 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 2.0*$h*$a]
set T364   1904                                            
HTNodeSet $T364 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 3.0*$h*$a]
set T365   1905                                            
HTNodeSet $T365 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 4.0*$h*$a]
set T366   1906                                            
HTNodeSet $T366 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 5.0*$h*$a]
set T367   1907                                            
HTNodeSet $T367 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 6.0*$h*$a]
set T368   1908                                            
HTNodeSet $T368 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 7.0*$h*$a]
set T369   1909                                            
HTNodeSet $T369 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 8.0*$h*$a]
set T370   1910                                            
HTNodeSet $T370 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 9.0*$h*$a]
set T371   1911                                            
HTNodeSet $T371 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 10.0*$h*$a]
set T372   1912                                            
HTNodeSet $T372 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 11.0*$h*$a]
set T373   1913                                            
HTNodeSet $T373 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 12.0*$h*$a]
set T374   1914                                            
HTNodeSet $T374 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 13.0*$h*$a]
set T375   1915                                            
HTNodeSet $T375 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 14.0*$h*$a]
set T376   1916                                            
HTNodeSet $T376 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 15.0*$h*$a]
set T377   1917                                            
HTNodeSet $T377 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 16.0*$h*$a]
set T378   1918                                            
HTNodeSet $T378 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 17.0*$h*$a]
set T379   1919                                            
HTNodeSet $T379 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 18.0*$h*$a]
set T380   1920                                            
HTNodeSet $T380 -Entity 1 -Locx [expr 18.0*$b*$a]     -Locy [expr 19.0*$h*$a]

#Temperature point (20th column -20 points)
set T381   2001
HTNodeSet $T381 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy 0.0 
set T382   2002                                           
HTNodeSet $T382 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 1.0*$h*$a]
set T383   2003                                           
HTNodeSet $T383 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 2.0*$h*$a]
set T384   2004                                           
HTNodeSet $T384 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 3.0*$h*$a]
set T385   2005                                           
HTNodeSet $T385 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 4.0*$h*$a]
set T386   2006                                           
HTNodeSet $T386 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 5.0*$h*$a]
set T387   2007                                           
HTNodeSet $T387 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 6.0*$h*$a]
set T388   2008                                           
HTNodeSet $T388 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 7.0*$h*$a]
set T389   2009                                           
HTNodeSet $T389 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 8.0*$h*$a]
set T390   2010                                           
HTNodeSet $T390 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 9.0*$h*$a]
set T391   2011                                           
HTNodeSet $T391 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 10.0*$h*$a]
set T392   2012                                           
HTNodeSet $T392 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 11.0*$h*$a]
set T393   2013                                           
HTNodeSet $T393 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 12.0*$h*$a]
set T394   2014                                           
HTNodeSet $T394 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 13.0*$h*$a]
set T395   2015                                           
HTNodeSet $T395 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 14.0*$h*$a]
set T396   2016                                           
HTNodeSet $T396 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 15.0*$h*$a]
set T397   2017                                           
HTNodeSet $T397 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 16.0*$h*$a]
set T398   2018                                           
HTNodeSet $T398 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 17.0*$h*$a]
set T399   2019                                           
HTNodeSet $T399 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 18.0*$h*$a]
set T400   2020                                           
HTNodeSet $T400 -Entity 1 -Locx [expr 19.0*$b*$a]    -Locy [expr 19.0*$h*$a]

set beamTemp 2021
HTNodeSet $beamTemp -NodeSet $T1 $T2 $T3 $T4 $T5 $T6 $T7 $T8 $T9 $T10	$T11	$T12	$T13	$T14	$T15	$T16	$T17	$T18	$T19	$T20	$T21	$T22	$T23	$T24	$T25	$T26	$T27	$T28	$T29	$T30	$T31	$T32	$T33	$T34	$T35	$T36	$T37	$T38	$T39	$T40	$T41	$T42	$T43	$T44	$T45	$T46	$T47	$T48	$T49	$T50	$T51	$T52	$T53	$T54	$T55	$T56	$T57	$T58	$T59	$T60	$T61	$T62	$T63	$T64	$T65	$T66	$T67	$T68	$T69	$T70	$T71	$T72	$T73	$T74	$T75	$T76	$T77	$T78	$T79	$T80	$T81	$T82	$T83	$T84	$T85	$T86	$T87	$T88	$T89	$T90	$T91	$T92	$T93	$T94	$T95	$T96	$T97	$T98	$T99	$T100	$T101	$T102	$T103	$T104	$T105	$T106	$T107	$T108	$T109	$T110	$T111	$T112	$T113	$T114	$T115	$T116	$T117	$T118	$T119	$T120	$T121	$T122	$T123	$T124	$T125	$T126	$T127	$T128	$T129	$T130	$T131	$T132	$T133	$T134	$T135	$T136	$T137	$T138	$T139	$T140	$T141	$T142	$T143	$T144	$T145	$T146	$T147	$T148	$T149	$T150	$T151	$T152	$T153	$T154	$T155	$T156	$T157	$T158	$T159	$T160	$T161	$T162	$T163	$T164	$T165	$T166	$T167	$T168	$T169	$T170	$T171	$T172	$T173	$T174	$T175	$T176	$T177	$T178	$T179	$T180	$T181	$T182	$T183	$T184	$T185	$T186	$T187	$T188	$T189	$T190	$T191	$T192	$T193	$T194	$T195	$T196	$T197	$T198	$T199	$T200	$T201	$T202	$T203	$T204	$T205	$T206	$T207	$T208	$T209	$T210	$T211	$T212	$T213	$T214	$T215	$T216	$T217	$T218	$T219	$T220	$T221	$T222	$T223	$T224	$T225	$T226	$T227	$T228	$T229	$T230	$T231	$T232	$T233	$T234	$T235	$T236	$T237	$T238	$T239	$T240	$T241	$T242	$T243	$T244	$T245	$T246	$T247	$T248	$T249	$T250	$T251	$T252	$T253	$T254	$T255	$T256	$T257	$T258	$T259	$T260	$T261	$T262	$T263	$T264	$T265	$T266	$T267	$T268	$T269	$T270	$T271	$T272	$T273	$T274	$T275	$T276	$T277	$T278	$T279	$T280	$T281	$T282	$T283	$T284	$T285	$T286	$T287	$T288	$T289	$T290	$T291	$T292	$T293	$T294	$T295	$T296	$T297	$T298	$T299	$T300	$T301	$T302	$T303	$T304	$T305	$T306	$T307	$T308	$T309	$T310	$T311	$T312	$T313	$T314	$T315	$T316	$T317	$T318	$T319	$T320	$T321	$T322	$T323	$T324	$T325	$T326	$T327	$T328	$T329	$T330	$T331	$T332	$T333	$T334	$T335	$T336	$T337	$T338	$T339	$T340	$T341	$T342	$T343	$T344	$T345	$T346	$T347	$T348	$T349	$T350	$T351	$T352	$T353	$T354	$T355	$T356	$T357	$T358	$T359	$T360	$T361	$T362	$T363	$T364	$T365	$T366	$T367	$T368	$T369	$T370	$T371	$T372	$T373	$T374	$T375	$T376	$T377	$T378	$T379	$T380	$T381	$T382	$T383	$T384	$T385	$T386	$T387	$T388	$T389	$T390	$T391	$T392	$T393	$T394	$T395	$T396	$T397	$T398	$T399	$T400
HTRecorder -file "Thermal_load\\BeamColumn$ID.dat" -NodeSet $beamTemp

proc RelaxTolerance { dt tolerance lastTime } {
	set tolerance [expr $tolerance*2]
	puts "Increased tolerance to $tolerance"
	if {$tolerance > 100} {
		puts "tolerance exceeds 100C, aborting analysis."
		return -1
	}
	HTAnalysis HeatTransfer TempIncr $tolerance 300 2 Newton
	HTAnalyze 1 $dt
	set reachedTime [getHTTime]
	if {[expr $reachedTime - $lastTime < $dt*1e-3]} {
		set OK 0
	} else { 
		set OK 1
	}
	
	if {$OK == 1} {
		return $OK
	} else {
		set OK [RelaxTolerance $dt $tolerance $lastTime]
	}
	if {$OK == 1} {
		return $OK
	} else {
		return -1
	}
}
puts "\n\n\n"
set OK 1
set tolerance 5
set reachedTime 0
set lastTime 0
HTAnalysis HeatTransfer TempIncr $tolerance 300 2 Newton

while {$reachedTime < $tFinal} {
	if { $OK > 0 } {
		set lastTime [getHTTime]
		puts "Attempting analysis for time: [expr $reachedTime + $dt]"
		HTAnalyze 1 $dt
		set reachedTime [getHTTime]
		puts "reachedTime: $reachedTime"
		puts "lastTime:$lastTime"
		puts "Difference is: [expr $reachedTime - $lastTime]" 
		
		if {[expr $reachedTime - $lastTime < $dt*1e-3]} {
			puts "Current step failed."
			set OK 0
		} else { 
			puts "Current step succeeded."
			set OK 1
		}
	} elseif { $OK < 0} {
		puts "tolerance exceeded. Cannot continue."
		break
	} else {
		puts "Seems analysis failed last step."
		set OK [RelaxTolerance $dt $tolerance $lastTime]
		set reachedTime [getHTTime]
		set tolerance 5
	}
}


# HTAnalyze [expr $tFinal/$dt] $dt

if {[expr $tFinal - $reachedTime] < 1e-3} {
	puts "Success"
} else {
	puts $reachedTime
	puts "Failure"
}
wipeHT
