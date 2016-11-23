Practical Lab Series 1 - Software Metrics
==========

Series 1 focuses on software metrics. Using Rascal, we have designed and build a tool that calculates the SIG Maintainability Model scores for a Java project. The tool calculates the following metrics (source code properties):
* Volume
* Unit Size
* Unit Complexity
* Duplication

Based on the value of a metric, a rank is calculated for the metric. Furthermore, based on the metric ranks, a rank is calculated for the following maintainability characteristics:
* Analysability
* Changeability
* Testability

Finally, based on the ranks of the maintainability characteristics, a rank is calculated for the overall maintainability of a Java project.

Information about the SIG Maintainability Model can be found in [this research paper](http://ieeexplore.ieee.org/document/4335232/?arnumber=4335232&tag=1 "A Practical Model for Measuring Maintainability"). Furthermore, information about how the metric values and ranks are calculated can be found in the PDF file in this repository (see `Series1/Report_Series1.pdf`).

How to calculate the SIG Maintainability Model scores for a Java project?
---------- 

Import the Rascal module `SIGMModel` in the Rascal console (this module can be found in `Series1/src/`). You can then call the method `main` with the location of the source directory of the Java project - for example: `main(|project://myJavaProject/src/|);`. Furthermore, you can also import the Rascal module `SIGMModelTest` in the Rascal console and call the method `mainTest` without any arguments (this module can also be found in `Series1/src/`). This will run the tool on the file `TestClass.java`.