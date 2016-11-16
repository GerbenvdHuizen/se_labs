module SIGMModel


import util::FileSystem;
import IO;
import List;
import lang::java::jdt::m3::Core;
import util::Math;
import helperFunctions;
import readVolume;
import readUnitSize;
import readComplexityPerUnit;
import readDuplication;

public void getAverageRating(loc project) {
	
	lrel[str,int,int] allFiles = findFileLineIndices(visibleFiles(project));
	M3 model = createM3FromEclipseProject(project);
	
	int volume = computeVolume(size(allFiles));
	int cpu = computeCPU(model);
	int unitSize = computeUnitSize(model);
	int duplication = computeDuplication(allFiles,size(allFiles));
	
	int totalRating = volume + unitSize + cpu + duplication; 
						
	int averageRating = totalRating/4;
	
	createTable([averageRating, volume, unitSize, cpu, duplication]); 
}

str getSTR(int n) {
	str result;
	if(n == 5)
		result = "++";
	else if(n == 4)
		result = "+";
	else if(n == 3)
		result = "o";
	else if(n == 2)
		result = "-";
	else
		result = "--";
	
	return result;
}

void createTable(list[int] metrics) {
int analAbi = round((metrics[1] + metrics[2] + metrics[4])/3.0);
int changeAbi = round((metrics[3] + metrics[4])/2.0);
int testAbi = round((metrics[2] + metrics[3])/2.0);
int maintAbi = round((analAbi + changeAbi + testAbi)/3.0);

println("Volume : <getSTR(metrics[1])>");
println("Complexity per unit : <getSTR(metrics[3])>");
println("Duplication : <getSTR(metrics[4])>");
println("Unit size : <getSTR(metrics[2])>");
println("");
println("                -------------------------------------------------------------");
println("                | Volume | Complexity PU | Duplication | Unit Size | Result ");	
println("-----------------------------------------------------------------------------");	
println("| Analysability |   x    |               |      x      |     x     |   <getSTR(analAbi)>");
println("-----------------------------------------------------------------------------");
println("| Changeability |        |       x       |      x      |           |   <getSTR(changeAbi)>");
println("-----------------------------------------------------------------------------");
println("| Stability     |        |               |             |           |   ");
println("-----------------------------------------------------------------------------");
println("| Testability   |        |       x       |             |     x     |   <getSTR(testAbi)>");
println("-----------------------------------------------------------------------------");
println("");
println("Maintainability : <getSTR(maintAbi)>");

}
