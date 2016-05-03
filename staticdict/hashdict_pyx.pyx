import array
import os
from libc.string cimport strncmp

cdef unsigned long strhash(char* s):
    cdef unsigned long h = 0
    cdef char c
    for c in s :
        h = (h * 31 + (c)) & 0xffffffff
    return h


def calc_bytes(s):
    ret = chr(len(s)).encode('utf8') + s
    return ret

class HashDict():
    def __init__(self, filename):
        self._index = array.array('L')
        self._index.fromfile(
                open(filename + '.index', 'rb'),
                os.stat(filename + '.index').st_size // 8
                )

        self._data = open(filename + '.data', 'rb').read()
        #self._char_data = self._data

    def find(self, key):
        cdef size_t idx = strhash(key) % len(self._index)
        cdef size_t cand_l = 0
        cdef size_t value_l = 0
        cdef size_t key_size = len(key)
        cdef char* key_ptr = key

        cdef unsigned char* _data_ptr = self._data
        cdef char* _data_ptr2 = self._data
        cdef char* cand_ptr

        idx = self._index[idx]

        while True:
            cand_l = _data_ptr[idx]
            if cand_l == 0 : return None

            cand_ptr = _data_ptr2 + idx + 1


            idx = idx + 1 + cand_l
            value_l = _data_ptr[idx]

            if (key_size == cand_l and 
                    strncmp(key_ptr, cand_ptr, cand_l) == 0
                    ) :
                value = self._data[idx + 1 : idx + 1 + value_l]
                return value

            idx = idx + 1 + value_l




def MakeHashDict(d, filename):
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
    datafile = open(filename + '.data', 'wb')
    datafile.write(b'\0')
    offset = 1

    index_bytes = [0 for i in range(bucket_size)]

    for i, v in enumerate(bucket_vec):
        if len(v) == 0 :
            index_bytes[i] = 0
        else :
            datafile.write(v)
            datafile.write(b'\0')
            index_bytes[i] = offset
            offset += len(v) + 1

    array.array('L', index_bytes).tofile(open(filename + '.index', 'wb'))
    datafile.close()
