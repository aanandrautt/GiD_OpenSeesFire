general way to set shell loads

*set cond Shell_Thermal *elems *CanRepeat
*loop elems *OnlyInCond

*set var FileName=Matprop(filename,str)
*set var TopFiber=Matprop(tobFiber,str)
*set var BotFiber=Matprop(botFiber,str)
%format%%%%%
eleLoad -ele *ElemsNum -type -shellThermal -file *FileName *BotFiber *TopFiber