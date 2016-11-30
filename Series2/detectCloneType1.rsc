module detectCloneType1

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

import List;
import IO;
import Set;
import Prelude;
import Map;
import util::Math;

import computeVolume;

public loc selectedProject = |project://Series2/src/|;
public map[node, lrel[node, loc]] buckets = ();



public int massThreshold;
public real similarityThreshold;

public void clone1Detection() {
	
	massThreshold = 20;
	similarityThreshold = 1.0;
	
	model = createM3FromEclipseProject(selectedProject);
	
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
	
	if (nodeLocation == selectedProject || (nodeLocation.end.line - nodeLocation.begin.line) < 6) {
		return;
	} else {	
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
