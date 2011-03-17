#!/usr/bin/env python

from fastbit import FastBit
import numpy as np

import shutil
shutil.rmtree('arr', True)

fast = FastBit('arr')
fast.logfile = 'test.log'
fast.verbosity = 10


fast.add_array(np.arange(10, dtype='f'), 'arr')
fast.add_array(np.arange(10, dtype='i'), 'brr')
#fast.add_array(np.array(['asdf', 'jkll'], dtype='c'), 'srr')


print "added"

fast.flush_buffer()
print fast.guess_col_types()

print "flushed"
del fast


f = FastBit('arr')
#q = f.query('brr > 0', 'brr', 'arr') #, 'srr')
q = f.query('brr > 0')
print q.rows, q.columns, len(q)

#print q.brr
for i in range(4):
    print q.arr#, q.brr

# for some reason __getitem__ gives a segfault
#for col in q.columns:
#    print col, q[col]
