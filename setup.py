#coding:utf8
from distutils.core import setup
from Cython.Build import cythonize

setup(
        name = 'staticdict',

        version = '0.0.2',

        author = 'ZHANG Kaixu',
        author_email = 'zhangkaixu@hotmail.com',
        url = 'https://github.com/zhangkaixu/staticdict',

        description = "Static dict for faster dump and load",

        ext_modules = cythonize("staticdict/hashdict_pyx.pyx"),
        packages = ['staticdict'],
        package_dir = {'staticdict':'staticdict'}
    )
