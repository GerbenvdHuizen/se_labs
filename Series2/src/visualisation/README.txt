Software Evolution - University of Amsterdam
Practical Lab Series 2 - Clone Detection

Vincent Erich - 10384081
Gerben van der Huizen - 10460748
December 2016

CONTENTS OF THIS FILE
---------------------
   
 * Introduction
 * Installation

INTRODUCTION
------------

The visualisation for Series 2 was implemented using javascript D3 functionality.
This Readme will provide a small guide on how to install and run the necessary components
for the visualisation.

Some important links:

 * Xampp:
   https://www.apachefriends.org/index.html

 * Javascript D3:
   https://d3js.org/

 * Paper containing ideas for clone visualization:
   https://www.cs.usask.ca/~croy/Theses/Thesis_Asaduzzaman_January2012.pdf

 * Javascript module used for scrolling bars:
   http://bl.ocks.org/billdwhite/36d15bc6126e6f6365d0#virtualscroller.js

 * Extension for chrome (chrome doesn't allow for local files to be opened without this):
   https://chrome.google.com/webstore/detail/locallinks/jllpkdkcdjndhggodimiphkghogcpida/related

INSTALLATION
------------
 
Note: these instructions are for Windows users.

 * Download Xampp from the provide link and install its components in c:\xampp.

 * Take the the entire src/visualisation folder provided in the submission and copy it
   to the xampp/htdocs directory. All the data sets from src/csv also need to be added
   to xampp/htdocs.

 * Run Xampp control centre and start the apache server.

 * Now from your browser, call localhost/"name of the folder in htdocs" to run the visualisation
   in your browser of choice.

 * To open local files make sure your Eclipse project is in c:/Users/*UserName*/workspace/..
   Also since javascript cannot access your Windows username you will need to change
   "LGGX" to your own Windows username line 150 ("file:///C:/Users/LGGX/workspace/"). Don't
   change line 157, since that one accesses the data set!

