class Point{
	// Point class
	static String j;
	static Int i=10;
	String s="tt";
	Int	test(){
		i=5;
	}
	static String test(Int i, String s){
		s="test";
		// comment
		this.test();
		/* multi line comment
		*/
	}
}

class Point1 extends Point
{
	static String test(){
	}
}
