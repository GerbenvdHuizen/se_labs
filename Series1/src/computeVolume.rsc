/**
 * Software Evolution - University of Amsterdam
 * Practical Lab Series 1 - Software Metrics
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
public tuple[int, str] getVolume (loc projectSource) {
	int totalCodeLines = computeVolume(projectSource);
	str volumeRank = getVolumeRank(totalCodeLines);
	return <totalCodeLines, volumeRank>;
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

/**
 * Returns a volume rank based on the number of LOC. The thresholds and ranks 
 * are based on the table in the paper "A Practical Model for Measuring 
 * Maintainability" (page 34).
 *
 * @param totalCodeLines	The number of LOC (int).
 * @return 					The volume rank (str).
 */
public str getVolumeRank (int totalCodeLines) {
	if (totalCodeLines <= 66000) {
		return "++";
	}
	else if (totalCodeLines > 66000 && totalCodeLines <= 246000) {
		return "+";
	}
	else if (totalCodeLines > 246000 && totalCodeLines <= 665000) {
		return "o";
	}
	else if (totalCodeLines > 665000 && totalCodeLines <= 1310000) {
		return "-";
	}
	else {
		return "--";
	}
}