#!/usr/bin/env python

"""
    prep-ml20.py
"""

from scipy.io import mmwrite
import numpy as np
import pandas as pd
import argparse
from scipy import sparse

def process(head=None):
    df = pd.read_csv('data/ml.csv', sep=',')
    if head is not None:
        df = df.head(head)
    
    uusers      = np.unique(df.userId.values)
    user_lookup = dict(zip(uusers, range(len(uusers))))
    
    umovies      = np.unique(df.movieId.values)
    movie_lookup = dict(zip(umovies, range(len(umovies))))
    
    rows = df.userId.apply(user_lookup.get).values
    cols = df.movieId.apply(movie_lookup.get).values
    vals = df.rating.values
    
    num_rows = len(user_lookup)
    num_cols = len(movie_lookup)
    
    m = sparse.csr_matrix((vals, (rows, cols)), shape=(num_rows, num_cols))
    if head is None:
        mmwrite('data/ml_full', m, field='real', precision=2, symmetry='general')
    else:
        mmwrite('data/ml_%d' % head, m, field='real', precision=2, symmetry='general')
    
    edge_df = pd.DataFrame({"rows" : rows, "cols" : cols, "vals" : vals})
    edge_df = edge_df[['rows', 'cols', 'vals']]
    edge_df = edge_df.sort_values(['rows', 'cols']).reset_index(drop=True)
    edge_df.cols += edge_df.rows.max() + 1 # Non-overlapping IDs
    
    if head is None:
        edge_df.to_csv('./data/ml_full.edgelist', header=None, sep='\t', index=False)
    else:
        edge_df.to_csv('./data/ml_%d.edgelist' % head, header=None, sep='\t', index=False)

# --

process(head=None)
process(head=int(1e6))
process(head=int(5e6))