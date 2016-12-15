/**
 * Software Evolution - University of Amsterdam
 * Practical Lab Series 2 - Clone Detection
 * computeVolume.rsc
 *
 * Vincent Erich - 10384081
 * Gerben van der Huizen - 10460748
 * December 2016
 */

module computeVolume

import IO;
import String;

import util::FileSystem;


/**
 * Returns the number of LOC of a Java project (i.e., the volume).
 *
 * @param projectSource		The location of the java project source (loc).
 * @return 					The number of LOC (int).
 */
public int getVolume (loc projectSource) {
	set[loc] sourceFiles = visibleFiles(projectSource);
	int totalCodeLines = 0;
	for (sourceFile <- sourceFiles) {
		list[str] lines = readFileLines(sourceFile);
		totalCodeLines += countCodeLines(lines);
	}
	return totalCodeLines;
}

/**
 * Given a list with lines from a source file, returns the number of LOC 
 * (i.e., excludes lines that are comments or only contain whitespace).
 *
 * @param lines		A list with lines from a source file (list[str]).
 * @return 			The number of LOC (int).
 */
public int countCodeLines (list[str] lines) {
	int codeLines = 0;
	for (line <- lines) {
		str trimmedLine = trim(line);
		if (/^\/\/.*/ !:= trimmedLine
			&& /^\/\*.*/ !:= trimmedLine
			&& /^\*.*/ !:= trimmedLine 
			&& /^\*\// !:= trimmedLine
			&& trimmedLine != "") {
			codeLines += 1;
		}
	}
	return codeLines;
}