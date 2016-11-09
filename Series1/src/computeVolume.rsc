module computeVolume

import IO;
import List;
import String;

public int computeVolume (list[loc] locations) {
	totalLines = 0;
	for (sourceFile <- locations) {
		lines = readFileLines(sourceFile);
		totalLines += countCodeLines(lines);
	}
	return totalLines;
}

public int countCodeLines (list[str] lines) {
	codeLines = 0;
	for (line <- lines) {
		trimmedLine = trim(line);
		if (/^\/\/.*/ !:= trimmedLine
			//!startsWith(trimmedLine, "//")
			&& /^\/\*.*/ !:= trimmedLine
			//&& !startsWith(trimmedLine, "/*")
			&& /^\*.*/ !:= trimmedLine 
			//&& !startsWith(trimmedLine, "*")
			&& /^\*\// !:= trimmedLine
			//&& !startsWith(trimmedLine, "*/")
			&& trimmedLine != ""
			&& /^\/\*.*\*\/$+/ !:= trimmedLine) {
			codeLines += 1;
		}
		else {
			println("Filtered out: " + trimmedLine);
		}
	}
	return codeLines;
}