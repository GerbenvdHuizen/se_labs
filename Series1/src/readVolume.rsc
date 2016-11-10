module readVolume

import IO;
import String;
import List;
import helperFunctions;

public void countCodeLines (list[loc] project){
	n = 0;
	for(s <- project){
		file = readFileLines(s.top);
		//println(removeCommentsAndWspace(clearTabBracket(file)));
		int codeLines = size(removeCommentsAndWspace(file));
		n += codeLines;
	}
	println(n);
	str result;
	if(n <= 66000) {
		result = "++";
	} else if(n > 66000 && n <= 246000) {
		result = "+";
	} else if(n > 246000 && n <= 665000) {
		result = "o";
	} else if(n > 665000 && n <= 1310000) {
		result = "-";
	} else if(n > 1310000) {
		result = "--";
	}
	
	println(result);
}