import java.awt.Color;

/**
 * Software Evolution - University of Amsterdam
 * Practical Lab Series 1 - Software Metrics
 * TestClass.java
 */

/**
 * Vincent Erich - 10384081
 * Gerben van der Huizen - 10460748
 * November 2016
 */

public class TestClass {
	
	private String name;
	private int age;
	
	// This is a single-line comment.
	public TestClass(String name, int age) {
		this.name = name;
		this.age = age;
		/* This is a c-style comment. */
	}
	
	public void setName(String name) {
		this.name = name;
	}
	
	public String getName() {
		return this.name;
	}
	
	public void setAge(int age) {
		this.age = age;
	}
	
	public int getAge() {
		return this.age;
	}
	
	public void testMethod() {
		if (this.age >= 18) {
			System.out.println("Adult");
		}
		else {
			System.out.println("Minor");
		}
		for (int i = 0; i < this.age; i++) {
			System.out.println(i);
		}
	}
	
	// Duplicate method
	public void testMethodDuplicate() {
		if (this.age >= 18) {
			System.out.println("Adult");
		}
		else {
			System.out.println("Minor");
		}
		for (int i = 0; i < this.age; i++) {
			System.out.println(i);
		}
	}
	
	//helper method to determine if given coordinates are in bounds
	public void inBounds(Color[][] image, int row, int col) {	
		System.out.println((row >= 0) && (row <= image.length) && (col >= 0)
					&& (col < image[0].length));
	}

	// 14 lines
	public void complexTestColor( Color[][] mat ) {	
		boolean isRectangular = true;
		int row = 1;
		final int COLUMNS = mat[0].length;

		while( isRectangular && row < mat.length )
		{	isRectangular = ( mat[row].length == COLUMNS );
			row++;
		}
		
		try {

		} catch (IndexOutOfBoundsException e) {
		    System.err.println("IndexOutOfBoundsException: " + e.getMessage());
		}
		
		System.out.println(isRectangular);
	}
	
	// 32 lines
	public void complexTestString( String monthString )	{	
		int month = 8;

        switch (month) {
            case 1:  monthString = "January";
                     break;
            case 2:  monthString = "February";
                     break;
            case 3:  monthString = "March";
                     break;
            case 4:  monthString = "April";
                     break;
            case 5:  monthString = "May";
                     break;
            case 6:  monthString = "June";
                     break;
            case 7:  monthString = "July";
                     break;
            case 8:  monthString = "August";
                     break;
            case 9:  monthString = "September";
                     break;
            case 10: monthString = "October";
                     break;
            case 11: monthString = "November";
                     break;
            case 12: monthString = "December";
                     break;
            default: monthString = "Invalid month";
                     break;
        }
        
        System.out.println(monthString);      
	}
	
}