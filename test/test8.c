int main()
{
  int a = 100, b = 50, c = 20;
  int *p = (int*)0x70000000;
  *p = a + b + c;
  return 0;
}
