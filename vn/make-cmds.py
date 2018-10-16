#!/usr/bin/env python

"""
    vn/make-cmd.py
"""

import os
import argparse
import numpy as np
from hashlib import md5
from datetime import datetime

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--num-seed-nodes', type=int, default=5)
    parser.add_argument('--seed', type=int, default=123)
    return parser.parse_args()


base_cmd = (
    '{bin_dir}/bin/test_vn_9.1_x86_64'
    ' --graph-type market'
    ' --graph-file {graph_file}'
    ' --src {src_string}'
    ' --num-runs 5'
    ' | tee results/{run_hash}'
)

bin_dir  = '/home/bjohnson/projects/davis/gunrock/tests/vn'

gunrock_datapath = '/home/bjohnson/projects/davis/gunrock/dataset/large'
datasets = {
    "%s/soc-LiveJournal1/soc-LiveJournal1.mtx" % gunrock_datapath : ( 4847571,   4847571,  68993773),
    "%s/hollywood-2009/hollywood-2009.mtx"     % gunrock_datapath : ( 1139905,   1139905,  57515616),
    "%s/soc-orkut/soc-orkut.mtx"               % gunrock_datapath : ( 2997166,   2997166, 106349209), # not running here, or in SSSP, skip for now
    "%s/indochina-2004/indochina-2004.mtx"     % gunrock_datapath : ( 7414866,   7414866, 194109311),
    "%s/road_usa/road_usa.mtx"                 % gunrock_datapath : (23947347,  23947347,  28854312),
    
    "../data/enron/enron_edgelist_2017-10-20.mtx " : (15056, 15055, 28732),
}

if __name__ == "__main__":
    args = parse_args()
    np.random.seed(args.seed)
    
    print('#/bin/bash\n\n# cmds.sh | seed=%d | date=%s' % (args.seed, datetime.now().strftime('%Y-%m-%dT%H:%M:%S')))
    
    for graph_file, mtx_data in datasets.items():
        srcs = np.random.choice(mtx_data[0], args.num_seed_nodes, replace=False)
        src_string = ','.join(map(str, srcs))
        
        run_obj = {
            "bin_dir"    : bin_dir,
            "graph_file" : graph_file,
            "src_string" : src_string,
        }
        run_obj['run_hash'] = md5(str(run_obj).encode('utf-8')).hexdigest()
        cmd = base_cmd.format(**run_obj)
        print('\n# --\n')
        print(cmd)
    
    print('\n#DONE\n')
