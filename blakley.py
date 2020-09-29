import unittest
import random

k = 256
def modular_product(a, b, n):
    """
    Input: a, b, n
    Output: r = a * b mod(n)
    Note: n > a,b
    """
    r = 0
    a_bin = "{0:0256b}".format(a)
    for i in range(len(a_bin)):
        r = 2*r + int(a_bin[i]) * b
        # r = r % n :
        if(r >= n):
            r = r-n
        if(r >= n):
            r = r-n
    return r


def modular_exp(m, e, n):
  c = 1
  p = m
  e_bin = "{0:0256b}".format(e)

  for i in range(k-1, 0, -1):
    if int(e_bin[i]):
      c = modular_product(c, p, n)
    p = modular_product(p, p, n)
  if int(e_bin[0]):
    c = modular_product(c, p, n)
  return c



def gen_rand():
  base = random.randint(1,1000)
  exp  = random.randint(1,1000)
  modulo = random.randrange(base, base+1000, 2)
  return base, exp, modulo


class tests(unittest.TestCase):

    def test_blakley_exponential(self):
        for i in range(100):
          random.seed(i)
          base, exp, modulo = gen_rand()
          expected = (pow(base,exp))%modulo
          actual = modular_exp(base, exp, modulo)

          try:
            self.assertEqual(expected, actual)
          except:
            print(f"\n{base}^{exp}(mod {modulo}) = (actual: {actual}, expected: {expected})")
    

    def test_blakley_product(self):
      for i in range(100):
        random.seed(i)
        a, b, n = gen_rand()
        n = a+b * 2

        expected = (a*b)%n
        actual = modular_product(a, b, n)
        self.assertEqual(expected,actual)

    def test_encrypt(self):
      message = "0x0000000011111111222222223333333344444444555555556666666677777777"
      m = int(message, 0)
    
      power = "0x0000000000000000000000000000000000000000000000000000000000010001"
      e = int(power, 0)
    
      n = "0x99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d"
      n = int(n, 0)

      expected = int("0x23026c469918f5ea097f843dc5d5259192f9d3510415841ce834324f4c237ac7",0)
      actual = modular_exp(m, e, n)
      self.assertEqual(expected, actual)
      print("Encryption successful\n")
    
    def test_decrypt(self):
       message = "0x23026c469918f5ea097f843dc5d5259192f9d3510415841ce834324f4c237ac7"
       c = int(message, 0)

       power = "0x0cea1651ef44be1f1f1476b7539bed10d73e3aac782bd9999a1e5a790932bfe9"
       d = int(power, 0)

       n = "0x99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d"
       n = int(n, 0)

       expected = int("0x0000000011111111222222223333333344444444555555556666666677777777", 0)
       actual = modular_exp(c, d, n)
       self.assertEqual(expected, actual)
       print("Decryption successful\n")

if __name__ == '__main__':
    unittest.main(argv=['first-arg-is-ignored'], exit=False)
