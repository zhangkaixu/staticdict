# staticdict
static dict for fast load and search


## static hash table

    # build the dict
    from staticdict import StaticHashDict
    d = {b'by\0tes' : b'bytes'}
    sd = StaticHashDict(d)

    # use it
    print(sd[b'by\0tes'])

    # save
    d.save('tmp')

    # load
    sd = StaticHashDict('tmp')
