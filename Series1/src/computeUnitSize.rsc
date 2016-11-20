/**
 * Software Evolution - University of Amsterdam
 * Practical Lab Series 1 - Software Metrics
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


/**
 * Returns a tuple containing the risk evaluation percentages of a Java 
 * project and the corresponding unit size rank.
 *
 * @param unitLocations		The locations of all the units in the Java project 
 *							(set[loc]).
 * @return 					A tuple with the risk evaluation percentages and 
 *							the unit size rank (tuple[map[str, num], str].
 */
public tuple[map[str, num], str] getUnitSize (set[loc] unitLocations) {
	map[str, num] riskPercentages = computeUnitSize(unitLocations);
	str unitSizeRank = getUnitSizeRank(riskPercentages);
	return <riskPercentages, unitSizeRank>;
}

/**
 * Returns the risk evaluation percentages of a Java project (with regard to 
 * the unit size metric). A method/constructor is the smallest unit in a Java 
 * project.
 * Based on the unit size of a unit, the unit is assigned to a risk evaluation 
 * category (low, moderate, high, or very high). The corresponding dictionary 
 * value of that risk evaluation category is then incremented by the number of 
 * LOC of that unit. The dictionary also stores the total number of LOC of all 
 * the units. The dictionary values are used to calculate the risk evaluation 
 * percentages.
 *
 * @param unitLocations		The locations of all the units in the Java project 
 *							(set[loc]).
 * @return 					A dictionary with the risk evaluation percentages 
 *							(map[str, num]).
 */
public map[str, num] computeUnitSize (set[loc] unitLocations) {
	map[str, num] riskEvaluationLines = ("low": 0, "moderate": 0, "high": 0, "very high": 0, "total": 0);
	for (unitLocation <- unitLocations) {
		list[str] unitLines = readFileLines(unitLocation);
		int unitCodeLines = countCodeLines(unitLines);
		str unitRiskEvaluation = getUnitRiskEvaluation(unitCodeLines);
		riskEvaluationLines[unitRiskEvaluation] += unitCodeLines; 
		riskEvaluationLines["total"] += unitCodeLines;
	}
	return getRiskEvaluationPercentages(riskEvaluationLines);
}

/**
 * Returns a risk evaluation category based on the number of LOC. The 
 * thresholds and risk evaluation categories are based on table III in the 
 * paper "Benchmark-based Aggregation of Metrics to Ratings".
 *
 * @param unitCodeLines		The number of LOC (int).
 * @return 					The risk evaluation category (str).
 */
public str getUnitRiskEvaluation (int unitCodeLines) {
	if (unitCodeLines <= 30) {
		return "low";
	}
	else if (unitCodeLines > 30 && unitCodeLines <= 44) {
		return "moderate";
	}
	else if (unitCodeLines > 44 && unitCodeLines <= 74) {
		return "high";
	}
	else {
		return "very high";
	}
}

/**
 * Returns a unit size rank based on the risk evaluation percentages. The 
 * thresholds and ranks are based on table IV in the paper "Benchmark-based 
 * Aggregation of Metrics to Ratings".
 *
 * @param riskPercentages	The risk evaluation percentages (map[str, num]). 
 * @return 					The unit size rank (str).
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