module readComplexityPerUnit

import lang::java::m3::AST;
import IO;
import String;
import List;
import Node;

public list[str] readFile(loc file){
	return readFileLines(file);
}

public int countMethods(list[str] file){
  n = 0;
  for(s <- file) {
      switch(s){
	  case /public/: n += 1;
	  case /void/: n += 1;
	  case /int\s[a-z,A-Z]*\(\)|int\s[a-z,A-Z]*\([A-Z,a-z]*/: n += 1;
	  case /boolean\s[a-z,A-Z]*\(\)|boolean\s[a-z,A-Z]*\([A-Z,a-z]*/: n += 1;
	  case /String\s[a-z,A-Z]*\(\)|String\s[a-z,A-Z]*\([A-Z,a-z]*/: n += 1;
	  case /[A-Z,a-z]*\s[a-z]*\(\)\{|[A-Z,a-z]*\s[a-z]*\([A-Z,a-z]*\s[a-z]*\)\{|[A-Z,a-z]*\s[a-z,A-Z]*\([A-Z,a-z]*\s[a-z]*\)\s[a-z]*/: n += 1;
	  }
  }
  return n;
}

public int countStatements(list[str] file){
	n = 0;
  	for(s <- file) {
      	switch(s){
		  case /if\(\w*(\)|\w*)(\s|[\,,\s,\.]*)/: n += 1;
		  case /for\(/: n += 1;
		  case /\swhile\(([\w]*\.[\w]*\(\)|true|\w*\(\)|\w*[\>,\=,\<]*)(\)\{|)/: n += 1;
		  case /do\{/: n += 1;
		}
    }
  	return n; 
}


public int countNodes (list[loc] project){
	nodes = 0;
	for(s <- project){
		file = readFile(s.top);
		println(file);
		nodes += countMethods(file);
		nodes += countStatements(file);
	}
	return nodes;	
}


lrel[loc, int, int] complexityPerUnit(list[Declaration]methodNodes) {
	lrel[loc, int, int] methodCPU = []; 
	 
	for(methodNode <- methodNodes) {
		int result = 1;
		
		//println(getAnnotations(methodNode));
		
		visit(methodNode) {
	  		case foreach(_,_,_) : result += 1;
	  		case \for(_,_,_,_) : result += 1;
	  		case \for(_,_,_) : result += 1;
			case \if(_,_) : result += 1;
			case \if(_,_,_) : result += 1;
			case \case(_) : result += 1;	
			case \while(_,_) : result += 1;
			case \catch(_,_) : result += 1;			
		}
		println(result);
		if(/method(m,_,_,_) := methodNode@typ) {
			unitS = unitSize(m);
			methodCPU += <m, result, unitS>;
		}				
	}
	
	return methodCPU;
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

void testCPU(loc project){
	list[Declaration] methodAsts = [ d | /Declaration d := createAstFromFile(project, true), d is method];
	//Anode = createAstFromFile(project,true);
	lrel[loc,int,int] methodCPU = complexityPerUnit(methodAsts);
	println(methodCPU);
	lrel[loc,int,int] lowRisk = [<l,x,y> | <l,x,y> <- methodCPU, x <= 10];
	lrel[loc,int,int] moderateRisk = [<l,x,y> | <l,x,y> <- methodCPU, x > 10, x <= 20];
	lrel[loc,int,int] highRisk = [<l,x,y> | <l,x,y> <- methodCPU, x > 20, x <= 50];
	lrel[loc,int,int] veryHighRisk = [<l,x,y> | <l,x,y> <- methodCPU, x > 50];
}
