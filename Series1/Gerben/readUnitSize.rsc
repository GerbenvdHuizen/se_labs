module readUnitSize

import lang::java::m3::AST;
import analysis::graphs::Graph;
import IO;
import String;
import List;

public list[str] readFile(loc file){
	return readFileLines(file);
}

public list[int] getMethodLength(list[str] file){
  list[int] lengths = [];
  bool toCount = false;
  bool startCount = false;
  int counter = 0;
  for(s <- file) {
      switch(s){
		  case /public/: toCount = true;
		  case /void/: toCount = true;
		  case /int\s[a-z,A-Z]*\(\)|int\s[a-z,A-Z]*\([A-Z,a-z]*/: toCount = true;
		  case /boolean\s[a-z,A-Z]*\(\)|boolean\s[a-z,A-Z]*\([A-Z,a-z]*/: toCount = true;
		  case /String\s[a-z,A-Z]*\(\)|String\s[a-z,A-Z]*\([A-Z,a-z]*/: toCount = true;
		  case /[A-Z,a-z]*\s[a-z]*\(\)\{|[A-Z,a-z]*\s[a-z]*\([A-Z,a-z]*\s[a-z]*\)\{|[A-Z,a-z]*\s[a-z,A-Z]*\([A-Z,a-z]*\s[a-z]*\)\s[a-z]*/: toCount = true;
		  default: toCount = false;
	  }
	  if(toCount == true) {
	  	startCount = true;
	  }
	  if(s := "}") {
	  	startCount = false;
	  	lengths = lengths + counter;
	  	counter = 0;
	  }
	  if(startCount == true && /^[ \t\r\n]*$/ !:= s) {
	  	counter += 1;
	  } 
  }
  return lengths;
}

public int getAverageMethodLength(list[loc] project){
	list[int] mLength = [];
	for(s <- project){
		file = readFile(s.top);
		mLength = mLength + getMethodLength(file);
	}
	println(mLength);
	return sum(mLength)/size(mLength);	
}

lrel[loc, int] unitSizePM(list[Declaration]methodNodes) {
	lrel[loc, int] methodUnitSize = []; 
	 
	for(methodNode <- methodNodes) {
		if(/method(m,_,_,_) := methodNode@typ) {
			unitS = unitSize(m);
			methodUnitSize += <m, unitS>;
		}				
	}
	
	return methodUnitSize;
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

int unitSize(loc methodLoc)	{
	list[str] lines = clearTabBracket(readFileLines(methodLoc));
	//println(removeCommentsAndWspace(lines));
	return size(removeCommentsAndWspace(lines));
}

public list[str] removeCommentsAndWspace(list[str] file){
	list[str] cleanLines = [];
	for(int i <- [0..(size(file) - 1)]){
    	if(!checkComment(file[i]) && !checkEmpty(file[i]) && /((\s|\/*)(\/\*|\s\*)|[^\w,\;]\s\/*\/)/ !:= file[i])
        	cleanLines += file[i];         
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

void testUnitSize(loc project){
	list[Declaration] methodAsts = [ d | /Declaration d := createAstFromFile(project, true), d is method];
	//Anode = createAstFromFile(project,true);
	
	lrel[loc,int] unitSizeAll = unitSizePM(methodAsts);
	println(unitSizeAll);
	lrel[loc,int] lowRisk = [<l,x> | <l,x> <- unitSizeAll, x <= 20];
	lrel[loc,int] moderateRisk = [<l,x> | <l,x> <- unitSizeAll, x > 20, x <= 50];
	lrel[loc,int] highRisk = [<l,x> | <l,x> <- unitSizeAll, x > 50, x <= 100];
	lrel[loc,int] veryHighRisk = [<l,x> | <l,x> <- unitSizeAll, x > 100];
}