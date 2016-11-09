module readVolume

import IO;
import String;
import List;

// Test...

public int blankLines(list[str] file){
	n = 0;
  for(s <- file)
    if(/^[ \t\r\n]*$/ := s)  
      n +=1;
  return n;
}

public int commentLines(list[str] file){
  n = 0;
  for(s <- file)
    if(/((\s|\/*)(\/\*|\s\*)|[^\w,\;]\s\/*\/)/ := s)   
      n +=1;
  return n;
}

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

public int countCodeLines (list[loc] project){
	n = 0;
	for(s <- project){
		file = readFileLines(s.top);
		println(removeCommentsAndWspace(clearTabBracket(file)));
		int codeLines = size(removeCommentsAndWspace(clearTabBracket(file)));
		n += codeLines;
	}
	return n;	
}