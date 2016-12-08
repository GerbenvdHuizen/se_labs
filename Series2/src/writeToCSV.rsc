module writeToCSV

import IO;
import List;
import String;

import lang::csv::IO;
import util::FileSystem;

import detectCloneType2;


public void writeToCSV () {
	lrel[loc, loc] clonePairLocations = getClonePairLocations();
	lrel[str, str] clonePairFolders = getClonePairFolders();
	set[loc] uniqueCloneLocations = toSet(cloningStatistics[3]);
	println("Creating dataset of clone data on file level...");
	rel[str file1, str file2, int nClonePairs, lrel[loc, loc] locations] cloneDataFiles = createCloneDataFiles(uniqueCloneLocations, clonePairLocations); 
	println("DONE");
	println("Creating dataset of clone data on folder level...");
	rel[str folder1, str folder2, int nClonePairs] cloneDataFolders = createCloneDataFolders(uniqueCloneLocations, clonePairFolders);
	println("DONE");
	println("Writing dataset of clone data on file level to csv file...");
	writeCSV(cloneDataFiles, sourceCloneDataFiles);
	println("DONE");
	println("Writing dataset of clone data on folder level to csv file...");
	writeCSV(cloneDataFolders, sourceCloneDataFolders);
	println("DONE");
}

// ---------------------------------

private lrel[loc, loc] getClonePairLocations () {
	lrel[loc, loc] clonePairLocations = [];
	for (cloneClass <- cloneClasses) {
		for (clonePair <- cloneClasses[cloneClass]) {
			clonePairLocations += <clonePair[0][1], clonePair[1][1]>;
		}
	}
	return clonePairLocations;
}

// ---------------------------------

private rel[str, str, int, lrel[loc, loc]] createCloneDataFiles (set[loc] uniqueCloneLocations, lrel[loc, loc] clonePairLocations) {
	rel[str, str, int, list[tuple[loc, loc]]] cloneData = {};
	for (cloneLocation1 <- uniqueCloneLocations) {
		for (cloneLocation2 <- uniqueCloneLocations) {
			int clonePairCounter = 0;
			lrel[loc, loc] locations = [];
			for (clonePairLocation <- clonePairLocations) {
				if ((clonePairLocation[0].file == cloneLocation1.file && clonePairLocation[1].file == cloneLocation2.file)
					|| (clonePairLocation[0].file == cloneLocation2.file && clonePairLocation[1].file == cloneLocation1.file)) {
						clonePairCounter += 1;
						locations += <clonePairLocation[0], clonePairLocation[1]>;
					} 
			}
			cloneData += {<cloneLocation1.file, cloneLocation2.file, clonePairCounter, locations>};
		}
	}
	return cloneData;
}

// ---------------------------------

private lrel[str, str] getClonePairFolders () {
	lrel[str, str] clonePairFolders = [];
	for (cloneClass <- cloneClasses) {
		for (clonePair <- cloneClasses[cloneClass]) {
			list[str] splitClone1 = split("/", clonePair[0][1].path);
			str folderClone1 = splitClone1[size(splitClone1) - 2];
			list[str] splitClone2 = split("/", clonePair[1][1].path);
			str folderClone2 = splitClone2[size(splitClone2) - 2];
			clonePairFolders += <folderClone1, folderClone2>;		
		}
	}
	return clonePairFolders;
}

// ---------------------------------

private rel[str, str, int] createCloneDataFolders (set[loc] uniqueCloneLocations, lrel[str, str] clonePairFolders) {
	rel[str, str, int] cloneData = {};
	list[str] uniqueFolders = [];
	for (cloneLocation <- uniqueCloneLocations) {
		list[str] splitCloneLocation = split("/", cloneLocation.path);
		str folder = splitCloneLocation[size(splitCloneLocation) - 2];
		if (folder notin uniqueFolders) {
			uniqueFolders += folder;
		}
	}
	for (folder2 <- uniqueFolders) {
		for (folder1 <- uniqueFolders) {
			int clonePairCounter = 0;
			for (clonePairFolder <- clonePairFolders) {
				if ((clonePairFolder[0] == folder1 && clonePairFolder[1] == folder2)
					|| (clonePairFolder[0] == folder2 && clonePairFolder[1] == folder1)) {
					clonePairCounter += 1;
				}
			}
			cloneData += {<folder1, folder2, clonePairCounter>};
		}		
	}
	return cloneData;
}

// ---------------------------------