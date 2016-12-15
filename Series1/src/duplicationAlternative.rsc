/**
 * Software Evolution - University of Amsterdam
 * Practical Lab Series 1 - Software Metrics
 * duplicationAlternative.rsc
 *
 * Vincent Erich - 10384081
 * Gerben van der Huizen - 10460748
 * November 2016
 */
 
module duplicationAlternative

import IO;
import List;
import String;

import util::FileSystem;
import util::Benchmark;
import util::Math;

import helperFunctions;

/**
 * Prints the duplication percentage of a Java project and the corresponding 
 * duplication rank in the console.
 *
 * @param projectSource		The location of the Java project source (loc).
 */
public void computeDuplicationRank (loc projectSource) {
	cpuDuplicationStart = cpuTime();
	duplicationPercentage = computeDuplication(projectSource);
	cpuDuplicationEnd = cpuTime(); 
	println("Duplication percentage: <duplicationPercentage> %.");
	println("Duplication rank: <getDuplicationRank(duplicationPercentage)>.");
	println("Time to calculate duplication: <round((cpuDuplicationEnd - cpuDuplicationStart) / 1000000000.0)> sec."); 
}

/**
 * Returns the duplication percentage of a Java project.
 *
 * @param projectSource		The location of the Java project source (loc).
 * @return 					The duplication percentage (num).
 */
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

/**
 * Returns a list with strings as one string.
 *
 * @param lines		The list with strings (list[str]).
 * @return			The list with strings as one string (str).
 */
public str oneString(list[str] lines) {
	result = "";
	for (line <- lines) {
		result += line + "\n";
	}
	return result;
}

/**
 * Returns the number of duplicate lines of code in the Java project.
 * Start with the first line of the first (filtered) source file, create a 
 * code block of six consecutive lines, and check whether that code block 
 * occurs in any of the other source files (or in the same source file). If 
 * not, then take the next code block of six consecutive lines, etc. If so, 
 * then incrementally add one line to the code block until no match is found 
 * in any of the other source files. Aggregate the number of lines of code 
 * found in each duplicate code block and return this number.
 *
 * @param allCodeLinesStr	All source code lines of the Java project as a 
 *							single string (str).
 * @param allCodeLinesList 	All source code lines of the Java project in a 
 *							list (list[str]).
 * @return 					The number of duplicate lines of code in the Java 
 * 							project (int).
 */
public int numDuplicateCodeLines(str allCodeLinesStr, list[str] allCodeLinesList) {
	duplicateCodeLines = 0;
	loopCounter = 0;
	maxIndex = size(allCodeLinesList) - 1;
	while (loopCounter <= maxIndex) {
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