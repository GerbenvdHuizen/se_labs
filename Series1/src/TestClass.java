/**
 * 
 */

/**
 * @author Vincent Erich
 *
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
}