import array
import os
from libc.string cimport strncmp
from cython.operator cimport dereference as deref

cdef unsigned long strhash(char* s):
    cdef unsigned long h = 0
    cdef char c
    for c in s :
        h = (h * 31 + (c)) & 0xffffffff
    return h


def calc_bytes(s):
    cdef size_t l = len(s)

    b = []
    while l > 0 :
        b.append(l % 128)
        l = l // 128
    #print(b)
    for l in range(len(b) - 1):
        b[l] += 128
    #print('coded b', b)
    #b = reversed(b)
    b = array.array('B', b).tostring()
    #b = b''.join([chr(i).encode('ascii') for i in b])
    #print(s, b)

    return b + s

cdef size_t get_size(unsigned char* p, size_t* size):
    cdef unsigned char cur = 0
    size[0] = 0
    cdef size_t i = 0

    while True :
        cur = p[0]
        #print('cur', cur, (cur & 0x7f) << (i * 7))
        #size[0] = (size[0] << 7) | (cur & 0x8f)
        size[0] = size[0] | ((cur & 0x7f) << (i * 7))
        i = i + 1
        if cur < 128 :
            #print('return', i, size[0])
            return i
        p = p + 1



class StaticHashDict():
    def save(self, filename):
        self._index.tofile(open(filename + '.index', 'wb'))
        datafile = open(filename + '.data', 'wb')
        datafile.write(self._data)
        datafile.close()


    def fromdict(self, d):
        '''determine the bucket size'''
        bucket_size = 1
        while bucket_size * 2 < len(d) :
            bucket_size *= 2

        bucket_vec = [bytes() for i in range(bucket_size)]


        '''calc str for each bucket'''
        for key, value in d.items():
            idx = strhash(key) % bucket_size
            bucket_vec[idx] += (
                    (calc_bytes(key))
                    + (calc_bytes(value)))

        '''write the index file'''
        _data = [b'\0']
        offset = 1

        index_bytes = [0 for i in range(bucket_size)]

        for i, v in enumerate(bucket_vec):
            if len(v) == 0 :
                index_bytes[i] = 0
            else :
                _data.append(v)
                _data.append(b'\0')

                index_bytes[i] = offset
                offset += len(v) + 1

        self._index = array.array('L', index_bytes)
        self._data = b''.join(_data)

    def load(self, filename):
        self._index = array.array('L')
        self._index.fromfile(
                open(filename + '.index', 'rb'),
                os.stat(filename + '.index').st_size // 8
                )

        self._data = open(filename + '.data', 'rb').read()

    def __init__(self, filename):
        if type(filename) == str :
            self.load(filename)
        if type(filename) == dict :
            self.fromdict(filename)

    def __contains__(self, key):
        return self[key] is not None

    def __getitem__(self, key):
        cdef size_t idx = strhash(key) % len(self._index)
        cdef size_t cand_l = 0
        cdef size_t value_l = 0
        cdef size_t key_size = len(key)
        cdef char* key_ptr = key

        cdef unsigned char* _data_ptr = self._data
        cdef char* _data_ptr2 = self._data
        cdef char* cand_ptr
        cdef size_t l_size = 0

        idx = self._index[idx]

        while True:
            l_size = get_size(_data_ptr + idx, (&cand_l))

            if cand_l == 0 : return None

            cand_ptr = _data_ptr2 + idx + l_size

            idx = idx + l_size + cand_l


            l_size = get_size(_data_ptr + idx, (&value_l))

            if (key_size == cand_l and 
                    strncmp(key_ptr, cand_ptr, cand_l) == 0
                    ) :
                value = self._data[idx + l_size : idx + l_size + value_l]
                return value

            idx = idx + l_size + value_l

    def find(self, key):
        return self[key]
