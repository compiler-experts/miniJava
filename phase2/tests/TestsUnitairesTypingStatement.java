class I {
	boolean a = (56 == 5);
	float b = 8.5f;
	boolean a2 = false;
	String c = "yes";
	int i = 5;
	int j = i;
    // Return None for constructor -> ok
	public I(boolean a, float b) {
		this.a = a;
		this.b = b;
		return;
	}
	// Return something for constructor -> not ok
	// public I(boolean a, float b) {
	// 	this.a = a;
	// 	this.b = b;
	// 	return i;
	// }
    // Return ref_type for methode -> ok
    private I func1 (int a, int b) {
		// int b = 1; // test Duplicate Local Variable -> not ok
		// { // Test Block in verify_statement
		// 	int n = 5;
		// 	String m = b;
		// }
		I ret = new I(false, 5.5f);
		i++; // test Expr in in verify_statement
		return ret;
	}
    // Return None for methode -> not ok
	// private I func2 (int a, int b) {
	// 	return;
	// }
	private void testIf(int i){
		int j = 0;
		// test if
		if (i == 1) {
			int x =0;
			j = 5;
		}
		// test if else
		if (i == 1) {
			int x = 0;
			j = 4;
		} else {
			int x = 1;
			j = 5;
		}
		// if conditon must be boolean
		// if (i) {
		// 	j = 4;
		// }
	}
}
