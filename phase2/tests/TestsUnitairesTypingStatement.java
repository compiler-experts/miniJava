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
    // Return ref_type for methode -> ok
    private I func1 (int a, int b) {
		// int b = 1; // test Duplicate Local Variable -> not ok
		// { // Test Block in verify_statement
		// 	int n = 5;
		// 	String m = b;
		// }
		I ret = new I(a2, b);
		i++; // test Expr in in verify_statement
		return I;
	}
    // Return None for methode -> not ok
	// private I func2 (int a, int b) {
	// 	return;
	// }
}
