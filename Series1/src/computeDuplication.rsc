module computeDuplication

import IO;
import List;
import String;

import util::FileSystem;
import util::Math;

import helperFunctions;


public void computeDuplicationRank (loc projectSource) {
	duplicationPercentage = computeDuplication(projectSource);
	println("Duplication rank: " + getDuplicationRank(duplicationPercentage)); 
}

public num computeDuplication(loc projectSource) {
	allCodeLines = [];
	sourceFiles = visibleFiles(projectSource);
	for (sourceFile <- sourceFiles) {
		lines = readFileLines(sourceFile);
		codeLines = returnCodeLines(lines);
		allCodeLines += codeLines;
	}
	allCodeLinesStr = oneString(allCodeLines);
	duplicateCodeLines = numDuplicateCodeLines(allCodeLinesStr, allCodeLines);
	duplicationPercentage = percent(duplicateCodeLines, size(allCodeLines));
	return duplicationPercentage;
}

public str oneString(list[str] allCodeLines) {
	result = "";
	for (codeLine <- allCodeLines) {
		result += codeLine + "\n";
	}
	return result;
}

public int numDuplicateCodeLines(str allCodeLinesStr, list[str] allCodeLinesList) {
	duplicateCodeLines = 0;
	loopCounter = 0;
	maxIndex = size(allCodeLinesList) - 1;
	while (loopCounter <= (size(allCodeLinesList) - 1)) {
		codeBlock = [];
		lineCounter = 0;
		check = true;
		while (check == true) {
			if (loopCounter + lineCounter > maxIndex) {
				loopCounter += 1;
				break;
			}
			else {
				codeBlock += allCodeLinesList[loopCounter + lineCounter];
				if (lineCounter >= 5) {
					codeBlockStr = oneString(codeBlock);
					if (size(findAll(allCodeLinesStr, codeBlockStr)) < 2) {
						check = false;
						if (lineCounter == 5) {
							loopCounter += 1;
							break;
						}
						else {
							check = false;
							duplicateCodeLines += lineCounter;
							loopCounter += lineCounter;
							break;
						}
					}
				}
				lineCounter += 1;
			}
		}
	}
	return duplicateCodeLines;
}

// Ranking is based on the table in the paper "A Practical Model for Measuring Maintainability".
public str getDuplicationRank(num duplicationPercentage) {
	if (duplicationPercentage >= 0 && duplicationPercentage <= 3) {
		return "++";
	}
	else if (duplicationPercentage > 3 && duplicationPercentage <= 5) {
		return "+";
	}
	else if (duplicationPercentage > 5 && duplicationPercentage <= 10) {
		return "o";
	}
	else if (duplicationPercentage > 10 && duplicationPercentage <= 20) {
		return "-";
	}
	else {
		return "--";
	}
}

//public int numDuplicateCodeLines(list[str] allCodeLines) {
//	codeBlock = [];
//	codeBlocks = [];
//	duplicateCodeLines = 0;
//	for (i <- [1 .. (size(allCodeLines) + 1)] ) {
//		codeBlock += allCodeLines[i - 1];
//		if (i % 6 == 0) {
//			if (codeBlock in codeBlocks) {
//				duplicateCodeLines += 6;
//			}
//			else {
//				codeBlocks += [codeBlock];	
//			}
//			codeBlock = [];
//		}
//	}
//	return duplicateCodeLines;
//}

//public int numDuplicateCodeLines(list[str] allCodeLines) {
//	duplicateCodeLines = 0;
//	codeBlocks = [];
//	for (i <- [0 .. (size(allCodeLines) - 5)] ) {
//		codeBlock = [];
//		for (j <- [0 .. 6]) {
//			codeBlock += allCodeLines[i + j];
//		}
//		if (codeBlock in codeBlocks) {
//			duplicateCodeLines += 6;
//		}
//		else {
//			codeBlocks += [codeBlock];
//		}
//	}
//	return duplicateCodeLines;
//}