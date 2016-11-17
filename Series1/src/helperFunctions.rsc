module helperFunctions

import IO;
import String;

import util::Math;


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

public map[str, num] getRiskEvaluationPercentages (map[str, int] riskEvaluationLines) {
	map[str, num] riskEvaluationPercentages = ("low": 0, "moderate": 0, "high": 0, "very high": 0);
	int totalMethodCodeLines = riskEvaluationLines["total"];
	riskEvaluationPercentages["low"] = percent(riskEvaluationLines["low"], totalMethodCodeLines);
	riskEvaluationPercentages["moderate"] = percent(riskEvaluationLines["moderate"], totalMethodCodeLines);
	riskEvaluationPercentages["high"] = percent(riskEvaluationLines["high"], totalMethodCodeLines);
	riskEvaluationPercentages["very high"] = percent(riskEvaluationLines["very high"], totalMethodCodeLines);
	return riskEvaluationPercentages;
}