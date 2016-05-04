# staticdict
静态的词典

便于快速保存和读取


## StaticHashDict

    from staticdict import *

    # 用key和value都是bytes的dict建词典
    sd = StaticHashDict({b'by\0tes' : b'bytes'})

    # 使用
    print(sd[b'by\0tes'])

    # 即使key非常多 保存 读取 都非常快
    d.save('tmp')
    sd = StaticHashDict('tmp')
