module readComplexityPerUnit

import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import IO;
import String;
import List;
import util::Math;
import helperFunctions;


lrel[int, int] complexityPerUnit(M3 model) {
	lrel[int, int] methodCPU = []; 
	set[loc]methodLocs = methods(model);
	
	for(methodLoc <- methodLocs) {
		int result = 1;
		
		//println(getAnnotations(methodNode));
		Declaration methodNode = getMethodASTEclipse(methodLoc, model = model);
		visit(methodNode) {
		  	case \if(_,_) : result += 1;
	        case \if(_,_,_) : result += 1;
	        case \case(_) : result += 1;
	        case \do(_,_) : result += 1;
	        case \while(_,_) : result += 1;
	        case \for(_,_,_) : result += 1;
	        case \for(_,_,_,_) : result += 1;
	        case foreach(_,_,_) : result += 1;
	        case \catch(_,_): result += 1;
	        case \conditional(_,_,_): result += 1;
	        case infix(_,"&&",_) : result += 1;
	        case infix(_,"||",_) : result += 1;			
		}
		//println(result);
		
		unitS = unitSize(methodLoc);
		methodCPU += <result, unitS>;
		
	}
	
	return methodCPU;
}

public int computeCPU(loc project){
	//list[Declaration] methodAsts = [ d | /Declaration d := createAstFromFile(project, true), d is method];
	//Anode = createAstFromFile(project,true);
	list[int] totalCPU =[];
	list[int] moderateRisk = [];
	list[int] highRisk = [];
	list[int] veryHighRisk = [];
	M3 model = createM3FromEclipseProject(project);
	
	lrel[int,int] methodCPU = complexityPerUnit(model);
	//println(methodCPU);
	//lrel[int,int] lowRisk = [<x,y> | <x,y> <- methodCPU, x <= 10];
	totalCPU += [y | <x,y> <- methodCPU];
	moderateRisk = [y | <x,y> <- methodCPU, x > 10, x <= 20];
	highRisk = [y | <x,y> <- methodCPU, x > 20, x <= 50];
	veryHighRisk = [y | <x,y> <- methodCPU, x > 50];
	
	int moderateRiskPercentage = 0;
	int highRiskPercentage = 0;
	int veryHighRiskPercentage = 0;
	if(moderateRisk != [])
		moderateRiskPercentage = percent(sum(moderateRisk) , sum(totalCPU));
	if(highRisk != [])
		highRiskPercentage = percent(sum(highRisk) , sum(totalCPU));
	if(veryHighRisk != [])
		veryHighRiskPercentage = percent(sum(veryHighRisk) , sum(totalCPU));
	
	//println(totalCPU);
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
