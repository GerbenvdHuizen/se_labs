/* 
* Software Evolution
* Series 1 code - Final version
* computeDuplication.rsc
*
* Vincent Erich - 10384081
* Gerben van der Huizen - 10460748
* November 2016
*/
module computeDuplication

import IO;
import List;
import String;
import Set;
import util::FileSystem;
import util::Math;
import helperFunctions;


/*
 * Creates a tuple containing the percentage of duplicates
 * and the duplication ranking.
 *
 * @param Location of a java project (loc).
 * @return Tuple with the percentage of duplication (num) and a rank (str).
 */
public tuple[num, str] getDuplication (loc projectSource) {
	num duplicationPercentage = computeDuplication(projectSource);
	str duplicationRank = getDuplicationRank(duplicationPercentage);
	return <duplicationPercentage, duplicationRank>;
}

/*
 * Computes the percentage of duplicates in the code of a java project.
 *
 * @param Location of a java project (loc).
 * @return The percentage of duplication (num) in the input code (project).
 */
public num computeDuplication(loc projectSource) {
	set[loc] sourceFiles = visibleFiles(projectSource);
	lrel[str, int, int] codeLinesInfo = getFileAndCodeLineIndices(sourceFiles);
	int duplicateCodeLines = numDuplicateCodeLines(codeLinesInfo);
	num duplicationPercentage = percent(duplicateCodeLines, size(codeLinesInfo));
	return duplicationPercentage;
}

/*
 * Returns all the line of code from a project with an line index
 * (which line number in a file is the line located on) and a file index 
 * (which file does the line come from).
 *
 * @param Locations of all files of a Java project (set[loc]).
 * @return List containing all lines of code of a java project
 * with line and file indices (lrel[str,int,int]).
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

/*
 * Returns the number of duplicate lines of code by finding all the files
 * with duplicates and then finding the blocks of duplicate code in those files.
 * The blocks of duplicate code have to contain at least 6 lines.
 *
 * @param List containing all lines of code of a java project
 * with line and file indices (lrel[str,int,int]).
 * @return The Number of duplicate lines found in the code of a Java project (int).
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

/*
 * Determines the Duplication rank of a Java project based
 * on certain thresholds. The thresholds were taken from 
 * a table from page 27 of "A Practical Model for 
 * Measuring Maintainability".
 *
 * @param Duplication percentage (num).
 * @return The ranking (str).
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