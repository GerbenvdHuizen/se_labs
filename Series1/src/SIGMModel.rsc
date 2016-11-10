module SIGMModel


import util::FileSystem;
import IO;
import readVolume;
import readUnitSize;
import readComplexityPerUnit;
import readDuplication;

public list[int] getAverageRating(loc project) {

	int volume = computeVolume(visibleFiles(project));
	int unitSize = computeUnitSize(project);
	int cpu = computeCPU(project);
	int duplication = computeDuplication(visibleFiles(project));
	int totalRating = volume + unitSize + cpu + duplication; 
						
	int averageRating = totalRating/4;
	
	return [averageRating, volume, unitSize, cpu, duplication]; 
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
int analAbi = (metrics[1] + metrics[2] + metrics[4])/3;
int changeAbi = (metrics[3] + metrics[4])/2;
int testAbi = (metrics[2] + metrics[3])/2;

println("Volume = 1");
println("Complexity per unit = 2");
println("Duplication = 3");
println("Unit size = 4");
println("Unit testing = 5");
println("");
println("                ------------------------------");
println("                | 1 | 2 | 3 | 4 | 5 | Result |");	
println("----------------------------------------------");	
println("| Analysability | x |   | x | x | x |   <getSTR(analAbi)>    | ");
println("----------------------------------------------");
println("| Changeability |   | x | x |   |   |   <getSTR(changeAbi)>    | ");
println("----------------------------------------------");
println("| Stability     |   |   |   |   | x |   o    | ");
println("----------------------------------------------");
println("| Testability   |   | x |   | x | x |   <getSTR(testAbi)>    | ");
println("----------------------------------------------");
println("");
println("Maintainability : <getSTR(metrics[0])>");

}
