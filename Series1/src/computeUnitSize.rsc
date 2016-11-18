/* 
* Software Evolution
* Series 1 code - Final version
* computeUnitSize.rsc
*
* Vincent Erich - 10384081
* Gerben van der Huizen - 10460748
* November 2016
*/
module computeUnitSize

import IO;
import lang::java::jdt::m3::Core;
import helperFunctions;

/*
 * Creates a tuple containing the risk evaluation percentages of unit size and
 * the unit size ranking.
 *
 * @param Locations of all methods of a Java project (set[loc]).
 * @return Tuple with risk evaluation percentages (map[str, num]) and a rank (str).
 */
public tuple[map[str, num], str] getUnitSize (set[loc] methodLocations) {
	map[str, num] riskPercentages = computeUnitSize(methodLocations);
	str unitSizeRank = getUnitSizeRank(riskPercentages);
	return <riskPercentages, unitSizeRank>;
}

/*
 * Computes the unit size of each method of a set of project files.
 * Based on the evaluation of the unit size a category for that method is
 * chosen (i.e. low, moderate, high or very high). If a method belongs to
 * certain category +1 will be added to a dictionary value of that category.
 * The dictionary is used to calculated the risk evaluation percentages for
 * each category which is returned as a dictionary as well.
 *
 * @param Locations of all methods of a Java project (set[loc]).
 * @return The risk evaluation percentage dictionary (map[str,int]).
 */
public map[str, num] computeUnitSize (set[loc] methodLocations) {
	map[str, num] riskEvaluationLines = ("low": 0, "moderate": 0, "high": 0, "very high": 0, "total": 0);
	for (methodLocation <- methodLocations) {
		list[str] methodLines = readFileLines(methodLocation);
		int methodCodeLines = countCodeLines(methodLines);
		str methodRiskEvaluation = getMethodRiskEvaluation(methodCodeLines);
		riskEvaluationLines[methodRiskEvaluation] += methodCodeLines; 
		riskEvaluationLines["total"] += methodCodeLines;
	}
	return getRiskEvaluationPercentages(riskEvaluationLines);
}

/*
 * Determines the risk evaluation of a method
 * on certain thresholds. The thresholds are based on table III 
 * from the paper "Benchmark-based Aggregation of Metrics to Ratings".
 *
 * @param Amount of lines of a unit/method (int).
 * @return The risk evaluation (str).
 */
public str getMethodRiskEvaluation (int methodCodeLines) {
	if (methodCodeLines <= 30) {
		return "low";
	}
	else if (methodCodeLines > 30 && methodCodeLines <= 44) {
		return "moderate";
	}
	else if (methodCodeLines > 44 && methodCodeLines <= 74) {
		return "high";
	}
	else {
		return "very high";
	}
}

/*
 * Determines the unit size rank of a Java project based
 * on certain percentage thresholds. The thresholds are based on table 
 * IV in the paper "Benchmark-based Aggregation of Metrics to Ratings".
 *
 * @param Unit size dictionary with risk level (str) 
 * as key and the calculated percentage (num) as value.
 * @return The ranking (str).
 */
public str getUnitSizeRank (map[str, num] riskPercentages) {
	num percentageModerate = riskPercentages["moderate"];
	num percentageHigh = riskPercentages["high"];
	num percentageVeryHigh = riskPercentages["very high"];
	if ((percentageModerate < 20.6) 
		&& (percentageHigh < 11.1) 
		&& (percentageVeryHigh < 3.9)) {
		return "++";
	}
	else if ((percentageModerate >= 20.6 && percentageModerate < 28.2) 
		&& (percentageHigh >= 11.1 && percentageHigh < 18.0) 
		&& (percentageVeryHigh >= 3.9 && percentageVeryHigh < 7.8)) {
		return "+";
	}
	else if ((percentageModerate >= 28.2 && percentageModerate < 35.9) 
		&& (percentageHigh >= 18.0 && percentageHigh < 26.0) 
		&& (percentageVeryHigh >= 7.8 && percentageVeryHigh < 12.7)) {
		return "o";
	}
	else if ((percentageModerate >= 35.9 && percentageModerate < 46.4) 
		&& (percentageHigh >= 26.0 && percentageHigh < 33.3) 
		&& (percentageVeryHigh >= 12.7 && percentageVeryHigh < 19.5)) {
		return "-";
	}
	else {
		return "--";
	}
}