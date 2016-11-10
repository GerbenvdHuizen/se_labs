module readDuplication

import IO;
import List;
import String;
import util::Math;
import helperFunctions;

public list[int] countDuplicates(list[str] file)
{
	list[str] cleanStrings = removeCommentsAndWspace(clearTabBracket(file));
	//println(clearTabBracket(cleanStrings));
	list[str] nonDuplicates = [];
	list[int] numbOfDuplicates = [];
	int count = 0;
	int numDuplicates = 0;

	
	for(int i <- [0..size(cleanStrings) - 1]) {
		if(size(cleanStrings) > i && (cleanStrings[i] in nonDuplicates))
			count += 1;
		else {
			if(count > 5) 
				numDuplicates += 1;	
				numbOfDuplicates += count;
			nonDuplicates += cleanStrings[i];
			count = 0;
		}
	}
	//println(nonDuplicates);
	//println("Number of duplicates: <numDuplicates> ");
	return numbOfDuplicates;
}

public int computeDuplication(set[loc] project){
	list[int] duplicates = [];
	n = 0;
	for(s <- project){
		file = readFileLines(s.top);
		int codeLines = size(removeCommentsAndWspace(file));
		n += codeLines;
		duplicates += countDuplicates(file);
	}
	int percentage = percent(sum(duplicates),n);
	
	println(percentage);
	int result;
	if(percentage <= 3) {
		result = 5;
	} else if(percentage > 3 && percentage <= 5) {
		result = 4;
	} else if(percentage > 5 && percentage <= 10) {
		result = 3;
	} else if(percentage > 10 && percentage <= 20) {
		result = 2;
	} else if(percentage > 20) {
		result = 1;
	}
	
	return result;
}