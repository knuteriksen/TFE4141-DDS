import unittest
import random

k = 32

def montgomery_product(a_res: int, b_res: int, n: int):
    """
    Returns u = a_res * b_res * r_res % n
    """
    u = 0
    a_bin = "{0:032b}".format(int(a_res))
    for i in range(k-1,-1,-1):
        u = u + int(a_bin[i])*b_res
        if not u//2:
            u = u + n
        u = u//2
    return u

def montgomery_exp(m: int, e: int, n: int):
    """
    Returns m^e % n
    """

    # Binary string representation of exponent and modulus
    n_bin = "{0:b}".format(n)
    e_bin = "{0:032b}".format(e)
    # Number of bits needed to represent exponent and modulus
    n_bits = len(n_bin)

    # r > n
    r = pow(2,int(20))

    # Computation of m residue
    m_res = mod(m,r,n)

    # Computation of x residue
    x_res = mod(r,1,n)

    for i in range(k):
        x_res = montgomery_product(x_res, x_res, n)

        if int(e_bin[i]) == 1:
            x_res = montgomery_product(m_res, x_res,n)

    x = montgomery_product(x_res, 1, n)

    return x


def mod(a, b, n):   # t = r(mod n)
    # t = qn + R
    """
    Returns r = a * b mod(n)
    """

    t = a*b
    # Pick q s.t. q*m>t
    q = n
    while(q<=t):
        q += n
    q -= n
    r = t - q
    return r

# UNIT TESTS:
def gen_rand():
  base = random.randint(1,1000)
  exp  = random.randint(1,1000)
  modulo = random.randrange(1, 1000, 2)
  return base, exp, modulo

class tests(unittest.TestCase):

    def test_montgomery_exponential(self):

        for i in range(5):
          random.seed(i)
          base, exp, modulo = gen_rand()
          expected = (pow(base,exp))%modulo
          actual = montgomery_exp(base, exp, modulo)

          try:
            self.assertEqual(expected, actual)
          except:
            print(f"\n{base}^{exp}(mod {modulo}) = (actual: {actual}, expected: {expected})")



if __name__ == '__main__':
    unittest.main(argv=['first-arg-is-ignored'], exit=False)
