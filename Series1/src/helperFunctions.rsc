/**
 * Software Evolution - University of Amsterdam
 * Practical Lab Series 1 - Software Metrics
 * helperFunctions.rsc
 *
 * Vincent Erich - 10384081
 * Gerben van der Huizen - 10460748
 * November 2016
 */

module helperFunctions

import IO;
import String;

import util::Math;


/**
 * Given a list with lines from a source file, returns the number of LOC 
 * (i.e., excludes lines that are comments or only contain whitespace).
 *
 * @param lines		A list with lines from a source file (list[str]).
 * @return 			The number of LOC (int).
 */
public int countCodeLines (list[str] lines) {
	int codeLines = 0;
	for (line <- lines) {
		str trimmedLine = trim(line);
		if (/^\/\/.*/ !:= trimmedLine
			&& /^\/\*.*/ !:= trimmedLine
			&& /^\*.*/ !:= trimmedLine 
			&& /^\*\// !:= trimmedLine
			&& trimmedLine != "") {
			codeLines += 1;
		}
	}
	return codeLines;
}

/**
 * Given a list with lines from a source file, returns the LOC (i.e., the 
 * lines that are not comments and do not only contain whitespace).
 *
 * @param lines		A list with lines from a source file (list[str]).
 * @return 			A list with LOC (list[str]).
 */
public list[str] returnCodeLines (list[str] lines) {
	list[str] codeLines = [];
	for (line <- lines) {
		str trimmedLine = trim(line);
		if (/^\/\/.*/ !:= trimmedLine
			&& /^\/\*.*/ !:= trimmedLine
			&& /^\*.*/ !:= trimmedLine
			&& /^\*\// !:= trimmedLine
			&& trimmedLine != "") {
			codeLines += trimmedLine;
		}
	}
	return codeLines;
}

/**
 * Returns the risk evaluation percentages.
 *
 * @param riskEvaluationLines	A dictionary with risk evaluation categories as 
 *								keys and the number of unit code lines belonging  
 *								to the risk evaluation categories as values
 *								(map[str, int]). 
 * @return 						The risk evaluation percentages (map[str, num]).
 */
public map[str, num] getRiskEvaluationPercentages (map[str, int] riskEvaluationLines) {
	map[str, num] riskEvaluationPercentages = ("low": 0, "moderate": 0, "high": 0, "very high": 0);
	int totalUnitCodeLines = riskEvaluationLines["total"];
	riskEvaluationPercentages["low"] = percent(riskEvaluationLines["low"], totalUnitCodeLines);
	riskEvaluationPercentages["moderate"] = percent(riskEvaluationLines["moderate"], totalUnitCodeLines);
	riskEvaluationPercentages["high"] = percent(riskEvaluationLines["high"], totalUnitCodeLines);
	riskEvaluationPercentages["very high"] = percent(riskEvaluationLines["very high"], totalUnitCodeLines);
	return riskEvaluationPercentages;
}