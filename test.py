import time
import random
import staticdict
random.seed(123)


d = {}
d[b'a'] = b'b'
d[b'c'] = b'd'
d = staticdict.StaticHashDict(d)
print(d[b'a'])
print(d[b'b'])
print(d[b'c'])



def m_test():
    """
    dict 1.19778108597
    baseline 7.37847208977
    pyx 5.19325304031
    cdef 2.38966298103
    """
    d = {}
    N = 1000000
    print("prepare dict")
    for i in range(N):
        x = random.randint(0, N * 2)
        y = N * 2 - x
        d[str(x).encode('utf8')] = str(y).encode('utf8')

    print("gen static dict")
    sd = staticdict.StaticHashDict(d)
    sd.save('tmp')
    sd = staticdict.StaticHashDict('tmp')

    print("test dict")
    bt = time.time()
    for i in range(N * 2 + 1):
        y = d.get(str(i).encode('utf8'), None)
        if y is None : continue
    print(time.time() - bt)
    
    print("test static dict")
    n = 0
    bt = time.time()
    for i in range(N * 2 + 1):
        y = sd[str(i).encode('utf8')]
        if y is None : continue
        n += 1
    print(time.time() - bt)
    print(len(d), n)


m_test()
