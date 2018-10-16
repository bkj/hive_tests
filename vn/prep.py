#!/usr/bin/env python

"""
    vn/prep.py
"""

from scipy import sparse
from scipy.io import mmwrite
import pandas as pd
import numpy as np

# --
# Process ENRON dataset (undirected, has self loops)

df = pd.read_csv('../data/enron/enron_edgelist_2017-10-20.edgelist', header=None, sep='\t')

data = np.ones(df.shape[0])
rows = df[0].values
cols = df[1].values

unodes = np.unique(np.hstack([rows, cols]))
assert unodes.max() == unodes.shape[0] - 1
num_nodes = unodes.shape[0]

m = sparse.csr_matrix((data, (rows, cols)), shape=(num_nodes, num_nodes))

mmwrite('../data/enron/enron_edgelist_2017-10-20.mtx', m, symmetry='symmetric', field='pattern')