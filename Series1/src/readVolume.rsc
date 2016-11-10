module readVolume

import IO;
import String;
import List;
import helperFunctions;

public int computeVolume (set[loc] project){
	n = 0;
	for(s <- project){
		file = readFileLines(s.top);
		int codeLines = size(removeCommentsAndWspace(file));
		n += codeLines;
	}
	//println(n);
	int result;
	if(n <= 66000) {
		result = 5;
	} else if(n > 66000 && n <= 246000) {
		result = 4;
	} else if(n > 246000 && n <= 665000) {
		result = 3;
	} else if(n > 665000 && n <= 1310000) {
		result = 2;
	} else if(n > 1310000) {
		result = 1;
	}
	
	return result;
}