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


test bool getSubtreeMassCheck() {
	node testSubtree = makeNode("1", makeNode("2", makeNode("3", makeNode("4", makeNode("5")))));
	if (getSubtreeMass(testSubtree) == 5)
		return true;
	return false;
}

// ---------------------------------

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
					case \method(x, y, _, _, _) : if(x != lang::java::jdt::m3::AST::short() || y != "methodName") normalized = false;
					case \method(x, y, _, _) : if(x != lang::java::jdt::m3::AST::short() || y != "methodName") normalized = false;
					case \parameter(_, x, _) : if( x != "paramName") normalized = false;
					case \vararg(_, x) : if( x != "varArgName") normalized = false; 
					case \annotationTypeMember(_, x) : if( x != "annonName") normalized = false;
					case \annotationTypeMember(_, x, _) : if( x != "annonName") normalized = false;
					case \typeParameter(x, _) : if( x != "typeParaName") normalized = false;
					case \constructor(x, _, _, _) : if( x != "constructorName") normalized = false;
					case \interface(x, _, _, _) : if( x != "interfaceName") normalized = false;
					case \class(x, _, _, _) : if( x != "className") normalized = false;
					case \enumConstant(x, _) : if( x != "enumName") normalized = false;
					case \enumConstant(x, _, _) : if( x != "enumName") normalized = false;
					case \methodCall(_, x, _) : if( x != "methodCall") normalized = false;
					case \methodCall(_, _, x, _) : if( x != "methodCall") normalized = false;
					case Type x : if( x != lang::java::jdt::m3::AST::short()) normalized = false;
					case Modifier x : if( x != lang::java::jdt::m3::AST::\public()) normalized = false;
					case \simpleName(x) : if( x != "simpleName") normalized = false;
					case \number(x) : if( x != "15") normalized = false;
					case \variable(x,_) : if( x != "variableName") normalized = false; 
					case \variable(x,_,_) : if( x != "variableName") normalized = false;  
					case \booleanLiteral(x) : if( x != true) normalized = false; 
					case \stringLiteral(x) : if( x != "StringLiteralName") normalized = false; 
					case \characterLiteral(x) : if( x != "q") normalized = false; 
				}
			}
		}
	}
	return normalised;
}

// ---------------------------------

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

// ---------------------------------

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

// ---------------------------------

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