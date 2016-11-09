module computeUnitSize

import IO;
import List;
import String;

import lang::java::jdt::m3::Core;

public void computeUnitSize (list[loc] locations) {
	for (sourceFile <- locations) {
		model = createM3FromEclipseProject(sourceFile);
		println(model);
	}
}