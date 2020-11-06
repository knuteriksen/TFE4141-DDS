import unittest
import random


def modular_inverse(a, n):
    """
    Returns t from the equation
    a*t = 1 % n
    """

    t, new_t = 0, 1
    r, new_r = n, a

    while new_r != 0:
        q = r // new_r
        t, new_t = new_t, t - q * new_t
        r, new_r = new_r, r - q * new_r

    if r > 1:
        return "ERROR: The modulus(n) must be an odd number!"
    if t < 0:
        t = t + n

    return t


def montgomery_product(a_res: int, b_res: int, n: int, n_comp: int, r):
    """
    Returns u = a_res * b_res * r_res % n
    """
    t = a_res * b_res
    m = (t * n_comp) % r
    u = (t + m*n) // r
    if u >= n:
        return u - n
    else:
        return u


def montgomery_exp(m: int, e: int, n: int):
    """
    Returns m^e % n
    """

    # Binary string representation of exponent and modulus
    e_bin = "{0:b}".format(e)
    n_bin = "{0:b}".format(n)
    
    # Number of bits needed to represent exponent and modulus
    e_bits = len(e_bin)
    n_bits = len(n_bin)
    
    # r > n
    r = 2**n_bits
    
    # Modular inverse of r
    r_inv = int(modular_inverse(r, n))
    
    # Computation of n compliment, i.e n'
    n_comp = int((r * r_inv - 1) / n)

    # Computation of m residue
    m_res = (m * r) % n

    # Computation of x residue
    x_res = r % n
    
    for i in range(0, e_bits, 1):
        x_res = montgomery_product(x_res, x_res, n, n_comp, r)

        if int(e_bin[i]) == 1:
            x_res = montgomery_product(m_res, x_res,n, n_comp, r)

    x = montgomery_product(x_res, 1, n, n_comp, r)

    return x
                                
# UNIT TESTS:
def gen_rand():
  base = random.randint(1,1000)
  exp  = random.randint(1,1000)
  modulo = random.randrange(1, 1000, 2)
  return base, exp, modulo

class tests(unittest.TestCase):
    
    def test_montgomery_exponential(self):
        
        for i in range(1000):
          random.seed(i)
          base, exp, modulo = gen_rand()
          expected = (base**exp)%modulo
          actual = montgomery_exp(base, exp, modulo)
          
          try:
            self.assertEqual(expected, actual)
          except:
            print(f"\n{base}^{exp}(mod {modulo}) = (actual: {actual}, expected: {expected})")
          

        
if __name__ == '__main__':
    unittest.main(argv=['first-arg-is-ignored'], exit=False)
