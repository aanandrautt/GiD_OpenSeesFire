# The number of fibers assigned to the cover material should be proportional to the cover size

proc NumofCoverFibers { depth Totaldepth Fibers } {

	# depth : the cover depth
	# Totaldepth: The total cross section length parallel to cover depth
	# Fibers: The number of fibers along the cover depth direction

	set ratio [expr $depth/$Totaldepth]
	set coverFibers [roundUp [expr $ratio*$Fibers]]
	return $coverFibers
}

proc GetTorsionalConstant { h tw b1 tf1 b2 tf2 } {

	set tf [expr ($tf1 + $tf2)/2.0]
	set J [expr ($b2*pow($tf2,3.0) + $b1*pow($tf1,3.0) + ($h - $tf*pow($tw,3.0)))/3.0]
	return $J
}

proc GetWebIy { h tw tf2 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf2]
	set Iy [expr $H*$sine - 0.5*$tw*$cosine]
	return $Iy
}
proc GetWebIz { h tw tf2 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf2]
	set Iz [expr -$H*$cosine - 0.5*$tw*$sine]
	return $Iz
}

proc GetWebJy { h tw tf2 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf2]
	set Jy [expr $H*$sine + 0.5*$tw*$cosine]
	return $Jy
}
proc GetWebJz { h tw tf2 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf2]
	set Jz [expr -$H*$cosine + 0.5*$tw*$sine]
	return $Jz
}

proc GetWebKy { h tw tf1 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf1]
	set Ky [expr -$H*$sine + 0.5*$tw*$cosine]
	return $Ky
}
proc GetWebKz { h tw tf1 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf1]
	set Kz [expr $H*$cosine + 0.5*$tw*$sine]
	return $Kz
}

proc GetWebLy { h tw tf1 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf1]
	set Ly [expr -$H*$sine -0.5*$tw*$cosine]
	return $Ly
}
proc GetWebLz { h tw tf1 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf1]
	set Lz [expr $H*$cosine -0.5*$tw*$sine]
	return $Lz
}

proc GetTopFlangeIy { h b1 tf1 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf1*0.5]
	set y1 [expr $H*$sine]
	set y2 [expr 0.5*$b1*$cosine]
	set y3 [expr 0.5*$tf1*$sine]
	set Iy [expr -$y1 - $y2 + $y3]
	return $Iy
}
proc GetTopFlangeIz { h b1 tf1 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf1*0.5]
	set z1 [expr $H*$cosine]
	set z2 [expr 0.5*$b1*$sine]
	set z3 [expr 0.5*$tf1*$cosine]
	set Iz [expr $z1 - $z2 - $z3]
	return $Iz
}

proc GetTopFlangeJy { h b1 tf1 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf1*0.5]
	set y1 [expr $H*$sine]
	set y2 [expr 0.5*$b1*$cosine]
	set y3 [expr 0.5*$tf1*$sine]
	set Jy [expr -$y1 + $y2 + $y3]
	return $Jy
}
proc GetTopFlangeJz { h b1 tf1 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf1*0.5]
	set z1 [expr $H*$cosine]
	set z2 [expr 0.5*$b1*$sine]
	set z3 [expr 0.5*$tf1*$cosine]
	set Jz [expr $z1 + $z2 - $z3]
	return $Jz
}

proc GetTopFlangeKy { h b1 tf1 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf1*0.5]
	set y1 [expr $H*$sine]
	set y2 [expr 0.5*$b1*$cosine]
	set y3 [expr 0.5*$tf1*$sine]
	set Ky [expr -$y1 + $y2 - $y3]
	return $Ky
}
proc GetTopFlangeKz { h b1 tf1 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf1*0.5]
	set z1 [expr $H*$cosine]
	set z2 [expr 0.5*$b1*$sine]
	set z3 [expr 0.5*$tf1*$cosine]
	set Kz [expr $z1 + $z2 + $z3]
	return $Kz
}

proc GetTopFlangeLy { h b1 tf1 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf1*0.5]
	set y1 [expr $H*$sine]
	set y2 [expr 0.5*$b1*$cosine]
	set y3 [expr 0.5*$tf1*$sine]
	set Ly [expr -$y1 - $y2 - $y3]
	return $Ly
}
proc GetTopFlangeLz { h b1 tf1 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf1*0.5]
	set z1 [expr $H*$cosine]
	set z2 [expr 0.5*$b1*$sine]
	set z3 [expr 0.5*$tf1*$cosine]
	set Lz [expr $z1 - $z2 + $z3]
	return $Lz
}

proc GetBotFlangeIy { h b2 tf2 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf2*0.5]
	set y1 [expr $H*$sine]
	set y2 [expr 0.5*$b2*$cosine]
	set y3 [expr 0.5*$tf2*$sine]
	set Iy [expr $y1 - $y2 + $y3]
	return $Iy
}
proc GetBotFlangeIz { h b2 tf2 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf2*0.5]
	set z1 [expr $H*$cosine]
	set z2 [expr 0.5*$b2*$sine]
	set z3 [expr 0.5*$tf2*$cosine]
	set Iz [expr -$z1 - $z2 - $z3]
	return $Iz
}

proc GetBotFlangeJy { h b2 tf2 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf2*0.5]
	set y1 [expr $H*$sine]
	set y2 [expr 0.5*$b2*$cosine]
	set y3 [expr 0.5*$tf2*$sine]
	set Jy [expr $y1 + $y2 + $y3]
	return $Jy
}
proc GetBotFlangeJz { h b2 tf2 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf2*0.5]
	set z1 [expr $H*$cosine]
	set z2 [expr 0.5*$b2*$sine]
	set z3 [expr 0.5*$tf2*$cosine]
	set Jz [expr -$z1 + $z2 - $z3]
	return $Jz
}

proc GetBotFlangeKy { h b2 tf2 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf2*0.5]
	set y1 [expr $H*$sine]
	set y2 [expr 0.5*$b2*$cosine]
	set y3 [expr 0.5*$tf2*$sine]
	set Ky [expr $y1 + $y2 - $y3]
	return $Ky
}
proc GetBotFlangeKz { h b2 tf2 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf2*0.5]
	set z1 [expr $H*$cosine]
	set z2 [expr 0.5*$b2*$sine]
	set z3 [expr 0.5*$tf2*$cosine]
	set Kz [expr -$z1 + $z2 + $z3]
	return $Kz
}

proc GetBotFlangeLy { h b2 tf2 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf2*0.5]
	set y1 [expr $H*$sine]
	set y2 [expr 0.5*$b2*$cosine]
	set y3 [expr 0.5*$tf2*$sine]
	set Ly [expr $y1 - $y2 - $y3]
	return $Ly
}
proc GetBotFlangeLz { h b2 tf2 angle } {
	set pi 3.141592653589793238
	set theta [expr ($pi/180)*$angle]
	set cosine [expr cos($theta)]
	set sine [expr sin($theta)]
	set H [expr $h*0.5 - $tf2*0.5]
	set z1 [expr $H*$cosine]
	set z2 [expr 0.5*$b2*$sine]
	set z3 [expr 0.5*$tf2*$cosine]
	set Lz [expr -$z1 - $z2 + $z3]
	return $Lz
}