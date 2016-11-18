/* 
* Software Evolution
* Series 1 code - Final version
* computeUnitComplexity.rsc
*
* Vincent Erich - 10384081
* Gerben van der Huizen - 10460748
* November 2016
*/
module computeUnitComplexity

import IO;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import helperFunctions;

/*
 * Creates a tuple containing the risk evaluation percentages of unit Complexity and
 * the unit complexity ranking.
 *
 * @param A model of the entire project (M3).
 * @param Locations of all files of a Java project (set[loc]).
 * @return Tuple with risk evaluation percentages (map[str, num]) and a rank (str).
 */
public tuple[map[str, num], str] getUnitComplexity (M3 m3Model, set[loc] fileLocations) {
	//M3 m3Model = createM3FromEclipseProject(projectSource);
	//set[loc] methodLocations = methods(m3Model);
	map[str, num] riskPercentages = computeUnitComplexity(m3Model, fileLocations);
	str unitComplexityRank = getUnitComplexityRank(riskPercentages);
	return <riskPercentages, unitComplexityRank>;
}

/*
 * Computes the unit complexity of each method of a set of project files.
 * From the model given as input the method ASTs can be created. To calclate 
 * the complexity of a unit the AST is visted and +1 is added the complexity 
 * value if certain statements are detected in an AST node. The result of visiting
 * the AST is used in the risk evaluation process.
 * Based on the evaluation of the unit complexity a category for that method is
 * chosen (i.e. low, moderate, high or very high). If a method belongs to
 * certain category +1 will be added to a dictionary value of that category.
 * The dictionary is used to calculated the risk evaluation percentages for
 * each category which is returned as a dictionary as well. 
 *
 * @param A model of the entire project (M3).
 * @param Locations of all files of a Java project (set[loc]).
 * @return The risk evaluation percentage dictionary (map[str,int]).
 */
public map[str, num] computeUnitComplexity (M3 m3Model, set[loc] fileLocations) {
	map[str, int] riskEvaluationLines = ("low": 0, "moderate": 0, "high": 0, "very high": 0, "total": 0);
	for (fileLocation <- fileLocations) {
		list[Declaration] methodAsts = [ d | /Declaration d := createAstFromFile(fileLocation, false), d is method || d is constructor];
		for(methodAst <- methodAsts) {
			int result = 1;
			
			visit(methodAst) {
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
			list[str] methodLines = readFileLines(methodAst@src);
			int methodCodeLines = countCodeLines(methodLines);
			int methodComplexity = result;
			str methodRiskEvaluation = getMethodRiskEvaluation(methodComplexity);
			riskEvaluationLines[methodRiskEvaluation] += methodCodeLines;
			riskEvaluationLines["total"] += methodCodeLines;
		}
	}
	return getRiskEvaluationPercentages(riskEvaluationLines);
}

/*
 * Determines the risk evaluation of method complexity
 * on certain thresholds. The thresholds were taken from 
 * a table from page 26 of "A Practical Model for 
 * Measuring Maintainability".
 *
 * @param Method complexity (int).
 * @return The risk evaluation (str).
 */
public str getMethodRiskEvaluation (int methodComplexity) {
	if (methodComplexity <= 10) {
		return "low";
	}
	else if (methodComplexity >= 11 && methodComplexity <= 20) {
		return "moderate";
	}
	else if (methodComplexity >= 21 && methodComplexity <= 50) {
		return "high";
	}
	else {
		return "very high";
	}
}

/*
 * Determines the complixity rank of a Java project based
 * on certain percentage thresholds. The thresholds were taken from 
 * a table from page 26 of "A Practical Model for 
 * Measuring Maintainability".
 *
 * @param Unit complexity dictionary with risk level (str) 
 * as key and the calculated percentage (num) as value.
 * @return The ranking (str).
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