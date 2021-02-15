/* Try using global and static variables */

int blah = 0;
int foo  = 100;

void bleeb(int bar)
{
  *((int*)0x70000000) = bar + blah + foo;
}

int main()
{
  static int bar = 200;
  blah += 50;
  foo  += 25;
  bleeb(bar);
  return 0;
}
