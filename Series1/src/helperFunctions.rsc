module helperFunctions

import lang::java::m3::AST;
import IO;
import String;
import List;

public bool checkComment(str line) {
	str noWhiteSpace = trim(line);
	if(startsWith(noWhiteSpace, "//") 
		|| startsWith(noWhiteSpace, "/*") 
		|| startsWith(noWhiteSpace, "*")
		|| startsWith(noWhiteSpace, "*/"))
		return true;
	else
		return false;
}

public bool checkEmpty(str line) {
	str noWhiteSpace = trim(line);
	if(/^[ \t\r\n]*$/ := noWhiteSpace)
		return true;
	else
		return false;
}

int unitSize(loc methodLoc)	{
	list[str] lines = readFileLines(methodLoc);
	//println(removeCommentsAndWspace(lines));
	return size(removeCommentsAndWspace(lines));
}

public list[str] removeCommentsAndWspace(list[str] file){
	list[str] cleanLines = [];
	for(line <- file){
    	if(!checkComment(line) && !checkEmpty(line)) { //&& /((\s|\/*)(\/\*|\s\*)|[^\w,\;]\s\/*\/)/ !:= file[i]
        	cleanLines += line;
        }
        //else 
        	//println( "filtered: "+ file[i]);     
	} 
	return cleanLines;
}

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