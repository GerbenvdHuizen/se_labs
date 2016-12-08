public class TestClass {
	
	private String name;
	private int age;
	
	public TestClass (String name, int age) {
		this.name = name;
		this.age = age;
	}
	
	public String getAgeClass () {
		if (this.age < 18) {
			return "minor";
		}
		else if (this.age >= 18 && this.age < 65) {
			return "adult";
		}
		else {
			return "senior";
		}
	}
	
	// This is a duplicate.
	public String getAgeClass2 () {
		if (this.age < 18) {
			return "minor";
		}
		else if (this.age >= 18 && this.age < 65) {
			return "adult";
		}
		else {
			return "senior";
		}
	}
	
	// Inefficient, but must be >= six lines ;-).
	public int getAgeInTenYears () {
		int currentAge = this.age;
		int newAge = currentAge;
		for(int i = 1; i < 11; i++) {
			newAge += 1;
		}
		System.out.println(currentAge);
		System.out.println(newAge);
		return newAge;
	}
	
	// This is a duplicate.
	public int getAgeInTenYears2 () {
		int currentAge = this.age;
		int newAge = currentAge;
		for(int i = 1; i < 11; i++) {
			newAge += 1;
		}
		System.out.println(currentAge);
		System.out.println(newAge);
		return newAge;
	}
	
	// This is a another duplicate, but with different names.
	public int getAgeInTenYears3 () {
		int currentAge3 = this.age;
		int newAge3 = currentAge3;
		for(int x = 1; x < 11; x++) {
			newAge3 += 1;
		}
		System.out.println(currentAge3);
		System.out.println(newAge3);
		return newAge3;
	}
	
	public String getName () {
		return this.name;
	}
	
	public void setName (String name) {
		this.name = name;
	}
	
	public int getAge () {
		return this.age;
	}
	
	public void setAge (int age) {
		this.age = age;
	}
}