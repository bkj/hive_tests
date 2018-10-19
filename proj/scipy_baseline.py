#!/usr/bin/env python

"""
    scipy_baseline.py
"""

import sys
import json
from time import time
from scipy.io import mmread

print('loading')
x = mmread(sys.argv[1]).tocsr()
print('x.shape', x.shape)

t = time()
p = x.T.dot(x)
print(json.dumps({
    'elapsed' : time() - t,
    'nnz' : p.nnz
}))