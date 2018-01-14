class Point{
	// Point class
	j;
	i=10;
	s="tt";
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
