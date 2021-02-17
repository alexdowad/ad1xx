int a(int arg)
{
  return arg + 100;
}

int b(int (*func)(int), int arg)
{
  return func(arg);
}

int main()
{
  int (*f)(int (*c)(int), int);
  f = b;
  *((int*)0x70000000) = f(a, 123);
  return 0;
}
