/**
 * Software Evolution - University of Amsterdam
 * Practical Lab Series 2 - Clone Detection
 * detectCloneType2Asserts.rsc
 *
 * Vincent Erich - 10384081
 * Gerben van der Huizen - 10460748
 * December 2016
 */

/**
 * ---------- IMPORTANT ----------
 * This module is almost the same as the module 'detectCloneType2'. This 
 * module performs type 2 clone detection on the Java file 'TestClass.java', 
 * and contains a number of assert statements to check whether the output of 
 * the clone detection algorithm is as expected.   
 * ---------- END ----------
 */

module detectCloneType2Asserts

import IO;
import Prelude;

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

import util::Math;

import computeVolume;
import writeToCSV;


// The source code to analyze. 
public loc projectSource = |project://Series2/src/TestClass.java|;

// The buckets for the subtrees.
public map[node, lrel[node, loc]] buckets = ();

// The (final) clone classes.
public map[node, lrel[tuple[node, loc], tuple[node, loc]]] cloneClasses = ();

// The cloning statistics.
public tuple[int, int, int, list[loc]] cloningStatistics = <0, 0, 0, []>;

// The minimum subtree mass (number of nodes) value to be considered.
private int massThreshold = 10;

// The minimum size of a clone (in terms of LOC) to be considered.
private int cloneSizeThreshold = 6;

// The threshold for the similarity between two subtrees.
private num similarityThreshold = 1.0;

// Clone classes that are subsumed in other clone classes.
private list[node] subsumedCloneClasses = [];

/**
 * Performs type 2 clone detection on the Java project defined by 
 * 'projectSource'.
 */
public void detectTest () {
	resetVariables();
	println("Starting clone detection...");
	cloneDetectionType2();
	println("DONE");
}

/**
 * Resets a number of (public and private) variables.
 */
public void resetVariables () {
	buckets = ();
	cloneClasses = ();
	subsumedCloneClasses = [];
	cloningStatistics = <0, 0, 0, []>;
}

/**
 * Performs type 2 clone detection on the Java project defined by 
 * 'projectSource'. We use the Basic Subtree Clone Detection Algorithm from 
 * the paper 'Clone Detection Using Abstract Syntax Trees' (Baxter et al., 
 * 1998). See the report for more information on the algorithm.
 */
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
				/* IMPORTANT!!!
				 * Replace the body of this if-statement with the following 
				 * line for type 1 clone detection:
				 * hashToBucket(subtree);
				 */
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
	
	// Relevant assert statements.
	assert percentageDuplLines == 72 : "Percentage of duplicated lines incorrect! Calculated: <percentageDuplLines>%, but should be 72%...";
	assert nUniqueClones == 5 : "Number of unique clones incorrect! Calculated: <nUniqueClones>, but should be 5...";
	assert nCloneClasses == 2 : "Number of clone classes incorrect! Calculated: <nCloneClasses>, but should be 2...";
	assert nLinesBiggestClone == 11 : "Number of lines of the biggest clone class incorrect!. Calculated: <duplication[0]>, but should be 11...";
	assert nClonePairsBiggestCloneClass == 3 : "Number of clone pairs in the biggest clone class incorrect!. Calculated: <nClonePairsBiggestCloneClass>, but should be 3...";
	
	// Print the cloning statistics.
	println("The percentage of duplicated lines in the project is <percentageDuplLines>%.");
	println("The project contains <nUniqueClones> unique clones.");
	println("<nCloneClasses> clone classes were extracted from the project.");
	println("The biggest clone has <nLinesBiggestClone> lines.");
	println("The biggest clone class has <nClonePairsBiggestCloneClass> clone pairs.");
}

/**
 * Returns the subtree mass (number of nodes) of a subtree.
 *
 * @param subtree	The subtree to calculate the subtree mass of (node).
 * @return			The subtree mass (int).
 */
public int getSubtreeMass (node subtree) {
	int subtreeMass = 0;
	visit (subtree) {
		case node x: subtreeMass += 1;
	}
	return subtreeMass;
}

/**
 * Normalises a subtree (i.e., replaces identifiers [method names, variable 
 * names, etc.] with a normalised form). The code is based on the RASCAL 
 * Declaration expression, see: 
 * http://tutor.rascal-mpl.org/Rascal/Libraries/lang/java/m3/AST/Declaration/Declaration.html
 *
 * @param subtree	The subtree to normalise (node).
 * @return			The normalised subtree (node).
 */
public node normaliseSubtree (node subtree) {
	return visit (subtree) {
		case \method(x, _, y, z, q) => \method(lang::java::jdt::m3::AST::short(), "methodIdentifier", y, z, q)
		case \method(x, _, y, z) => \method(lang::java::jdt::m3::AST::short(), "methodIdentifier", y, z)
		case \parameter(x, _, z) => \parameter(x, "paramIdentifier", z)
		case \vararg(x, _) => \vararg(x, "varArgIdentifier") 
		case \annotationTypeMember(x, _) => \annotationTypeMember(x, "annotationTypeIdentifier")
		case \annotationTypeMember(x, _, y) => \annotationTypeMember(x, "annotationTypeIdentifier", y)
		case \typeParameter(_, x) => \typeParameter("typeParamIdentifier", x)
		case \constructor(_, x, y, z) => \constructor("constructorIdentifier", x, y, z)
		case \interface(_, x, y, z) => \interface("interfaceIdentifier", x, y, z)
		case \class(_, x, y, z) => \class("classIdentifier", x, y, z)
		case \enumConstant(_, y) => \enumConstant("enumConstantIdentifier", y) 
		case \enumConstant(_, y, z) => \enumConstant("enumConstantIdentifier", y, z)
		case \methodCall(x, _, z) => \methodCall(x, "methodCallIdentifier", z)
		case \methodCall(x, y, _, z) => \methodCall(x, y, "methodCallIdentieifer", z) 
		case Type _ => lang::java::jdt::m3::AST::short()
		case Modifier _ => lang::java::jdt::m3::AST::\private()
		case \simpleName(_) => \simpleName("simpleNameIdentifier")
		case \number(_) => \number("15")
		case \variable(x,y) => \variable("variableIdentifier", y) 
		case \variable(x,y,z) => \variable("variableIdentifier", y, z) 
		case \booleanLiteral(_) => \booleanLiteral(true)
		case \stringLiteral(_) => \stringLiteral("StringLiteralIdentifier")
		case \characterLiteral(_) => \characterLiteral("a")
	}
}

/**
 * Hashes a subtree to a bucket (i.e., step 2 of the Basic Subtree Clone 
 * Detection Algorithm).
 *
 * @param subtree	The subtree to hash.
 */
public void hashToBucket (node subtree) {
	loc subtreeLocation = extractSubtreeLocation(subtree);
	if (subtreeLocation != projectSource && (subtreeLocation.end.line - subtreeLocation.begin.line) >= cloneSizeThreshold) {	
		if ((Declaration d := subtree 
			|| Statement d := subtree 
			|| Expression d := subtree)) { 
			buckets[d] = (d in buckets ? buckets[d] + <subtree, subtreeLocation> : [<subtree, subtreeLocation>]);
		}
	}
}

/**
 * Returns the location of a subtree. Note that we are only interested in the 
 * location of a subtree of 'type' Declaration, Expression, or Statement. If 
 * the subtree is of another 'type', the location of the project source is 
 * returned (i.e., 'projectSource').
 *
 * @param subtree	The subtree to get the location of (node).
 * @return			The location of the subtree (loc).
 */
private loc extractSubtreeLocation (node subtree) {
	switch(subtree) {
		case Declaration d: if(d@src?) return d@src;
		case Expression e: if(e@src?) return e@src;
		case Statement s: if(s@src?) return s@src;
	}
	return projectSource;
}

/**
 * Given a list relation with relations between tuples (representing clone 
 * pairs), remove the symmetric relations and return the resulting list 
 * relation.
 *
 * @param bucketClonePairs	The list relation to remove the symmetric 
 *							relations from 
 *							(lrel[tuple[node, loc], tuple[node, loc]]).
 * @return					'bucketClonePairs' without the symmetric relations 
 *							(lrel[tuple[node, loc], tuple[node, loc]]).
 */
public lrel[tuple[node, loc], tuple[node, loc]] removeSymmetricPairs (lrel[tuple[node, loc], tuple[node, loc]] bucketClonePairs) {
	lrel[tuple[node, loc], tuple[node, loc]] newBucketClonePairs = [];
	for (clonePair <- bucketClonePairs) {
		invertedClonePair = <<clonePair[1][0], clonePair[1][1]>, <clonePair[0][0], clonePair[0][1]>>;
		if (invertedClonePair notin newBucketClonePairs) {		
			newBucketClonePairs += clonePair;
		}
	}
	return newBucketClonePairs;
}

/**
 * Computes the similarity between two subtrees according to the following
 * formula:
 * 		Similarity = 2 x S / (2 x S + L + R)
 * where
 * S = the number of shared nodes;
 * L = the number of different nodes in subtree 1;
 * R = the number of different nodes in subtree 2.
 * The formula is part of the Basic Subtree Clone Detection Algorithm.
 *
 * @param subtree1	The first subtree (node).
 * @param subtree2	The second subtree (node).
 * @return			The similarity between 'subtree1' and 'subtree2' according 
 *					to the similarity formula described above (num).
 */
public num computeSimilarity (node subtree1, node subtree2) {
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

/**
 * Given a clone from a clone pair, checks whether subtrees of that clone are 
 * clone classes (in which case these clone classes have to be removed 
 * [subsumption]). If a subtree of a clone is indeed a clone class, the 
 * subtree is added to the list with subsumed clone classes.
 *
 * @param clone		A clone from a clone pair (tuple[node, loc]).
 */
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

/**
 * Given a subtree of a clone from a clone pair, checks whether the subtree is 
 * a clone class.
 *
 * @param clone		The subtree of a clone from a clone pair to check 
 *					(tuple[node, loc]).
 * @return			A boolean indicating whether the subtree is indeed a clone 
 *					class (bool). 
 */
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

/**
 * Computes the relevant cloning statistics, including:
 * - The precentage of duplicated lines;
 * - The number of clones;
 * - The biggest clone (in LOC).
 */
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