module readDuplication

import IO;
import List;
import Set;
import String;
import util::Math;
import helperFunctions;

public int countDuplicates(lrel[str,int,int] allFilesIndices) {
	list[str] duplicateLines = [x | <x,y,z> <- allFilesIndices] - dup([x | <x,y,z> <- allFilesIndices]); 
	lrel[str,int,int] duplicateRelations = [<x,y,z> | <x,y,z> <- allFilesIndices, x in duplicateLines];
	
	int result = 0;
	set[int] filesWithDuplicates = {z | <x,y,z> <- duplicateRelations};
	//println(sort(filesWithDuplicates));

	for(fileIndx <- filesWithDuplicates) {
		list[int] indicesOfDupl = sort({y | <x,y,z> <- duplicateRelations, z == fileIndx});
		
		int lineCount = size(indicesOfDupl);
		if(size(indicesOfDupl) > 5) {
			int sizeDuplList  = size(indicesOfDupl) - 1;
			int counter = 0;
			
			while(sizeDuplList  >= counter + 1) {
				int countDupl = 0;
				int index = indicesOfDupl[counter];
				
				counter += 1;
				index += 1;	
				while(sizeDuplList >= counter && index == indicesOfDupl[counter]) {
					counter += 1;
					index += 1;	
					countDupl += 1;			
				}
						
				if(countDupl > 5) {
					result += countDupl;
				}					
			}
		}
	}
	return result;
}

public int computeDuplication(lrel[str,int,int] projectLines, int numbOfLines){
	int duplicates = countDuplicates(projectLines);
	
	println(duplicates);
	int percentage = percent(duplicates, numbOfLines);
	
	println(percentage);
	int result;
	if(percentage <= 3) {
		result = 5;
	} else if(percentage > 3 && percentage <= 5) {
		result = 4;
	} else if(percentage > 5 && percentage <= 10) {
		result = 3;
	} else if(percentage > 10 && percentage <= 20) {
		result = 2;
	} else if(percentage > 20) {
		result = 1;
	}
	
	return result;
}