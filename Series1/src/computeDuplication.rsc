/**
 * Software Evolution - University of Amsterdam
 * Practical Lab Series 1 - Software Metrics
 * computeDuplication.rsc
 *
 * Vincent Erich - 10384081
 * Gerben van der Huizen - 10460748
 * November 2016
 */
 
module computeDuplication

import IO;
import List;
import Set;
import String;

import util::FileSystem;
import util::Math;

import helperFunctions;


/**
 * Returns a tuple containing the duplication percentage of a Java project 
 * and the corresponding duplication rank.
 *
 * @param projectSource		The location of the Java project (loc).
 * @return 					A tuple with the duplication percentage and the 
 *							duplication rank (tuple[num, str]).
 */
public tuple[num, str] getDuplication (loc projectSource) {
	num duplicationPercentage = computeDuplication(projectSource);
	str duplicationRank = getDuplicationRank(duplicationPercentage);
	return <duplicationPercentage, duplicationRank>;
}

/**
 * Returns the duplication percentage of a Java project.
 *
 * @param projectSource		The location of the Java project (loc).
 * @return 					The duplication percentage (num).
 */
public num computeDuplication(loc projectSource) {
	set[loc] sourceFiles = visibleFiles(projectSource);
	lrel[str, int, int] codeLinesInfo = getFileAndCodeLineIndices(sourceFiles);
	int duplicateCodeLines = numDuplicateCodeLines(codeLinesInfo);
	num duplicationPercentage = percent(duplicateCodeLines, size(codeLinesInfo));
	return duplicationPercentage;
}

/**
 * Returns all the lines of code in a Java project together with the file 
 * index (i.e., the index of the file the line occurs in) and the line index 
 * (i.e., the index of the line of the file the line occurs in).
 *
 * @param sourceFiles	The locations of all the source files of the Java 
 *						project (set[loc]).
 * @return 				A list relation containing all the lines of code in 
 *						the Java project together with file indices and line 
 *						indices (lrel[str, int, int]).
 */
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

/**
 * Returns the number of duplicate lines of code by finding all the files
 * that contain duplicate lines of code and then finding blocks of duplicate 
 * lines in those files. 
 * Blocks of duplicate lines >= six lines.
 *
 * @param codeLinesInfo		A list relation containing all the lines of code 
 *							in the Java project together with file indices and 
 *							line indices (lrel[str, int, int]).
 * @return 					The number of duplicate code lines (int).
 */
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

/**
 * Returns a duplication rank based on the duplication percentage. The 
 * thresholds and ranks are based on the table in the paper "A Practical 
 * Model for Measuring Maintainability" (page 36).
 *
 * @param duplicationPercentage		The duplication percentage (num).
 * @return 							The duplication rank (str).
 */
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