module detectCloneType1

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import lang::csv::IO;

import List;
import IO;
import Set;
import Prelude;
import Map;
import util::Math;
import util::FileSystem;

import computeVolume;
import helperFunctions;

public loc selectedProject = |project://Assignment1/src/|;
public map[node, lrel[node, loc]] buckets = ();
public list[node] subCloneClasses = [];


public int massThreshold;
public real similarityThreshold;

public map[node, lrel[tuple[node, loc], tuple[node, loc]]] cloneClasses = ();

public void clone1Detection() {
	
	massThreshold = 10;
	similarityThreshold = 1.0;
	
	//model = createM3FromEclipseProject(selectedProject);
	
	ast = createAstsFromEclipseProject(selectedProject, true);
	//ast = normalizeNames(ast);
	
	buckets = ();

	visit (ast) {
		case node x: {
			int currentMass = getNodeMass(x);
			if (currentMass >= massThreshold) {
				node normalizedNode = normalizeNames(x);
				fillBucketList(normalizedNode);
				
			}
		}
	}
	
	println("Filled bucket list.");
	
	for (bucket <- buckets) {
		if (size(buckets[bucket]) >= 2) {
			lrel[tuple[node,loc] Left, tuple[node,loc] Right] bucketPairs = [];
			bucketPairs += buckets[bucket] * buckets[bucket];
			
			bucketPairs = [pair | pair <- bucketPairs, pair.Left != pair.Right];
			bucketPairs = removeSymm(bucketPairs);
				
			for (bucketPair <- bucketPairs) {
				num similarity = computeSimilarity(bucketPair[0][0], bucketPair[1][0])*1.0;
				if (similarity >= similarityThreshold) {
					cloneClasses[bucketPair[0][0]] = bucketPair[0][0] in cloneClasses ? 
														cloneClasses[bucketPair[0][0]] + bucketPair : [bucketPair];
				}
			}
		}
	}
	
	//println(size(cloneClasses));
	for (currentClass <- cloneClasses) {
		for (currentClone <- cloneClasses[currentClass]) {
			checkSubsumeClone(currentClone[0]);
			checkSubsumeClone(currentClone[1]);
		}
	}
	
	println("remove subsume clones...");
	
	for (subCloneClass <- subCloneClasses) {
		cloneClasses = delete(cloneClasses, subCloneClass);
	}
	

	lrel[tuple[node, loc], tuple[node, loc]] cloneValues = [v | <k,v> <- toRel(cloneClasses)];
	cloneClassSizes = [size(cloneClasses[k]) | k:_ <- cloneClasses];
	//println(sum(cloneClassSizes));
	tuple[int,int,int,list[loc]] cloningStatisctics = getCloningStatistics(cloneValues);
	println("The percentage of duplication in the project is <cloningStatisctics[0]>%.");
	println("<size(cloneClasses)> clone classes were extracted from the project.");
	println("The biggest clone class of the project has <max(cloneClassSizes)> clone pairs.");
	println("The project contains <cloningStatisctics[1]> unique clones.");
	println("The largest clone of the project has <cloningStatisctics[2]> lines.");
	
	fileRelationList = getCloneGraphData(cloneClasses);
	
	rel[str file1, str file2, int cloneAmount] R1 = createDataSet(visibleFiles(selectedProject), fileRelationList);
	//rel[str file1, str file2, int cloneAmount] R1 = createDataSet(toSet(cloningStatisctics[3]), fileRelationList);
	//println(R1);
	writeCSV(R1, |file:///xampp/htdocs/series2SE/allFiles.csv|);
	//writeFile(|project://Series2/src/cloneClass.txt/|, oneString(stringClones));

}

public str oneString(list[str] allCodeLines) {
	result = "";
	for (codeLine <- allCodeLines) {
		result += codeLine + "\n";
	}
	return result;
}

public rel[str,str,int] createDataSet(set[loc] allFiles, lrel[str,str] cloneRelations){
	rel[str,str,int] cloneDataSet = {};
	count = 0;
	for(file <- allFiles) {
		for(fileRel <- allFiles) {
			counter = 0;
			for(relation <- cloneRelations) {
				if((relation[0] == file.file && relation[1] == fileRel.file) || (relation[1] == file.file && relation[0] == fileRel.file)) {
					counter += 1;
				}
				
			}
			if(counter > 0) {
				//cloneDataSet += {<file.file, fileRel.file, counter>};
				//println({<file.file, fileRel.file, counter>});
				count += 1;
			}
			cloneDataSet += {<file.file, fileRel.file, counter>};
			//println({<file.file, fileRel.file, counter>});
			
		}
	}
	println(count);
	return cloneDataSet;
}


public lrel[str,str] getCloneGraphData(map[node, lrel[tuple[node, loc], tuple[node, loc]]] cloneClasses) {
	lrel[str,str] allPairs = [];
	for(cloneNode <- cloneClasses) {
		for(pair <- cloneClasses[cloneNode]) {
				allPairs += <pair[0][1].file, pair[1][1].file>;
		}
	}
	
	return allPairs;
}  
public tuple[int,int,int,list[loc]] getCloningStatistics(lrel[tuple[node, loc], tuple[node, loc]] nodeValues) {
	uniqueNodeSizes = [];
	uniqueLocations = [];
	
	for(pair <- nodeValues) {
		if(pair[0][1] notin uniqueLocations) {
			uniqueLocations += pair[0][1];
			uniqueNodeSizes += countCodeLines(readFileLines(pair[0][1]));
		} 
		if(pair[1][1] notin uniqueLocations) {
			uniqueLocations += pair[1][1];
			uniqueNodeSizes += countCodeLines(readFileLines(pair[1][1]));
		} 
	}
	projectVolume = getVolume(selectedProject);
	//println(projectVolume);
	//println(size(uniqueNodeSizes));
	//println(uniqueLocations);
	return(<percent(sum(uniqueNodeSizes), projectVolume),size(uniqueNodeSizes), max(uniqueNodeSizes), uniqueLocations>);
}

public num computeSimilarity(node t1, node t2) {
	//Similarity = 2 x S / (2 x S + L + R)
	
	list[node] tree1 = [];
	list[node] tree2 = [];
	
	visit (t1) {
		case node x: {
			tree1 += x;
		}
	}
	
	visit (t2) {
		case node x: {
			tree2 += x;
		}
	}
	
	num s = size(tree1 & tree2);
	num l = size(tree1 - tree2);
	num r = size(tree2 - tree1); 
		
	num similarity = (2 * s) / (2 * s + l + r); 
	
	return similarity;
}


public void fillBucketList(node inputNode) {

	loc nodeLocation = extractNodeLocation(inputNode);
	
	if (nodeLocation != selectedProject && (nodeLocation.end.line - nodeLocation.begin.line) >= 6) {	
		if( (Declaration d := inputNode || Statement d := inputNode || Expression d := inputNode) && ("src" in getAnnotations(inputNode))) 
			buckets[d] = d in buckets ? buckets[d] + <inputNode,nodeLocation> : [<inputNode,nodeLocation>];
	}
}

public int getNodeMass(node inputNode) {
	int mass = 0;
	visit (inputNode) {
		case node x: {
			mass += 1;
		}
	}
	return mass;
}

public loc extractNodeLocation(node inputNode) {
	
	switch(inputNode) {
		case Declaration d : if(d@src?) return d@src;
		case Expression e : if(e@src?) return e@src;
		case Statement s: if(s@src?) return s@src;
		default: return selectedProject;
	}
	
	return selectedProject;
}

public lrel[tuple[node,loc],tuple[node,loc]] removeSymm(lrel[tuple[node,loc],tuple[node,loc]] allClonePairs) {
	newClonePairs = [];
	for (clonePair <- allClonePairs) {
		reversePair = <<clonePair[1][0],clonePair[1][1]>,<clonePair[0][0],clonePair[0][1]>>;
		if (reversePair notin newClonePairs) {		
			newClonePairs += clonePair;
		}
	}
	return newClonePairs;
}

public void checkSubsumeClone(tuple[node,loc] clone) {
	visit (clone[0]) {
		case node n: {
			if (n != clone[0]) {
				if (getNodeMass(n) >= massThreshold) {
					tuple[node,loc] currentNode = <n, extractNodeLocation(n)>;
					if (isClone(currentNode)) {
						subCloneClasses += n;
					}
					
				}
			}
		}
	}
}

public bool isClone(tuple[node,loc] possibleClone) {
	for (cloneClass <- cloneClasses) {
		for (pair <- cloneClasses[cloneClass]) {
			if ((possibleClone[1] <= pair[0][1] && pair[0][0] == possibleClone[0]) || (possibleClone[1] <= pair[1][1] && pair[1][0] == possibleClone[0])) {
				if (cloneClasses[possibleClone[0]]?) {
					if (size(cloneClasses[possibleClone[0]]) == size(cloneClasses[cloneClass])) {
						return true;
					}
				}
			} 
		}
	}
	
	return false;
}

public node normalizeNames( node ast ) {
	return visit (ast) {
		case \method(x, _, y, z, q) => \method(lang::java::jdt::m3::AST::short(), "methodName", y, z, q)
		case \method(x, _, y, z) => \method(lang::java::jdt::m3::AST::short(), "methodName", y, z)
		case \parameter(x, _, z) => \parameter(x, "paramName", z)
		case \vararg(x, _) => \vararg(x, "varArgName") 
		case \annotationTypeMember(x, _) => \annotationTypeMember(x, "annonName")
		case \annotationTypeMember(x, _, y) => \annotationTypeMember(x, "annonName", y)
		case \typeParameter(_, x) => \typeParameter("typeParaName", x)
		case \constructor(_, x, y, z) => \constructor("constructorName", x, y, z)
		case \interface(_, x, y, z) => \interface("interfaceName", x, y, z)
		case \class(_, x, y, z) => \class("className", x, y, z)
		case \enumConstant(_, y) => \enumConstant("enumName", y) 
		case \enumConstant(_, y, z) => \enumConstant("enumName", y, z)
		case \methodCall(x, _, z) => \methodCall(x, "methodCall", z)
		case \methodCall(x, y, _, z) => \methodCall(x, y, "methodCall", z) 
		case Type _ => lang::java::jdt::m3::AST::short()
		case Modifier _ => lang::java::jdt::m3::AST::\private()
		case \simpleName(_) => \simpleName("simpleName")
		case \number(_) => \number("15")
		case \variable(x,y) => \variable("variableName",y) 
		case \variable(x,y,z) => \variable("variableName",y,z) 
		case \booleanLiteral(_) => \booleanLiteral(true)
		case \stringLiteral(_) => \stringLiteral("StringLiteralName")
		case \characterLiteral(_) => \characterLiteral("q")
	}
}
