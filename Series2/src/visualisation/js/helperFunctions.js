
/*
	Software Evolution - University of Amsterdam
	Practical Lab Series 2 - Clone Detection
	helperFunctions.js

	Vincent Erich - 10384081
	Gerben van der Huizen - 10460748
	December 2016
	
*/
 
var helperFunctions = (function() {
	
	var _helpers = {};
	
	// Determine font size.
	_helpers.fontSize = function(d) {
		fontSize = 10;
		if (d >= 80)
			fontSize = 7;
		return fontSize;
	}

	// Return a color code based on the integer input.
	_helpers.chooseColor = function(d, list, bool) {
		
		color = "black";
		if (!bool) {
			if (d[0] == 0)
				color = "white";
			else if (d[0] == list[0])
				color = "#c7e9b4";
			else if (d[0] == list[1])
				color = "#7fcdbb";
			else if (d[0] == list[2])
				color = "#41b6c4";
			else if (d[0] >= list[3] && d[0] < list[4])
				color = "#1d91c0";
			else if (d[0] >= list[4])
				color = "#225ea8";
		} else {
			if (d[0] == 0)
				color = "white";
			else if (d[0] > 0 && d[0] < list[1])
				color = "#c7e9b4";
			else if (d[0] >= list[1] && d[0] < list[2])
				color = "#7fcdbb";
			else if (d[0] >= list[2] && d[0] < list[3])
				color = "#41b6c4";
			else if (d[0] >= list[3] && d[0] < list[4])
				color = "#1d91c0";
			else if (d[0] >= list[4])
				color = "#225ea8";
		}
		
		return color
	}
	
	// Get unique items from array.
	_helpers.uniq = function(a) {
		var seen = {};
		return a.filter(function(item) {
			return seen.hasOwnProperty(item) ? false : (seen[item] = true);
		});
	}

	// Fill a matrix with data.
	_helpers.fillMatrix = function(first, second, matrix) {
		var x = [0,"",""];
		for (var i = 0; i < matrix.length; i++) {
			if (matrix[i][0] == first && matrix[i][1] == second) {
				x = [matrix[i][2], first, second, matrix[i][3]];
			}
		}
		return x;
	}
	
	// sort a today array by the column/index of an element.
	function sortByColumn(a, colIndex){

		a.sort(sortFunction);

		function sortFunction(a, b) {
			if (a[colIndex] === b[colIndex]) {
				return 0;
			}
			else {
				return (a[colIndex] > b[colIndex]) ? -1 : 1;
			}
		}

		return a;
	}

	// Sort matrix by columns and rows.
	_helpers.sortMatrix = function(inputMatrix) {
		sortedMatrix = [];
		counter = 0
		for (var i = 0; i < inputMatrix.length; i++) {
			counter+=1;
			sortedMatrix.push([]);
			for (var j = 0; j < inputMatrix.length; j++) {
				sortedMatrix[i].push([]);
			}
		}

		sortedMatrix2 = [];
		for (var i = 0; i < inputMatrix.length; i++) {
			sortedMatrix2.push([]);
		}
		
		columnSums = [];
		for (var i = 0; i < inputMatrix.length; i++) {
			columnSum = 0;
			for (var j = 0; j < inputMatrix.length; j++) {
				columnSum += inputMatrix[j][i][0];
			}
			columnSums.push([columnSum,i]);
		}
		newColumn = sortByColumn(columnSums, 0);
		for (var i = 0; i < inputMatrix.length; i++) {
			for (var j = 0; j < inputMatrix.length; j++) {
				sortedMatrix[i][j] = inputMatrix[i][newColumn[j][1]];
			}
		}
		
		rowSums = [];
		
		for (var i = 0; i < inputMatrix.length; i++) {
			row = sortedMatrix[i];
			rowSum = 0;
			
			for (var j = 0; j < inputMatrix.length; j++) {
				rowSum += sortedMatrix[i][j][0];
			}
			rowSums.push([rowSum, i]);
			
		}
		newRow = sortByColumn(rowSums, 0);
		
		for (var i = 0; i < inputMatrix.length; i++) {
			sortedMatrix2[i] = sortedMatrix[newRow[i][1]];
		}

		return sortedMatrix2;
	}
	
	// Returns true if input number is even.
	function isEven(n) {
	   return n % 2 == 0;
	}
	
	// Returns true of input number is odd.
	function isOdd(n) {
	   return Math.abs(n % 2) == 1;
	}
	
	// Creates a string which can be made into a html link.
	function createLink(string, length) {
		var standardLink = "file:///C:/Users/LGGX/workspace/";
		var split = string.split("|");
		return standardLink + split[0];
	}
	
	// Sorts all the clone pairs in a readable format.
	function splitLocations(locations, length) {
		var res = locations.split("|file:///C:/Users/LGGX/workspace/");
		
		if (res[0] == "[]")
			return "<strong>No clone pairs</strong>";
			
		var totalString = "<strong>Clone pair locations:</strong> <br>"
		var countPairs = 1;
		var count = 1;
		var pairSubString = "";
		
		for (var i = 1; i < res.length; i++) {
			var subString = "";
			if (i == (res.length - 1)) {
				subString = res[i].substring(0, res[i].length - 2);
			} else if (isOdd(i)){
				subString = res[i].substring(0, res[i].length - 1);
			} else {
				subString = res[i].substring(0, res[i].length - 3);
			}
			if(count == 1) {
				count += 1;
				pairSubString += ("<em>Pair " + countPairs.toString() + ":</em> <br>");
				pairSubString += ("|" + subString + "<br>");
				pairSubString += "<a href="+ createLink(subString, length) +" target='_blank'>"+createLink(subString, length)+"</a> <br>";
			} else {
				count = 1;
				countPairs += 1;
				pairSubString += ("|" + subString + "<br>");
				pairSubString += "<a href="+ createLink(subString, length) +" target='_blank'>"+createLink(subString, length)+"</a> <br><br>";
				totalString += pairSubString;
				pairSubString = "";
			}	
		}
		return totalString;
	}
	
	// Create a string which contains details about the the clone pairs of a cell.
	_helpers.createString = function(data, length) {
		var totalString = "<font size='6'><strong>Clone pair overview</strong></font> <br><br>";
		totalString += "<strong>Number of clone pairs:</strong> <br>"+ data[0].toString() + "<br><br>";
		totalString += "<strong>File names:</strong> <br>"+ data[1] + "<br>" + data[2] + "<br><br>";
		totalString += splitLocations(data[3], length);
		return totalString;
	}
		
	return _helpers;
})();