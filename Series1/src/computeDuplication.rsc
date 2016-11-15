module computeDuplication

import IO;
import List;

import util::FileSystem;
import util::Math;

import helperFunctions;


// Not finished!

public num computeDuplicationRank (loc projectSource) {
	allCodeLines = [];
	sourceFiles = visibleFiles(projectSource);
	for (sourceFile <- sourceFiles) {
		lines = readFileLines(sourceFile);
		codeLines = returnCodeLines(lines);
		allCodeLines += codeLines;
	}
	duplicateCodeLines = computeDuplication(allCodeLines);
	duplicationPercentage = percent(duplicateCodeLines, size(allCodeLines));
	// Return a rank based on the percentage!
	return duplicationPercentage;
}

public int computeDuplication(list[str] allCodeLines) {
	codeBlock = [];
	codeBlocks = [];
	duplicateCodeLines = 0;
	for (i <- [1 .. (size(allCodeLines) + 1)] ) {
		codeBlock += allCodeLines[i - 1];
		if (i % 6 == 0) {
			if (codeBlock in codeBlocks) {
				duplicateCodeLines += 6;
			}
			else {
				codeBlocks += [codeBlock];	
			}
			codeBlock = [];
		}
	}
	return duplicateCodeLines;
}

//public void computeDuplication(list[str] allCodeLines) {
//	codeBlocks = [];
//	for (i <- [0 .. (size(allCodeLines) - 5)] ) {
//		codeBlock = [];
//		for (j <- [0 .. 6]) {
//			codeBlock += allCodeLines[i + j];
//		}
//		if (codeBlock in codeBlocks) {
//			println("Found duplicate code block:");
//			println(codeBlock);
//		}
//		else {
//			codeBlocks += [codeBlock];
//		}
//	}
//}