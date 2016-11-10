module computeVolume

import IO;
import List;
import String;

import util::FileSystem;

import helperFunctions;

public void computeVolumeRank (loc projectSource) {
	totalCodeLines = computeVolume(projectSource);
	println("Volume rank: " + getVolumeRank(totalCodeLines));
}

public int computeVolume (loc projectSource) {
	sourceFiles = visibleFiles(projectSource);
	totalCodeLines = 0;
	for (sourceFile <- sourceFiles) {
		lines = readFileLines(sourceFile);
		totalCodeLines += countCodeLines(lines);
	}
	return totalCodeLines;
}

// Ranking is based on the table in the paper "A Practical Model for Measuring Maintainability".
public str getVolumeRank (int totalCodeLines) {
	if (totalCodeLines >= 0 && totalCodeLines <= 66000) {
		return "++";
	}
	else if (totalCodeLines > 6600 && totalCodeLines <= 246000) {
		return "+";
	}
	else if (totalCodeLines > 246000 && totalCodeLines <= 665000) {
		return "o";
	}
	else if (totalCodeLines > 665 && totalCodeLines <= 1310000) {
		return "-";
	}
	else {
		return "--";
	}
}