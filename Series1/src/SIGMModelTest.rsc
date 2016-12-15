/**
 * Software Evolution - University of Amsterdam
 * Practical Lab Series 1 - Software Metrics
 * SIGMModelTest.rsc
 *
 * Vincent Erich - 10384081
 * Gerben van der Huizen - 10460748
 * November 2016
 */
 
module SIGMModelTest

import IO;

import lang::java::jdt::m3::Core;
import util::Math;

import computeVolume;
import computeUnitSize;
import computeUnitComplexity;
import computeDuplication;


/**
 * Main method that calculates (and prints) the SIG Maintainability Model 
 * scores for the Java file TestClass.java.
 */
public void mainTest() {
	loc projectSource = |project://Series1/src/TestClass.java|;
	println("START EVALUATION");
	println("Creating M3 model...");
	M3 m3Model = createM3FromEclipseProject(projectSource);
	println("DONE");
	println("Extracting file locations...");
	set[loc] fileLocations = files(m3Model);
	println("DONE");
	println("Extracting unit locations (constructors and methods)...");
	set[loc] constructorLocations = constructors(m3Model);
	set[loc] methodLocations = methods(m3Model);
	set[loc] unitLocations = constructorLocations + methodLocations;
	println("DONE");
	
	println("Calculating volume...");
	tuple[int, str] volume = getVolume(projectSource);
	println("DONE");
	println("Calculating unit size...");
	tuple[map[str, num], str] unitSize = getUnitSize(unitLocations);
	println("DONE");
	println("Calculating complexity per unit...");
	tuple[map[str, num], str] unitComplexity = getUnitComplexity(m3Model, fileLocations);
	println("DONE");
	println("Calculating duplication...");
	tuple[num, str] duplication = getDuplication(projectSource);
	println("DONE");
	
	// Tests (asserts).
	assert volume[0] == 93 : "Volume metric value incorrect! Calculated <volume[0]>, but should be 93...";
	assert unitSize[0]["low"] == 64 &&  unitSize[0]["moderate"] == 36: "Unit size metric value incorrect! Calculated: low <unitSize[0]["low"]>% and moderate <unitSize[0]["moderate"]>%, but low should be 64% and moderate should be 36%...";
	assert unitComplexity[0]["low"] == 64 &&  unitComplexity[0]["moderate"] == 36: "Complexity per unit metric value(s) incorrect! Calculated: low <unitComplexity[0]["low"]>% and moderate <unitComplexity[0]["moderate"]>%, but low should be 64% and moderate should be 36%...";
	assert duplication[0] == 22 : "Duplication metric value incorrect!. Calculated <duplication[0]>%, but should be 22%...";
	
	str volumeRank = volume[1];
	str unitSizeRank = unitSize[1];
	str unitComplexityRank = unitComplexity[1];
	str duplicationRank = duplication[1];
	
	str analysabilityRank = intToRank(round((rankToInt(volumeRank) + rankToInt(duplicationRank) + rankToInt(unitSizeRank)) / 3.0));
	str changeabilityRank = intToRank(round((rankToInt(unitComplexityRank) + rankToInt(duplicationRank)) / 2.0));
	str testabilityRank = intToRank(round((rankToInt(unitComplexityRank) + rankToInt(unitSizeRank)) / 2.0));
	str maintainabilityRank = intToRank(round((rankToInt(analysabilityRank) + rankToInt(changeabilityRank) + rankToInt(testabilityRank)) / 3.0));
	
	println("\n----------RESULTS----------\n");
	println("Project: <projectSource>\n");
	println("Source code properties:");
	println("Metric: Volume. Metric value (LOC): <volume[0]>. Metric rank: <volumeRank>.");
	println("Metric: Unit size. Metric value (risk profile percentages): | Low : <unitSize[0]["low"]>, Moderate : <unitSize[0]["moderate"]>, High : <unitSize[0]["high"]>, Very high : <unitSize[0]["very high"]> | Metric rank: <unitSizeRank>.");
	println("Metric: Complexity per unit. Metric value (risk profile percentages): | Low : <unitComplexity[0]["low"]>, Moderate : <unitComplexity[0]["moderate"]>, High : <unitComplexity[0]["high"]>, Very high : <unitComplexity[0]["very high"]> | Metric rank: <unitComplexityRank>.");
	println("Metric: Duplication. Metric value (%): <duplication[0]>. Metric rank: <duplicationRank>.\n");
	println("Maintainablity characteristics:");
	println("Characteristic: analysability. Rank: <analysabilityRank>.");
	println("Characteristic: changeability. Rank: <changeabilityRank>.");
	println("Characteristic: testability. Rank: <testabilityRank>.");
	println("----------------------------------------");
	println("Final maintainability rank: <maintainabilityRank>.");
}

/**
 * Turns a rank into an integer.
 *
 * @param rank		The rank (str).
 * @return 			The integer (int).
 */
public int rankToInt (str rank) {
	switch(rank) {
		case "--": return 1;
		case "-": return 2;
		case "o": return 3;
		case "+": return 4;
		case "++": return 5;
	}
}

/**
 * Turns an integer into a rank.
 *
 * @param score		The integer (int).
 * @return 			The rank (str).
 */
public str intToRank (int score) {
	switch(score) {
		case 1: return "--";
		case 2: return "-";
		case 3: return "o";
		case 4: return "+";
		case 5: return "++";
	}
}