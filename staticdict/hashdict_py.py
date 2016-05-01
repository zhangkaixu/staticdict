import array
import os
def strhash(s):
    h = 0
    for c in s :
        h = (h * 31 + ord(c)) & 0xffffffff
    return h


def calc_n_bytes(s):
    if len(s) < 128 :
        return len(s) + 1
    return len(s) + 2  # TODO
def calc_bytes(s):
    return chr(len(s)) + s
    pass

class HashDict():
    def __init__(self, filename):
        self._index = array.array('L')
        self._index.fromfile(
                open(filename + '.index', 'rb'),
                os.stat(filename + '.index').st_size / 8
                )

        self._data = open(filename + '.data', 'rb').read()

    def find(self, key):
        idx = strhash(key) % len(self._index)
        idx = self._index[idx]

        while True:
            cand_l = ord(self._data[idx])
            if cand_l == 0 : return None
            cand = self._data[idx + 1 : idx + 1 + cand_l]

            idx = idx + 1 + cand_l
            value_l = ord(self._data[idx])
            value = self._data[idx + 1 : idx + 1 + value_l]

            if cand == key :
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
        bucket_vec[idx] += calc_bytes(key) + calc_bytes(value)

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
