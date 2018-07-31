add types support of query:
ushort, uint, ulong, int ,long ,float, double

FastBit-Python
==============

A pythonic interface to the `FastBit`_ library which
does compressed bitmask indexes on disk-based, column-oriented
data.


This wrapper is very much in progress. (contributors welcome).
It is started from earlier work (http://code.google.com/p/pyfastbit/) by myself
and Jose Nazario.


See tinker.py for current usage.

Installing FastBit
==================

install fastbit c/c++ library::

    wget https://codeforge.lbl.gov/frs/download.php/231/fastbit-ibis1.2.2.tar.gz
    tar xzf fastbit-ibis1.2.2.tar.gz
    cd fastbit-ibis1.2.2/
    ./configure && make -j4 && sudo make install

and to install pyfastbit::

    git clone
    sudo python setup.py install

Usage
=====

::

    >>> from fastbit import FastBit
    >>> import numpy as np
    >>> f = FastBit('datadir.test')
    >>> f.add_array(np.arange(100), 'a')
    >>> f.add_array(np.arange(100, dtype='i'), 'b')
    >>> q = f.query('b > 97', 'b')
    >>> q.b
    [98, 99]
    >>> import shutil; shutil.rmtree('datadir.test')


.. _`FastBit`: https://sdm.lbl.gov/fastbit/
