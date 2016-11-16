module computeDuplication

import IO;
import List;
import String;

import util::FileSystem;
import util::Math;

import helperFunctions;


public num computeDuplicationRank (loc projectSource) {
	duplicationPercentage = computeDuplication(projectSource);
	//println("Duplication rank: " + getDuplicationRank(duplicationPercentage));
	return duplicationPercentage; 
}

public num computeDuplication(loc projectSource) {
	allCodeLines = [];
	sourceFiles = visibleFiles(projectSource);
	for (sourceFile <- sourceFiles) {
		lines = readFileLines(sourceFile);
		codeLines = returnCodeLines(lines);
		allCodeLines += codeLines;
	}
	//----------
	allCodeLinesStr = oneString(allCodeLines);
	duplicateCodeLines2 = numDuplicateCodeLines2(allCodeLinesStr, allCodeLines);
	//----------
	duplicateCodeLines = numDuplicateCodeLines(allCodeLines);
	duplicationPercentage = percent(duplicateCodeLines, size(allCodeLines));
	return duplicationPercentage;
}

//----------
public str oneString(list[str] allCodeLines) {
	result = "";
	for (codeLine <- allCodeLines) {
		result += codeLine + "\n";
	}
	return result;
}

public int numDuplicateCodeLines2(str allCodeLinesStr, list[str] allCodeLinesList) {
	duplicateCodeLines = 0;
	loopCounter = 0;
	//for (i <- [0 .. (size(allCodeLinesList) - 1)] ) {
	while (loopCounter <= (size(allCodeLinesList) - 1)) {
		codeBlock = [];
		lineCounter = 0;
		check = true;
		while (check == true) {
			codeBlock += allCodeLinesList[loopCounter + lineCounter];
			if (lineCounter == 5) {
				codeBlockStr = oneString(codeBlock);
				if (size(findAll(allCodeLinesStr, codeBlockStr)) >= 2) {
					lineCounter += 1;
					println("Test");
				}
				else {
					check = false;
					duplicateCodeLines += lineCounter + 1;
					loopCounter += lineCounter;
				}
			}
		}
	}
	return duplicateCodeLines;
}
//----------

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

public int numDuplicateCodeLines(list[str] allCodeLines) {
	duplicateCodeLines = 0;
	codeBlocks = [];
	for (i <- [0 .. (size(allCodeLines) - 5)] ) {
		codeBlock = [];
		for (j <- [0 .. 6]) {
			codeBlock += allCodeLines[i + j];
		}
		if (codeBlock in codeBlocks) {
			duplicateCodeLines += 6;
		}
		else {
			codeBlocks += [codeBlock];
		}
	}
	return duplicateCodeLines;
}