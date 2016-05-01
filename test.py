import time
import random
import staticdict
random.seed(123)


d = {}
d['a'] = 'b'
d['c'] = 'd'
staticdict.MakeHashDict(d, 'tmp')


d = staticdict.HashDict('tmp')
print(d.find('a'))
print(d.find('b'))
print(d.find('c'))



def m_test():
    """
    dict 1.19778108597
    baseline 7.37847208977
    pyx 5.19325304031
    cdef 2.38966298103
    """
    d = {}
    print("prepare dict")
    for i in range(1000000):
        x = random.randint(0, 1000000 * 2)
        y = 1000000 * 2 - x
        d[bytes(str(x))] = bytes(str(y))

    print("gen static dict")
    staticdict.MakeHashDict(d, 'tmp')

    sd = staticdict.HashDict('tmp')

    print("test dict")
    bt = time.time()
    for i in range(1000000 * 2):
        y = d.get(bytes(str(i)), None)
        if y is None : continue
    print(time.time() - bt)
    
    print("test static dict")
    n = 0
    bt = time.time()
    for i in range(1000000 * 2):
        y = sd.find(bytes(str(i)))
        if y is None : continue
        n += 1
    print(time.time() - bt)
    print(len(d), n)


m_test()
