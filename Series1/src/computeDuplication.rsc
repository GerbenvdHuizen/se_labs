module computeDuplication

import IO;
import List;
import String;
import Set;

import util::FileSystem;
import util::Math;

import helperFunctions;


public void computeDuplicationRank (loc projectSource) {
	num duplicationPercentage = computeDuplication(projectSource);
	println("Duplication rank: " + getDuplicationRank(duplicationPercentage)); 
}

public num computeDuplication(loc projectSource) {
	set[loc] sourceFiles = visibleFiles(projectSource);
	lrel[str, int, int] codeLinesInfo = getFileAndCodeLineIndices(sourceFiles);
	int duplicateCodeLines = numDuplicateCodeLines(codeLinesInfo); 
	println(duplicateCodeLines);
	num duplicationPercentage = percent(duplicateCodeLines, size(codeLinesInfo));
	return duplicationPercentage;
}

public lrel[str, int, int] getFileAndCodeLineIndices(set[loc] sourceFiles) {
	lrel[str, int, int] codeLinesInfo = [];
	int fileIndex = 1;
	for (sourceFile <- sourceFiles) {
		int lineIndex = 1;
		list[str] lines = readFileLines(sourceFile);
		list[str] codeLines = returnCodeLines(lines);
		for (codeLine <- codeLines) {
			codeLinesInfo += <codeLine, fileIndex, lineIndex>;
			lineIndex += 1;
		}
		fileIndex += 1;
	}
	return codeLinesInfo;
}

public int numDuplicateCodeLines(lrel[str, int, int] codeLinesInfo) {
	list[str] duplicateCodeLines = [line | <line, fileIndex, lineIndex> <- codeLinesInfo] - dup([line | <line, fileIndex, lineIndex> <- codeLinesInfo]);
	lrel[str, int, int] duplicateCodeLinesInfo = [<line, fileIndex, lineIndex> | <line, fileIndex, lineIndex> <- codeLinesInfo, line in duplicateCodeLines];
	set[int] fileIndicesDuplicates = {fileIndex | <line, fileIndex, lineIndex> <- duplicateCodeLinesInfo};
	int numDuplicateCodeLines = 0;
	for (fileIndex <- fileIndicesDuplicates) {
		list[int] lineIndicesDuplicates = sort({z | <x, y, z> <- duplicateCodeLinesInfo, y == fileIndex});
		if (size(lineIndicesDuplicates) > 5) {
			int counter = 0;
			int maxIndex = size(lineIndicesDuplicates) - 1;
			while (maxIndex >= counter + 1) {
				int countDuplicateCodeLines = 0;
				int lineIndex = lineIndicesDuplicates[counter];
				counter += 1;
				lineIndex += 1;
				while (maxIndex >= counter && lineIndex == lineIndicesDuplicates[counter]) {
					counter += 1;
					lineIndex += 1;
					countDuplicateCodeLines += 1;
				}
				if (countDuplicateCodeLines > 5) {
					numDuplicateCodeLines += countDuplicateCodeLines;
				}
			}
		} 	
	}
	return numDuplicateCodeLines;
}

//public str oneString(list[str] allCodeLines) {
//	str result = "";
//	for (codeLine <- allCodeLines) {
//		result += codeLine + "\n";
//	}
//	return result;
//}

//public int numDuplicateCodeLines(str allCodeLinesStr, list[str] allCodeLinesList) {
//	int duplicateCodeLines = 0;
//	int loopCounter = 0;
//	int maxIndex = size(allCodeLinesList) - 1;
//	while (loopCounter <= (size(allCodeLinesList) - 1)) {
//		list[str] codeBlock = [];
//		int lineCounter = 0;
//		bool check = true;
//		while (check == true) {
//			if (loopCounter + lineCounter > maxIndex) {
//				loopCounter += 1;
//				break;
//			}
//			else {
//				codeBlock += allCodeLinesList[loopCounter + lineCounter];
//				if (lineCounter >= 5) {
//					codeBlockStr = oneString(codeBlock);
//					if (size(findAll(allCodeLinesStr, codeBlockStr)) < 2) {
//						check = false;
//						if (lineCounter == 5) {
//							loopCounter += 1;
//							break;
//						}
//						else {
//							check = false;
//							duplicateCodeLines += lineCounter;
//							loopCounter += lineCounter;
//							break;
//						}
//					}
//				}
//				lineCounter += 1;
//			}
//		}
//	}
//	return duplicateCodeLines;
//}

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