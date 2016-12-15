/**
 * Software Evolution - University of Amsterdam
 * Practical Lab Series 2 - Clone Detection
 * testFrame.rsc
 *
 * Vincent Erich - 10384081
 * Gerben van der Huizen - 10460748
 * December 2016
 */
 
module unitTests

import IO;
import List;
import Node;

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::m3::Core;

import util::Math;

import detectCloneType2;

// Run all tests by typing :test in the rascal console.

/**
 * A test function which evaluates whether the getSubtreeMass function
 * works as intended. A small example tree with a mass of 5 is created
 * for the evaluation.
 *
 * @return 			Truth value of the test (Boolean).
 */
test bool getSubtreeMassCheck() {
	node testSubtree = makeNode("1", makeNode("2", makeNode("3", makeNode("4", makeNode("5")))));
	if (getSubtreeMass(testSubtree) == 5)
		return true;
	return false;
}

/**
 * A test function which evaluates whether the normaliseSubtree function
 * works as intended. Creates an abstract syntax tree from the TestClass.java
 * and normalises all of the nodes with the normaliseSubtree function. After
 * each node has been normalised it is checked for having normalised atributes
 * (where necessary). False is returned when an not-normalised node is found.
 *
 * @return 			Truth value of the test (Boolean).
 */
test bool normaliseSubtreeCheck() {
	int massThreshold = 10;
	bool normalised = true;
	AST = createAstFromFile(|project://Series2/src/TestClass.java|, false);
	
	visit (AST) {
		case node subtree: {
			int subtreeMass = getSubtreeMass(subtree);
			if (subtreeMass >= massThreshold) {
				node normalisedSubtree = normaliseSubtree(subtree);
				
				visit (normalisedSubtree) {
					case \method(x, y, _, _, _) : if(x != lang::java::jdt::m3::AST::short() || y !=  "methodIdentifier") normalized = false;
					case \method(x, y, _, _) : if(x != lang::java::jdt::m3::AST::short() || y !=  "methodIdentifier") normalized = false;
					case \parameter(_, x, _) : if( x != "paramIdentifier") normalized = false;
					case \vararg(_, x) : if( x != "varArgIdentifier") normalized = false; 
					case \annotationTypeMember(_, x) : if( x != "annotationTypeIdentifier") normalized = false;
					case \annotationTypeMember(_, x, _) : if( x != "annotationTypeIdentifier") normalized = false;
					case \typeParameter(x, _) : if( x != "typeParamIdentifier") normalized = false;
					case \constructor(x, _, _, _) : if( x != "constructorIdentifier") normalized = false;
					case \interface(x, _, _, _) : if( x != "interfaceIdentifier") normalized = false;
					case \class(x, _, _, _) : if( x != "classIdentifier") normalized = false;
					case \enumConstant(x, _) : if( x != "enumConstantIdentifier") normalized = false;
					case \enumConstant(x, _, _) : if( x != "enumConstantIdentifier") normalized = false;
					case \methodCall(_, x, _) : if( x != "methodCallIdentifier") normalized = false;
					case \methodCall(_, _, x, _) : if( x != "methodCallIdentifier") normalized = false;
					case Type x : if( x != lang::java::jdt::m3::AST::short()) normalized = false;
					case Modifier x : if( x != lang::java::jdt::m3::AST::\public()) normalized = false;
					case \simpleName(x) : if( x != "simpleNameIdentifier") normalized = false;
					case \number(x) : if( x != "15") normalized = false;
					case \variable(x,_) : if( x != "variableIdentifier") normalized = false; 
					case \variable(x,_,_) : if( x != "variableIdentifier") normalized = false;  
					case \booleanLiteral(x) : if( x != true) normalized = false; 
					case \stringLiteral(x) : if( x != "StringLiteralIdentifier") normalized = false; 
					case \characterLiteral(x) : if( x != "a") normalized = false; 
				}
			}
		}
	}
	return normalised;
}

/**
 * A test function which evaluates whether the hashToBucket function works
 * as intended. A bucket is created for the purpose of this test. Since we know what
 * content and format the created bucket should have, the result from using the hashToBucket
 * function can simply be compared to this expected result. 
 *
 * @return 			Truth value of the test (Boolean).
 */
test bool hashToBucketCheck() {
	resetVariables();
	AST = createAstFromFile(|project://Series2/src/TestClass.java|, false);
	node testNode;
	loc testNodeLocation;

	visit (AST) {
		case node subtree: {
			if (Declaration d := subtree 
				|| Statement d := subtree 
				|| Expression d := subtree
				&& ("src" in getAnnotations(subtree)))
					testNode = subtree;
					//break;
		}
	}
	
	hashToBucket(testNode);
	switch(testNode) {
		case Declaration d: testNodeLocation = d@src;
	}
	
	for (bucket <- buckets) {
		if (bucket != testNode || buckets[bucket][0][1] != testNodeLocation)
			return false;
	}
	return true;
}

/**
 * A test function which evaluates whether the removeSymmetricPairsCheck function
 * works as intended. The function is evaluated by checking whether it removes
 * the reflexive pair from a list containing two pairs. 
 *
 * @return 			Truth value of the test (Boolean).
 */
test bool removeSymmetricPairsCheck() {
	node testNode1 = makeNode("testNode1");
	node testNode2 = makeNode("testNode2");
	loc testLocation = |drive://test|;
	testBucket = [<<testNode1, testLocation>,
				<testNode2 , testLocation>>,
				<<testNode2, testLocation>,
				<testNode1, testLocation>>];
	if (size(removeSymmetricPairs(testBucket)) == 1)
		return true;
	return false;
}

/**
 * A test function which evaluates whether the computeSimilarity function
 * works as intended. The similarity between two simple trees is computed
 * and the result is checked for correctness.
 *
 * @return 			Truth value of the test (Boolean).
 */
test bool computeSimilarityCheck() {
	node testSubtree1_1 = makeNode("WoW I am different!");
	node testSubtree1_2 = makeNode("Me 2!");
	node testSubtree2_1 = makeNode("I am Groot!");
	node testSubtree2_2 = testSubtree2_1;
	if (computeSimilarity(testSubtree1_1, testSubtree1_2) == 0 
		&& computeSimilarity(testSubtree2_1, testSubtree2_2) == 1)
		return true;
	return false;
}

// ---------------------------------