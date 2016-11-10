module computeUnitComplexity

import IO;

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import helperFunctions;


public void computeUnitComplexityRank (loc projectSource) {
	m3Model = createM3FromEclipseProject(projectSource);
	methodLocations = methods(m3Model);
	riskPercentages = computeUnitComplexity(m3Model, methodLocations);
	println("Complexity per unit rank: " + getUnitComplexityRank(riskPercentages));
}

public map[str, num] computeUnitComplexity (M3 m3Model, set[loc] methodLocations) {
	riskEvaluationLines = ("low": 0, "moderate": 0, "high": 0, "very high": 0, "total": 0);
	for (methodLocation <- methodLocations) {
		methodLines = readFileLines(methodLocation);
		methodCodeLines = countCodeLines(methodLines); 
		methodAST = getMethodASTEclipse(methodLocation, model = m3Model);
		methodComplexity = calculateMethodComplexity(methodAST);
		methodRiskEvaluation = getMethodRiskEvaluation(methodComplexity);
		riskEvaluationLines[methodRiskEvaluation] += methodCodeLines;
		riskEvaluationLines["total"] += methodCodeLines;
	}
	return getRiskEvaluationPercentages(riskEvaluationLines);
}

public int calculateMethodComplexity (Declaration methodAST) {
    int complexity = 1;
    visit (methodAST) {
        case \if(_,_) : complexity += 1;
        case \if(_,_,_) : complexity += 1;
        case \case(_) : complexity += 1;
        case \do(_,_) : complexity += 1;
        case \while(_,_) : complexity += 1;
        case \for(_,_,_) : complexity += 1;
        case \for(_,_,_,_) : complexity += 1;
        case foreach(_,_,_) : complexity += 1;
        case \catch(_,_) : complexity += 1;
        case \conditional(_,_,_) : complexity += 1;
        case infix(_,"&&",_) : complexity += 1;
        case infix(_,"||",_) : complexity += 1;
    }
    return complexity;
}

// Evaluation is based on the table in the paper "A Practical Model for Measuring Maintainability".
public str getMethodRiskEvaluation (int methodComplexity) {
	if (methodComplexity >= 1 && methodComplexity <= 10) {
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

// Ranking is based on the table in the paper "A Practical Model for Measuring Maintainability".
public str getUnitComplexityRank (map[str, num] riskPercentages) {
	percentageModerate = riskPercentages["moderate"];
	percentageHigh = riskPercentages["high"];
	percentageVeryHigh = riskPercentages["very high"];
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