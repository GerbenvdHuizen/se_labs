module detectCloneType2Asserts

import IO;
import Prelude;

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

import util::Math;

import computeVolume;
//import writeToCSV;


// The source code to analyze.
public loc projectSource = |project://Series2/src/TestClass.java|;
// The buckets for the subtrees.
public map[node, lrel[node, loc]] buckets = ();
// The (final) clone classes.
public map[node, lrel[tuple[node, loc], tuple[node, loc]]] cloneClasses = ();
// The clone statistics.
public tuple[int, int, int, list[loc]] cloningStatistics = <0, 0, 0, []>;
// The source of the csv file with clone data on the 'file level'.
public loc sourceCloneDataFiles = |project://Series2/src/csv/cloneDataFiles.csv|;
// The source of the csv file with clone data on the 'folder level'.
public loc sourceCloneDataFolders = |project://Series2/src/csv/cloneDataFolders.csv|;

// The minimum subtree mass (number of nodes) value to be considered.
private int massThreshold = 10;
// The threshold for the similarity between two subtrees.
private num similarityThreshold = 1.0;
// Clone classes that are subsumed in other clone classes.
private list[node] subsumedCloneClasses = [];

// ---------------------------------

public void detectTest () {
	resetVariables();
	println("Starting clone detection...");
	cloneDetectionType2();
	println("DONE");
	//println("Starting creation datasets and writing to csv files...");
	//writeToCSV();
	//println("DONE");
}

// ---------------------------------

public void resetVariables () {
	buckets = ();
	cloneClasses = ();
	subsumedCloneClasses = [];
	cloningStatistics = <0, 0, 0, []>;
}

// ---------------------------------

private void cloneDetectionType2 () {
	println("Creating ASTs of the project...");
	ASTs = createAstsFromEclipseProject(projectSource, false);
	println("DONE");
	
	// Steps 1 + 2 of the Basic Subtree Clone Detection Algorithm.
	println("Hashing subtrees with a minimum subtree mass of <massThreshold> to buckets...");
	visit (ASTs) {
		case node subtree: {
			int subtreeMass = getSubtreeMass(subtree);
			if (subtreeMass >= massThreshold) {
				node normalisedSubtree = normaliseSubtree(subtree);
				hashToBucket(normalisedSubtree);
			}
		}
	}
	println("DONE");
	
	// Step 3 of the Basic Subtree Clone Detection Algorithm.
	println("Creating clone pairs (and clone classes)...");
	for (bucketKey <- buckets) {
		if (size(buckets[bucketKey]) > 1) {
			lrel[tuple[node, loc] clone1, tuple[node, loc] clone2] bucketClonePairs = [];
			// Create the Cartesian product of two list relation values.
			bucketClonePairs += buckets[bucketKey] * buckets[bucketKey];
			// Remove the reflexive clone pairs from the bucket.
			bucketClonePairs = [clonePair | clonePair <- bucketClonePairs, clonePair.clone1 != clonePair.clone2];
			// Remove the symmetric clone pairs from the bucket.
			bucketClonePairs = removeSymmetricPairs(bucketClonePairs);
				
			for (clonePair <- bucketClonePairs) {
				num similarity = computeSimilarity(clonePair[0][0], clonePair[1][0]);
				if (similarity == similarityThreshold) {
					cloneClasses[clonePair[0][0]] = clonePair[0][0] in cloneClasses ? cloneClasses[clonePair[0][0]] + clonePair : [clonePair];
				}
			}
		}
	}
	println("DONE");
	
	println("Removing subsumed clones...");
	for (cloneClass <- cloneClasses) {
		for (clonePair <- cloneClasses[cloneClass]) {
			checkSubsumedClones(clonePair[0]);
			checkSubsumedClones(clonePair[1]);
		}
	}
	for (subsumedCloneClass <- subsumedCloneClasses) {
		cloneClasses = delete(cloneClasses, subsumedCloneClass);
	}
	println("DONE");
	
	println("Computing cloning statistics...");
	computeCloningStatistics();
	println("DONE");
	
	list[int] cloneClassSizes = [size(cloneClasses[k]) | k:_ <- cloneClasses];
	int percentageDuplLines = cloningStatistics[0];
	int nUniqueClones = cloningStatistics[1];
	int nCloneClasses = size(cloneClasses);
	int nLinesBiggestClone = cloningStatistics[2];
	int nClonePairsBiggestCloneClass = max(cloneClassSizes);
	
	assert percentageDuplLines == 72 : "Percentage of duplicated lines incorrect! Calculated: <percentageDuplLines>%, but should be 72%...";
	assert nUniqueClones == 5 : "Number of unique clones incorrect! Calculated: <nUniqueClones>, but should be 5...";
	assert nCloneClasses == 2 : "Number of clone classes incorrect! Calculated: <nCloneClasses>, but should be 2...";
	assert nLinesBiggestClone == 11 : "Number of lines of the biggest clone class incorrect!. Calculated: <duplication[0]>, but should be 11...";
	assert nClonePairsBiggestCloneClass == 3 : "Number of clone pairs in the biggest clone class incorrect!. Calculated: <nClonePairsBiggestCloneClass>, but should be 3...";
	
	println("The percentage of duplicated lines in the project is <percentageDuplLines>%.");
	println("The project contains <nUniqueClones> unique clones.");
	println("<nCloneClasses> clone classes were extracted from the project.");
	println("The biggest clone has <nLinesBiggestClone> lines.");
	println("The biggest clone class has <nClonePairsBiggestCloneClass> clone pairs.");
}

// ---------------------------------

public int getSubtreeMass (node subtree) {
	int subtreeMass = 0;
	visit (subtree) {
		case node x: subtreeMass += 1;
	}
	return subtreeMass;
}

// ---------------------------------

public node normaliseSubtree (node subtree) {
	return visit (subtree) {
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
		case \variable(x,y) => \variable("variableName", y) 
		case \variable(x,y,z) => \variable("variableName", y, z) 
		case \booleanLiteral(_) => \booleanLiteral(true)
		case \stringLiteral(_) => \stringLiteral("StringLiteralName")
		case \characterLiteral(_) => \characterLiteral("q")
	}
}

// ---------------------------------

public void hashToBucket (node subtree) {
	loc subtreeLocation = extractSubtreeLocation(subtree);
	if (subtreeLocation != projectSource && (subtreeLocation.end.line - subtreeLocation.begin.line) > 5) {	
		if ((Declaration d := subtree 
			|| Statement d := subtree 
			|| Expression d := subtree)) { 
		//	&& ("src" in getAnnotations(subtree))) { 
			buckets[d] = (d in buckets ? buckets[d] + <subtree, subtreeLocation> : [<subtree, subtreeLocation>]);
		}
	}
}

// ---------------------------------

// If a subtree is not a Declaration, Expression, or Statement, then it is 
// a subtree with content we are not interested in. 

private loc extractSubtreeLocation (node subtree) {
	switch(subtree) {
		case Declaration d: if(d@src?) return d@src;
		case Expression e: if(e@src?) return e@src;
		case Statement s: if(s@src?) return s@src;
		//default: return projectSource;
	}
	return projectSource;
}

// ---------------------------------

public lrel[tuple[node, loc], tuple[node, loc]] removeSymmetricPairs (lrel[tuple[node, loc], tuple[node, loc]] bucketClonePairs) {
	newBucketClonePairs = [];
	for (clonePair <- bucketClonePairs) {
		invertedClonePair = <<clonePair[1][0], clonePair[1][1]>, <clonePair[0][0], clonePair[0][1]>>;
		if (invertedClonePair notin newBucketClonePairs) {		
			newBucketClonePairs += clonePair;
		}
	}
	return newBucketClonePairs;
}

// ---------------------------------

public num computeSimilarity (node subtree1, node subtree2) {
	// Similarity = 2 x S / (2 x S + L + R)
	list[node] nodesSubtree1 = [];
	list[node] nodesSubtree2 = [];
	
	visit (subtree1) {
		case node x: {
			nodesSubtree1 += x;
		}
	}
	
	visit (subtree2) {
		case node x: {
			nodesSubtree2 += x;
		}
	}
	
	num s = size(nodesSubtree1 & nodesSubtree2);
	num l = size(nodesSubtree1 - nodesSubtree2);
	num r = size(nodesSubtree2 - nodesSubtree1); 
	num similarity = (2 * s) / (2 * s + l + r); 
	return similarity;
}

// ---------------------------------

private void checkSubsumedClones (tuple[node, loc] clone) {
	cloneTree = clone[0];
	visit (cloneTree) {
		case node x: {
			if (x != cloneTree) {
				if (getSubtreeMass(x) >= massThreshold) {
					tuple[node, loc] currentClone = <x, extractSubtreeLocation(x)>;
					if (isSubsumedCloneClass(currentClone)) {
						subsumedCloneClasses += x;
					}
				}
			}
		}
	}
}

// ---------------------------------

private bool isSubsumedCloneClass (tuple[node, loc] clone) {
	for (cloneClass <- cloneClasses) {
		for (clonePair <- cloneClasses[cloneClass]) {
			if ((clone[0] == clonePair[0][0]) // && clone[1] <= clonePair[0][1]) 
				|| (clone[0] == clonePair[1][0])) { // && clone[1] <= clonePair[1][1])) {
					if (cloneClasses[clone[0]]?) {
						if (size(cloneClasses[clone[0]]) == size(cloneClasses[cloneClass])) {
							return true;
						}
					}
			} 
		}
	}
	return false;
}

// ---------------------------------

private void computeCloningStatistics () {
	lrel[tuple[node, loc], tuple[node, loc]] allClonePairs = [v | <k, v> <- toRel(cloneClasses)];
	list[int] nLOCUniqueClones = [];
	list[loc] uniqueCloneLocations = [];
	
	for (clonePair <- allClonePairs) {
		for (int i <- [0 .. 2]) {
			if (clonePair[i][1] notin uniqueCloneLocations) {
				uniqueCloneLocations += clonePair[i][1];
				nLOCUniqueClones += countCodeLines(readFileLines(clonePair[i][1]));
			}
		}
	}
	
	nLOCProject = getVolume(projectSource);
	cloningStatistics[0] = percent(sum(nLOCUniqueClones), nLOCProject);
	cloningStatistics[1] = size(nLOCUniqueClones);
	cloningStatistics[2] = max(nLOCUniqueClones);
	cloningStatistics[3] = uniqueCloneLocations;
}

// ---------------------------------