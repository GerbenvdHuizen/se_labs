module writeToCSV

import lang::csv::IO;
import util::FileSystem;

import detectCloneType2;


public void writeToCSV () {
	lrel[str, str] fileRelationsClones = getFileRelationsClones();
	rel[str file1, str file2, int nClonePairs] cloneData = createCloneData(visibleFiles(projectSource), fileRelationsClones);
	writeCSV(cloneData, cloneDataSource);
}

private lrel[str, str] getFileRelationsClones () {
	lrel[str, str] fileRelations = [];
	for (cloneClass <- cloneClasses) {
		for (clonePair <- cloneClasses[cloneClass]) {
			fileRelations += <clonePair[0][1].file, clonePair[1][1].file>;
		}
	}
	return fileRelations;
}

private rel[str, str, int] createCloneData (set[loc] allFiles, lrel[str, str] fileRelationsClones) {
	rel[str, str, int] cloneData = {};
	for (file2 <- allFiles) {
		for (file1 <- allFiles) {
			clonePairCounter = 0;
			for (fileRelationClones <- fileRelationsClones) {
				if ((fileRelationClones[0] == file1.file && fileRelationClones[1] == file2.file)
					|| (fileRelationClones[0] == file2.file && fileRelationClones[1] == file1.file)) {
						clonePairCounter += 1;
					} 
			}
			cloneData += <file1.file, file2.file, clonePairCounter>;
		}
	}
	return cloneData;
}