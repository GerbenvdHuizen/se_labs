/**
 * Software Evolution - University of Amsterdam
 * Practical Lab Series 1 - Software Metrics
 * computeUnitComplexity.rsc
 *
 * Vincent Erich - 10384081
 * Gerben van der Huizen - 10460748
 * November 2016
 */
 
module computeUnitComplexity

import IO;

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

import helperFunctions;


/**
 * Returns a tuple containing the risk evaluation percentages of a Java 
 * project and the corresponding complexity per unit rank.
 *
 * @param m3Model			The M3 model of the Java project (M3).
 * @param fileLocations		The locations of all the files of the Java project 
 *							(set[loc]).
 * @return 					A tuple with the risk evaluation percentages and 
 *							the complexity per unit rank 
 *							(tuple[map[str, num], str].
 */
public tuple[map[str, num], str] getUnitComplexity (M3 m3Model, set[loc] fileLocations) {
	map[str, num] riskPercentages = computeUnitComplexity(m3Model, fileLocations);
	str unitComplexityRank = getUnitComplexityRank(riskPercentages);
	return <riskPercentages, unitComplexityRank>;
}

/**
 * Returns the risk evaluation percentages of a Java project (with regard to 
 * the complexity per unit metric). A method/constructor is the smallest unit 
 * in a Java project.
 * It is possible to create the unit ASTs from the M3 model given 
 * as first parameter/argument. To calculate the cyclomatic complexity of a 
 * unit, the corresponding method AST is visited and is incremented by one 
 * (starting from one) if certain statements are detected in a node. The 
 * cyclomatic complexities of all the units are used to calculate the risk 
 * evaluation percentages.
 * Based on the cyclomatic complexity of a unit, the unit is assigned to a 
 * risk evaluation category (low, moderate, high, or very high). The 
 * corresponding dictionary value of that risk evaluation category is then 
 * incremented by the number of LOC of that unit. The dictionary also stores 
 * the total number of LOC of all the units. The dictionary values are used to  
 * calculate the risk evaluation percentages. 
 *
 * @param m3Model			The M3 model of the Java project (M3).
 * @param fileLocations		The locations of all the files of the Java project 
 *							(set[loc]).
 * @return 					A dictionary with the risk evaluation percentages 
 *							(map[str, num]).
 */
public map[str, num] computeUnitComplexity (M3 m3Model, set[loc] fileLocations) {
	map[str, int] riskEvaluationLines = ("low": 0, "moderate": 0, "high": 0, "very high": 0, "total": 0);
	for (fileLocation <- fileLocations) {
		list[Declaration] unitASTs = [ d | /Declaration d := createAstFromFile(fileLocation, false), d is method || d is constructor];
		for(unitAST <- unitASTs) {
			int result = 1;
			visit(unitAST) {
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
			list[str] unitLines = readFileLines(unitAST@src);
			int unitCodeLines = countCodeLines(unitLines);
			int unitComplexity = result;
			str unitRiskEvaluation = getUnitRiskEvaluation(unitComplexity);
			riskEvaluationLines[unitRiskEvaluation] += unitCodeLines;
			riskEvaluationLines["total"] += unitCodeLines;
		}
	}
	return getRiskEvaluationPercentages(riskEvaluationLines);
}

/**
 * Returns a risk evaluation category based on the cyclomatic complexity. The 
 * thresholds and risk evaluation categories are based on the table in the 
 * paper "A Practical Model for Measuring Maintainability" (page 35).
 *
 * @param unitComplexity	The cyclomatic complexity (int).
 * @return 					The risk evaluation category (str).
 */
public str getUnitRiskEvaluation (int unitComplexity) {
	if (unitComplexity <= 10) {
		return "low";
	}
	else if (unitComplexity >= 11 && unitComplexity <= 20) {
		return "moderate";
	}
	else if (unitComplexity >= 21 && unitComplexity <= 50) {
		return "high";
	}
	else {
		return "very high";
	}
}

/**
 * Returns a complexity per unit rank based on the risk evaluation 
 * percentages. The thresholds and ranks are based on the table in the paper 
 * "A Practical Model for Measuring Maintainability" (page 35).
 *
 * @param riskPercentages	The risk evaluation percentages (map[str, num]). 
 * @return 					The complexity per unit rank (str).
 */
public str getUnitComplexityRank (map[str, num] riskPercentages) {
	num percentageModerate = riskPercentages["moderate"];
	num percentageHigh = riskPercentages["high"];
	num percentageVeryHigh = riskPercentages["very high"];
	if (percentageModerate <= 25 
		&& percentageHigh == 0 
		&& percentageVeryHigh == 0) {
		return "++";
	}
	else if ((percentageModerate > 25 && percentageModerate <= 30) 
		&& (percentageHigh > 0 && percentageHigh <= 5) 
		&& percentageVeryHigh == 0) {
		return "+";
	}
	else if ((percentageModerate > 30 && percentageModerate <= 40) 
		&& (percentageHigh > 5 && percentageHigh < 10) 
		&& percentageVeryHigh >= 0) {
		return "o";
	}
	else if ((percentageModerate > 40 && percentageModerate <= 50) 
		&& (percentageHigh > 10 && percentageHigh <= 15) 
		&& (percentageVeryHigh >= 0 && percentageVeryHigh <= 5)) {
		return "-";
	}
	else {
		return "--";
	}
}