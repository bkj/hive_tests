#!/bin/bash

# vn/run.sh

# --
# Build

WORKDIR=$(pwd)
cd $HOME/projects/davis/gunrock/tests/vn
make clean
make
cd $WORKDIR

# --
# Prep data

python prep.py

# --
# Generate commands

mkdir -p results
python make-cmds.py > cmds.sh
chmod +x cmds.sh

cat ./cmds.sh

# ----------------------
# HIVE reference version

cd ~/projects/hive/v0/vertex_nomination_Enron

# enron
python snap_vertex_nomination.py \
    --inpath ./_data/enron/enron_edgelist_2017-10-20.edgelist \
    --num-runs 10 --num-seeds 5

# elapsed 4.22690701485
# elapsed 3.31696605682
# elapsed 3.94093322754
# elapsed 4.35121011734
# elapsed 3.78329610825
# elapsed 3.91527295113
# elapsed 6.84083485603
# elapsed 3.7240831852
# elapsed 3.50313091278
# elapsed 3.42775392532

# hollywood
HOLLYWOOD="/home/bjohnson/projects/davis/gunrock/dataset/large/hollywood-2009/hollywood-2009.edgelist"
python snap_vertex_nomination.py \
    --inpath $HOLLYWOOD \
    --num-runs 10 --num-seeds 5

# ----------------------
# Gunrock version

cd /home/bjohnson/projects/davis/gunrock/tests/vn

# enron
python ~/edgelist2mtx.py \
    --inpath ~/projects/hive/v0/vertex_nomination_Enron/_data/enron/enron_edgelist_2017-10-20.edgelist \
    --outpath ./enron.mtx \
    --symmetry symmetric \
    --field pattern

./bin/test_vn_9.1_x86_64 \
    --graph-type market \
    --graph-file ./enron.mtx \
    --src random \
    --srcs-per-run 5 \
    --num-runs 10

# hollywood
HOLLYWOOD="../../dataset/large/hollywood-2009/hollywood-2009.mtx"
./bin/test_vn_9.1_x86_64 \
    --graph-type market \
    --graph-file $HOLLYWOOD \
    --src random \
    --srcs-per-run 5 \
    --num-runs 10

INDO="../../dataset/large/indochina-2004/indochina-2004.mtx"
./bin/test_vn_9.1_x86_64 \
    --graph-type market \
    --graph-file $INDO \
    --src random \
    --srcs-per-run 5 \
    --num-runs 10
