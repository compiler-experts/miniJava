class I {

	boolean a = (56 == 5);
	float b = 8.5;
	boolean a2 = false;
	String c = "yes";
	int i = 5;
	int j = i;
	public I(int e) {
		e += 1;
	}
	I my = new I(i);
	String mystring1 = I.func1(j);
	String mystring2 = func1(i);
	boolean f = !a;
	int g = ~5;
	float h = (-8.5f);
	boolean boo = I.a;
	int sr = 5;
	long l = (long) sr;
	boolean test = my instanceof I;
	private String func1 (int a) {
		int b = 1;
		b += (5+4);
		++b;
		b--;
		return "YES";
	}

}
