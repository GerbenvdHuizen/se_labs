module testFrame

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;
import lang::java::m3::Core;

import Node;
import List;
import IO;
import util::Math;

import detectCloneType2;

test bool subTreeMassQuickCheck() {
	
	if (getSubtreeMass(makeNode("1", makeNode("2", makeNode("3", 
		makeNode("4", makeNode("5")))))) == 5)
		return true;

	return false;
}

test bool similarityQuickCheck() {
	
	if (computeSimilarity(makeNode("WoW I am different!"), makeNode("Me 2!")) == 0 &&
		computeSimilarity(makeNode("I am Groot!"), makeNode("I am Groot!")) == 1)
		return true;
		
	return false;
}

test bool hashToBucketQuickCheck() {
	node testNode;
	fileAST = createAstFromFile(|project://Series2/src/TestClass.java|, false);
	int counter = 0;

	visit (fileAST) {
		case node subTree: {
			counter += 1;
			if (Declaration d := subTree || Statement d := subTree || Expression d := subTree
				&& ("src" in getAnnotations(subTree)))
				testNode = subTree;
		}
	}
	
	hashToBucket(testNode);
	
	loc testNodeLocation;
	switch(testNode) {
		case Declaration d: testNodeLocation = d@src;
	}
	
	for (bucket <- buckets) {
		if (bucket != testNode || buckets[bucket][0][1] != testNodeLocation)
			return false;
	}
	
	return true;

}

test bool removeSymmetricPairsQuickCheck() {
	
	node testNode1 = makeNode("testNode1");
	node testNode2 = makeNode("testNode2");
	
	loc testLocation = |project://Series2/src/TestJava.java|;
	
	
	testBucket = [<<testNode1, testLocation>, 
				<testNode2 , testLocation>>,
				<<testNode2, testLocation>,
				<testNode1, testLocation>>];
	
	if (size(removeSymmetry(testBucket)) == 1) {
		return true;
	}
	return false;
}

test bool normalizeQuickCheck() {
	
	fileAST = createAstFromFile(|project://Series2/src/TestClass.java|, false);
	massThreshold = 10;
	
	normalized = true;
	
	visit (fileAST) {
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
	
	return normalized;

}