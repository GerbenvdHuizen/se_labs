module computeUnitSize

import IO;
import Map;
import String;

import lang::java::jdt::m3::Core;

import helperFunctions;


public void computeUnitSizeRank (loc projectSource) {
	m3Model = createM3FromEclipseProject(projectSource);
	methodLocations = methods(m3Model);
	riskPercentages = computeUnitSize(methodLocations);
	println("Unit size rank: " + getUnitSizeRank(riskPercentages));
}

public map[str, num] computeUnitSize (set[loc] methodLocations) {
	riskEvaluationLines = ("low": 0, "moderate": 0, "high": 0, "very high": 0, "total": 0);
	for (methodLocation <- methodLocations) {
		methodLines = readFileLines(methodLocation);
		methodCodeLines = countCodeLines(methodLines);
		methodRiskEvaluation = getMethodRiskEvaluation(methodCodeLines);
		riskEvaluationLines[methodRiskEvaluation] += methodCodeLines; 
		riskEvaluationLines["total"] += methodCodeLines;
	}
	return getRiskEvaluationPercentages(riskEvaluationLines);
}

// Rating is based on table III in the paper "Benchmark-based Aggregation of Metrics to Ratings".
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

// Ranking is based on table IV in the paper "Benchmark-based Aggregation of Metrics to Ratings".
public str getUnitSizeRank (map[str, num] riskPercentages) {
	percentageModerate = riskPercentages["moderate"];
	percentageHigh = riskPercentages["high"];
	percentageVeryHigh = riskPercentages["very high"];
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