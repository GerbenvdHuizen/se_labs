module readDuplication

import IO;
import List;
import String;
import readVolume;

list[str] clearTabBracket(list[str] lines) {
	list[str] clearedLines = [];
	list[str] toClear = ["\t", "{", "}"];
	str temp;
	for(line <- lines) {
		tmp = line;
		for(char <- toClear ) {
			temp = trim(replaceAll(tmp, char, ""));
		}
		if(temp == "{" || temp == "}")
			temp = "";
		clearedLines += temp;			
	}
	return clearedLines;
}

public list[str] removeCommentsAndWspace(list[str] file){
	list[str] cleanLines = [];
	for(int i <- [0..(size(file) - 1)]){
    	if(!checkComment(file[i]) && !checkEmpty(file[i]) && /((\s|\/*)(\/\*|\s\*)|[^\w,\;]\s\/*\/)/ !:= file[i])
        	cleanLines += file[i];         
	} 
	return cleanLines;
}

public void countDuplicates(list[str] file)
{
	list[str] cleanStrings = removeCommentsAndWspace(clearTabBracket(file));
	//println(clearTabBracket(cleanStrings));
	list[str] nonDuplicates = [];
	int count = 0;
	int numDuplicates = 0;
	
	for(int i <- [0..size(cleanStrings) - 1]) {
		if(size(cleanStrings) > i && (cleanStrings[i] in nonDuplicates))
			count += 1;
		else {
			if(count > 5) 
				numDuplicates += 1;	
			nonDuplicates += cleanStrings[i];
			count = 0;
		}
	}
	println(nonDuplicates);
	println("Number of duplicates: <numDuplicates> ");
}

public void duplication(list[loc] project){
	for(s <- project){
		file = readFileLines(s.top);
		countDuplicates(file);
	}	
}