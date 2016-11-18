/* 
* Software Evolution
* Series 1 code - Final version
* SIGMModel.rsc
*
* Vincent Erich - 10384081
* Gerben van der Huizen - 10460748
* November 2016
*/
module SIGMModel

import IO;
import util::Math;
import lang::java::jdt::m3::Core;
import computeVolume;
import computeUnitSize;
import computeUnitComplexity;
import computeDuplication;

/*
 * Main method for testing all the metrics.
 *
 * @param Location of a java project (loc).
 */
public void main(loc projectSource) {
	println("START EVALUATION");
	println("Creating M3 model...");
	M3 m3Model = createM3FromEclipseProject(projectSource);
	println("DONE");
	println("Extracting method locations...");
	set[loc] methodLocations = methods(m3Model);
	set[loc] fileLocations = files(m3Model);
	println("DONE");
	
	println("Calculating volume...");
	tuple[int, str] volume = getVolume(projectSource);
	println("DONE");
	println("Calculating unit size...");
	tuple[map[str, num], str] unitSize = getUnitSize(methodLocations);
	println("DONE");
	println("Calculating complexity per unit...");
	tuple[map[str, num], str] unitComplexity = getUnitComplexity(m3Model, fileLocations);
	println("DONE");
	println("Calculating duplication...");
	tuple[num, str] duplication = getDuplication(projectSource);
	println("DONE");
	
	//map[str, int] rankToIntMapping = ("++": 5, "+": 4, "o": 3, "-": 2, "--": 1);
	//map[int, str] intToRankMapping = (1: "-", 2: "-", 3: "o", 4: "+", 5: "++");
	println(unitSize[0]["low"]);
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
	println("Characteristic: maintainability. Rank: <maintainabilityRank>.");
}

/*
 * Turns a rank into a number.
 *
 * @param Rank (str).
 * @return Number (int).
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

/*
 * Turns a number into a rank.
 *
 * @param Number (int).
 * @return Rank (str).
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
