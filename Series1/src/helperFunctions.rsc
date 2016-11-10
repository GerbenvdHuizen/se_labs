module helperFunctions

import IO;
import String;

import util::Math;


public int countCodeLines (list[str] lines) {
	codeLines = 0;
	for (line <- lines) {
		trimmedLine = trim(line);
		if (/^\/\/.*/ !:= trimmedLine
			//!startsWith(trimmedLine, "//")
			&& /^\/\*.*/ !:= trimmedLine
			//&& !startsWith(trimmedLine, "/*")
			&& /^\*.*/ !:= trimmedLine 
			//&& !startsWith(trimmedLine, "*")
			&& /^\*\// !:= trimmedLine
			//&& !startsWith(trimmedLine, "*/")
			&& trimmedLine != "") {
			//&& /^\/\*.*\*\/$+/ !:= trimmedLine) {
			codeLines += 1;
		}
		//else {
		//	println("Filtered out: " + trimmedLine);
		//}
	}
	return codeLines;
}

public map[str, num] getRiskEvaluationPercentages (map[str, int] riskEvaluationLines) {
	riskEvaluationPercentages = ("low": 0.0, "moderate": 0.0, "high": 0.0, "very high": 0.0);
	totalMethodLines = riskEvaluationLines["total"];
	riskEvaluationPercentages["low"] = percent(riskEvaluationLines["low"], totalMethodLines);
	riskEvaluationPercentages["moderate"] = percent(riskEvaluationLines["moderate"], totalMethodLines);
	riskEvaluationPercentages["high"] = percent(riskEvaluationLines["high"], totalMethodLines);
	riskEvaluationPercentages["very high"] = percent(riskEvaluationLines["very high"], totalMethodLines);
	return riskEvaluationPercentages;
}