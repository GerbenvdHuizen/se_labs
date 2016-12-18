Practical Lab Series 2 - Clone Detection
==========

Series 2 focuses on clone detection. Using RASCAL, we have implemented a clone detection tool that can detect Type 2 clones in a Java project. Furthermore, we have implemented a clone management tool that visualises the results of the clone detection tool (i.e., an interactive web visualisation written using the Javascript D3 library). This README briefly describes how to run the tools. More information about the assignment and implementation details can de found in the PDF file in this repository (see `Series2/Report_Series2.pdf`).

The clone detection tool
---------------------

Import the RASCAL module `detectCloneType2` in the RASCAL console (this module can be found in `Series2/src/`). The clone detection tool will detect Type 2 clones in the source of the Java project defined by the variable `projectSource` (see line 26 in `detectCloneType2.rsc`). The value of this variable is `|project://small_project/src/|` by default (this is a small example project that was provided with the assignment). You can change the value of the variable `projectSource` to let it point to the source of another Java project. You can then call the method `detectAndWrite` without any arguments, which will run the clone detection tool on the Java project. The results of the clone detection tool will be printed in the RASCAL console. Furthermore, the data for the clone management tool will be written to the csv files `cloneDataFiles.csv` and `cloneDataFolders.csv`, which can be found in `Series2/src/csv/`. 


The clone management tool
----------

The clone management tool is an interactive web visualisation written using the Javascript D3 library. In order to run the tool, perform the following steps:

* [Download](https://www.apachefriends.org/download.html "Download XAMPP") and install XAMPP.
* Copy the folder `Series2/src/visualisation/` and paste it in XAMPP's `htdocs` folder (the location of the `htdocs` folder depends on where you have installed XAMPP, but can typically be found in `C:/xampp/` [on Windows]). Furthermore, copy the csv files in the folder `Series2/src/csv/` and paste them in the folder `C:/xampp/htdocs/visualisation/` [1].
* Run XAMPP Control Panel and start the Apache module.
* Open your web browser and go to [localhost/visualisation/](localhost/visualisation/ "localhost/visualisation/") to interact with the visualisation.

[1] Note that the folder `Series2/src/csv/` contains two extra files besides the files `cloneDataFiles.csv` and `cloneDataFolders.csv`: `cloneDataFilesLarge.csv` and `cloneDataFoldersLarge.csv`. These two extra files contain the clone data of the large example project that was provided with the assignment. Since it takes a long time to create these files, we have already included them in the folder. The files `cloneDataFiles.csv` and `cloneDataFolders.csv` contain the clone data of the small example project that was provided with the assignment (unless the tool has been run on another project, in which case the two files contain the clone data of that project). 