/* Since the RV32I instruction set does not include a multiply instruction,
 * GCC automatically converts a multiply op to a function call... which goes to
 * a function called `__mulsi3`
 * Since we're not linking to any libraries, we need to define it here */
unsigned long __mulsi3 (unsigned long a, unsigned long b)
{
  unsigned long r = 0;

  while (a) {
    if (a & 1)
      r += b;
    a >>= 1;
    b <<= 1;
  }

  return r;
}

/* Stupid way to compute a factorial. Just testing if recursive function calls work */
long factorial(long n)
{
  if (n <= 1)
    return 1;
  else
    return n * factorial(n-1);
}

int main()
{
  /* Try recursive function call */
  *((long*)0x70000000) = factorial(10);

  /* Try 'for' and 'while' loops */
  long *p = (long*)0x70000004;
  for (int i = 0; i <= 10; i++)
    p[i] = 10;

  long *q = p + 9;
  while (q >= p) {
    *q += *(q+1);
    q--;
  }
}
