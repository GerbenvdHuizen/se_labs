/**
 * Software Evolution - University of Amsterdam
 * Practical Lab Series 2 - Software Metrics
 * computeVolume.rsc
 *
 * Vincent Erich - 10384081
 * Gerben van der Huizen - 10460748
 * November 2016
 */

module computeVolume

import IO;

import util::FileSystem;

import helperFunctions;


/**
 * Returns a tuple containing the number of LOC of a Java project and the 
 * corresponding volume rank.
 *
 * @param projectSource		The location of the java project source (loc).
 * @return 					A tuple with the number of LOC and the volume rank 
 *							(tuple[int, str]).
 */
public int getVolume (loc projectSource) {
	int totalCodeLines = computeVolume(projectSource);
	return totalCodeLines;
}

/**
 * Returns the number of LOC of a Java project (i.e., the volume).
 *
 * @param projectSource		The location of the java project source (loc).
 * @return 					The number of LOC (int).
 */
public int computeVolume (loc projectSource) {
	set[loc] sourceFiles = visibleFiles(projectSource);
	int totalCodeLines = 0;
	for (sourceFile <- sourceFiles) {
		list[str] lines = readFileLines(sourceFile);
		totalCodeLines += countCodeLines(lines);
	}
	return totalCodeLines;
}
