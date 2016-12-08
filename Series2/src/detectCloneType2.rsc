module detectCloneType2

import IO;
import Prelude;

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

import util::Math;

import computeVolume;
import writeToCSV;


// The source code to analyze.
public loc projectSource = |project://Series2/src/TestClass.java|; //public loc projectSource = |project://small_project/src/|;
// The (final) clone classes.
public map[node, lrel[tuple[node, loc], tuple[node, loc]]] cloneClasses = ();
// The source of the csv file with clone data (to visualize).
public loc cloneDataSource = |project://Series2/src/csv/cloneData.csv|;

// The minimum subtree mass (number of nodes) value to be considered.
public int massThreshold = 10;
// The buckets for the subtrees.
public map[node, lrel[node, loc]] buckets = ();
// The threshold for the similarity between two subtrees.
public num similarityThreshold = 1.0;
// Clone classes that are subsumed in other clone classes.
public list[node] subsumedCloneClasses = [];
// The clone statistics.
public tuple[int, int, int, list[loc]] cloningStatistics = <0, 0, 0, []>;

// ---------------------------------

public void detectAndWrite () {
	cloneDetectionType2();
	writeToCSV();
}


public void cloneDetectionType2 () {
	println("Creating AST of the project...");
	AST = createAstsFromEclipseProject(projectSource, false);
	
	println("DONE");
	
	// Steps 1 + 2 of the Basic Subtree Clone Detection Algorithm.
	println("Hashing subtrees with a minimum subtree mass of <massThreshold> to buckets...");
	
	visit (AST) {
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
		if (size(buckets[bucketKey]) >= 2) {
			lrel[tuple[node, loc] clone1, tuple[node, loc] clone2] bucketClonePairs = [];
			// Create the reflexive transitive closure of the clones in the bucket.
			bucketClonePairs += buckets[bucketKey] * buckets[bucketKey];
			// Remove the reflexive clone pairs from the bucket.
			bucketClonePairs = [clonePair | clonePair <- bucketClonePairs, clonePair.clone1 != clonePair.clone2];
			// Remove the symmetric clone pairs from the bucket.
			bucketClonePairs = removeSymmetry(bucketClonePairs);
				
			for (clonePair <- bucketClonePairs) {
				num similarity = computeSimilarity(clonePair[0][0], clonePair[1][0]);
				if (similarity >= similarityThreshold) {
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
	list[int] cloneClassSizes = [size(cloneClasses[k]) | k:_ <- cloneClasses];
	println("DONE");
	println("The percentage of duplicated lines in the project is <cloningStatistics[0]>%.");
	println("The project contains <cloningStatistics[1]> unique clones.");
	println("<size(cloneClasses)> clone classes were extracted from the project.");
	println("The biggest clone has <cloningStatistics[2]> lines.");
	println("The biggest clone class has <max(cloneClassSizes)> clone pairs.");
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
		case Modifier _ => lang::java::jdt::m3::AST::\public()
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
	if (subtreeLocation != projectSource && (subtreeLocation.end.line - subtreeLocation.begin.line) >= 6) {	
		if ((Declaration d := subtree 
			|| Statement d := subtree 
			|| Expression d := subtree) 
			&& ("src" in getAnnotations(subtree))) { 
			buckets[d] = (d in buckets ? buckets[d] + <subtree, subtreeLocation> : [<subtree, subtreeLocation>]);
		}
	}
}

// ---------------------------------

public loc extractSubtreeLocation (node subtree) {
	switch(subtree) {
		case Declaration d: if(d@src?) return d@src;
		case Expression e: if(e@src?) return e@src;
		case Statement s: if(s@src?) return s@src;
		//default: return projectSource;
	}
	return projectSource;
}

// ---------------------------------

public lrel[tuple[node, loc], tuple[node, loc]] removeSymmetry (lrel[tuple[node, loc], tuple[node, loc]] bucketClonePairs) {
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

public void checkSubsumedClones (tuple[node, loc] clone) {
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

public bool isSubsumedCloneClass (tuple[node, loc] clone) {
	for (cloneClass <- cloneClasses) {
		for (clonePair <- cloneClasses[cloneClass]) {
			if ((clone[0] == clonePair[0][0] && clone[1] <= clonePair[0][1]) 
				|| (clone[0] == clonePair[1][0] && clone[1] <= clonePair[1][1])) {
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

public void computeCloningStatistics () {
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