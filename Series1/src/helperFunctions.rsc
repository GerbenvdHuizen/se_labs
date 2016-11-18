/* 
* Software Evolution
* Series 1 code - Final version
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


/*
 * Counts the amount of lines which are not comments
 * or lines which only contain whitespace.
 *
 * @param List of string (list[str]) containing LOC.
 * @return The LOC count (int).
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
			//&& /^\/\*.*\*\/$+/ !:= trimmedLine) {
			codeLines += 1;
		}
	}
	return codeLines;
}

/*
 * Returns all the LOC which are not comment lines
 * or lines with only whitspace.
 *
 * @param List of strings (list[str]) containing LOC.
 * @return List of strings (list[str]) containing all of the none comment
 * and none whitespace lines.
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
			//&& /^\/\*.*\*\/$+/ !:= trimmedLine) {
			codeLines += trimmedLine;
		}
	}
	return codeLines;
}

/*
 * Calculate the risk evaluation percentages for each risk level
 * (i.e. low, moderate, high and very high).
 *
 * @param Dictionary with risk level (str) as key and 
 * amount of members (int) as value.
 * @return Dictionary with risk level (str) as key and 
 * the calculated percentage (num) as value.
 */
public map[str, num] getRiskEvaluationPercentages (map[str, int] riskEvaluationLines) {
	map[str, num] riskEvaluationPercentages = ("low": 0, "moderate": 0, "high": 0, "very high": 0);
	int totalMethodCodeLines = riskEvaluationLines["total"];
	riskEvaluationPercentages["low"] = percent(riskEvaluationLines["low"], totalMethodCodeLines);
	riskEvaluationPercentages["moderate"] = percent(riskEvaluationLines["moderate"], totalMethodCodeLines);
	riskEvaluationPercentages["high"] = percent(riskEvaluationLines["high"], totalMethodCodeLines);
	riskEvaluationPercentages["very high"] = percent(riskEvaluationLines["very high"], totalMethodCodeLines);
	return riskEvaluationPercentages;
}