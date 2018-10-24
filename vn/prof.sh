#!/bin/bash
/home/bjohnson/projects/davis/gunrock/tests/sssp/bin/test_sssp_9.1_x86_64 \
    --graph-type market \
    --graph-file /home/bjohnson/projects/davis/gunrock/dataset/large/hollywood-2009/hollywood-2009.mtx \
    --undirected \
    --src 0 \
    --num-runs 10