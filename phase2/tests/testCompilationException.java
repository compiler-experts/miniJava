class B extends A{
  public void f1(){
  }
}

class A {

  int a = 5;
  String b ="abc";
  public void f1(){
  }

  //test same function exception
  public void f1(int b){
  }

  public void f1(int d){
  }

  public void f1(int d,int c){
  }

  //test constructor exception
  public A(int num)
  {
    int a = num;
  }

  public A(int num,int b)
  {
    int a = num;
  }

  public A(int num1)
  {
    int a = num;
  }



}


class C {

}
