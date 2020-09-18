import math


def modular_inverse(a, n):
    t, new_t = 0, 1
    r, new_r = n, a

    while new_r != 0:
        q = r // new_r
        t, new_t = new_t, t - q * new_t
        r, new_r = new_r, r - q * new_r

    if r > 1:
        return "ERROR!"
    if t < 0:
        t = t + n

    return t


def montgomery_product(a_res: int, b_res: int, n: int, n_comp: int, r):
    t = a_res * b_res
    m = (t * n_comp) % r
    u = (t + m*n) / r
    if u >= n:
        return u - n
    else:
        return u


def montgomery_exp(m: int, e: int, n: int):
    e_bin = "{0:b}".format(e)
    n_bits = int(math.log(n)/math.log(2)) + 1
    r = 2**n_bits
    r_inv = modular_inverse(r, n)
    n_comp = int((r * r_inv - 1) / n)
    m_bar = (m * r) % n
    x_bar = r % n
    for i in range(0, n_bits, 1):
        x_bar = montgomery_product(x_bar, x_bar, n, n_comp, r)

        if int(e_bin[i]) == 1:
            x_bar = montgomery_product(m_bar, x_bar,n, n_comp, r)

    x = montgomery_product(x_bar, 1, n, n_comp, r)

    return x

