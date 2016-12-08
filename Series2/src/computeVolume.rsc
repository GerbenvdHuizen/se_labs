module computeVolume

import IO;
import String;

import util::FileSystem;


public int getVolume (loc projectSource) {
	set[loc] sourceFiles = visibleFiles(projectSource);
	int totalCodeLines = 0;
	for (sourceFile <- sourceFiles) {
		list[str] lines = readFileLines(sourceFile);
		totalCodeLines += countCodeLines(lines);
	}
	return totalCodeLines;
}

public int countCodeLines (list[str] lines) {
	int codeLines = 0;
	for (line <- lines) {
		str trimmedLine = trim(line);
		if (/^\/\/.*/ !:= trimmedLine
			&& /^\/\*.*/ !:= trimmedLine
			&& /^\*.*/ !:= trimmedLine 
			&& /^\*\// !:= trimmedLine
			&& trimmedLine != "") {
			//&& /^\/\*.*\*\/$+/ !:= trimmedLine) {
			codeLines += 1;
		}
	}
	return codeLines;
}