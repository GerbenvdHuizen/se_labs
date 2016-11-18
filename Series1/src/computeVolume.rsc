/* 
* Software Evolution
* Series 1 code - Final version
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


/*
 * Creates a tuple containing the LOC and volume ranking.
 *
 * @param Location of a java project (loc).
 * @return Tuple with LOC (int) and a rank (str).
 */
public tuple[int, str] getVolume (loc projectSource) {
	int totalCodeLines = computeVolume(projectSource);
	str volumeRank = getVolumeRank(totalCodeLines);
	return <totalCodeLines, volumeRank>;
}

/*
 * Computes the volume or LOC of a Java project.
 *
 * @param Location of a java project (loc).
 * @return Volume or LOC (int).
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

/*
 * Determines the volume rank of a Java project based
 * on certain thresholds. The thresholds were taken from 
 * a table from page 25 of "A Practical Model for 
 * Measuring Maintainability".
 *
 * @param Volume or LOC (int).
 * @return The ranking (str).
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