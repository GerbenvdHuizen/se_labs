module readUnitSize

import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import IO;
import String;
import List;
import util::Math;
import helperFunctions;


list[int] unitSizePM(M3 model) {
	list [int] methodUnitSize = []; 
	set[loc]methodLocs = methods(model);
	for(methodLoc <- methodLocs) {
		unitS = unitSize(methodLoc);
		methodUnitSize += unitS;	
	}
	
	return methodUnitSize;
}

public int computeUnitSize(M3 model){
	
	list[int] moderateRisk = [];
	list[int] highRisk = [];
	list[int] veryHighRisk = [];
	//M3 model = createM3FromEclipseProject(project);
	
	//list[Declaration] methodAsts = [ d | /Declaration d := createM3FromEclipseProject(s), d is java+method];
	
	list[int] unitSizeAll = unitSizePM(model);
	//lowRisk += [<l,x> | <l,x> <- unitSizeAll, x <= 20];
	moderateRisk += [x | x <- unitSizeAll, x > 30, x <= 44];
	highRisk += [x | x <- unitSizeAll, x > 44, x <= 74];
	veryHighRisk += [x | x <- unitSizeAll, x > 74];
	
	int moderateRiskPercentage = 0;
	int highRiskPercentage = 0;
	int veryHighRiskPercentage = 0;
	if(moderateRisk != [])
		moderateRiskPercentage = percent(sum(moderateRisk), sum(unitSizeAll));
	if(highRisk != [])
		highRiskPercentage = percent(sum(highRisk) ,sum(unitSizeAll));
	if(veryHighRisk != [])
		veryHighRiskPercentage = percent(sum(veryHighRisk) , sum(unitSizeAll));
	
	//println(unitSizeAll);
	println(moderateRiskPercentage);
	println(highRiskPercentage);
	println(veryHighRiskPercentage);
	
	int result;
	if(moderateRiskPercentage <= 25 && 
		highRiskPercentage < 1 && 
		veryHighRiskPercentage < 1) {
		result = 5;
	} else if(moderateRiskPercentage <= 30 &&
		highRiskPercentage <= 5 && 
		veryHighRiskPercentage < 1) {
		result = 4;
	} else if(moderateRiskPercentage <= 40 &&
		highRiskPercentage <= 10 && 
		veryHighRiskPercentage < 1) {
		result = 3;
	} else if(moderateRiskPercentage <= 50 &&
		highRiskPercentage <= 15 && 
		veryHighRiskPercentage <= 5) {
		result = 2;
	} else 
		result = 1;
	
	return result;
}