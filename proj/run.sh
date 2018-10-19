#!/bin/bash

# -------------------------------------
# data prep

mkdir -p data
wget http://files.grouplens.org/datasets/movielens/ml-20m.zip
unzip ml-20m.zip
mv ml-20m/ratings.csv ./data/ml.csv
rm -rf ml-20m ml-20m.zip

# Create datasets
# python prep-ml20.py
python ~/mtx2square.py --inpath data/ml_1000000.mtx --outpath data/ml_1000000_square.mtx
python ~/mtx2square.py --inpath data/ml_5000000.mtx --outpath data/ml_5000000_square.mtx
python ~/mtx2square.py --inpath data/ml_full.mtx --outpath data/ml_full_square.mtx

wget https://graphchallenge.s3.amazonaws.com/synthetic/graph500-scale18-ef16/graph500-scale18-ef16_adj.tsv.gz
gunzip graph500-scale18-ef16_adj.tsv.gz

python ~/edgelist2mtx.py --inpath graph500-scale18-ef16_adj.tsv \
    --outpath data/graph500-scale18-ef16_adj.mtx \
    --field pattern \
    --symmetry general

python ~/mtx2edgelist.py --inpath data/graph500-scale18-ef16_adj.mtx --outpath data/graph500-scale18-ef16_adj.edgelist

DATA=/home/bjohnson/projects/davis/hive_tests/proj/data

# -------------------------------------
# Scipy benchmark

python scipy_baseline.py $DATA/ml_1000000.mtx
# {"nnz": 63104132, "elapsed": 2.4912478923797607}

python scipy_baseline.py $DATA/ml_5000000.mtx
# {"nnz": 157071858, "elapsed": 10.105232000350952}

python scipy_baseline.py $DATA/ml_full.mtx
# {"nnz": 286857534, "elapsed": 39.18109321594238}

python scipy_baseline.py $DATA/graph500-scale18-ef16_adj.mtx
# {"nnz": 2973926895, "elapsed": 150.869460105896}

# -------------------------------------
# PNNL benchmarks

cd /home/bjohnson/projects/hive/cpp/graph_projection
mkdir -p results
make clean; make

THREADS=(64 32 16 8 4 2 1)

rm -f results/ml_1000000; touch results/ml_1000000
for THREAD in ${THREADS[*]}; do
    OMP_NUM_THREADS=$THREAD ./graph_projection --edgelistfile $DATA/ml_1000000.edgelist \
        --simple 1 --num-vertices 20693 --num-edges 1000000 | tee -a results/ml_1000000
done
# 64 20693 1000000 9.055 63090182
# 32 20693 1000000 13.1482 63090182
# 16 20693 1000000 22.0257 63090182
# 8 20693 1000000 37.5853 63090182
# 4 20693 1000000 60.1542 63090182
# 2 20693 1000000 62.2842 63090182
# 1 20693 1000000 61.4852 63090182

rm -f results/ml_5000000; touch results/ml_5000000
for THREAD in ${THREADS[*]}; do
    OMP_NUM_THREADS=$THREAD ./graph_projection --edgelistfile $DATA/ml_5000000.edgelist \
        --simple 1 --num-vertices 54797 --num-edges 5000000 | tee -a results/ml_5000000
done
# 64 54797 5000000 29.0056 157051456
# 32 54797 5000000 38.1186 157051456
# 16 54797 5000000 57.4606 157051456
# 8 54797 5000000 113.987 157051456
# 4 54797 5000000 218.519 157051456
# 2 54797 5000000 309.723 157051456
# 1 54797 5000000 357.511 157051456

rm -f results/ml_full; touch results/ml_full
for THREAD in ${THREADS[*]}; do
    OMP_NUM_THREADS=$THREAD ./graph_projection --edgelistfile $DATA/ml_full.edgelist \
        --simple 1 --num-vertices 165237 --num-edges 20000263 | tee -a results/ml_full
done

# -------------------------------------
# GraphBLAS

cd /home/bjohnson/projects/davis/graphblas_proj
export GRAPHBLAS_PATH=$HOME/projects/davis/GraphBLAS
make clean; make

./proj --X $DATA/ml_1000000.mtx --unweighted 1 --proj-debug 1
# proj_num_edges          = 63104132
# dim_out                 = 13950
# proj_num_edges (noloop) = 63090182
# timer                   = 366.06

./proj --X $DATA/ml_5000000.mtx --unweighted 1 --proj-debug 1
# proj_num_edges          = 157071858
# dim_out                 = 20402
# proj_num_edges (noloop) = 157051456
# timer                   = 1221.32

./proj --X $DATA/ml_full.mtx --unweighted 1 --proj-debug 1
# proj_num_edges          = 286857534
# dim_out                 = 26744
# proj_num_edges (noloop) = 286830790
# timer                   = 5012.05
# Profiling notes:
#   83% of time spent in csrgemm
#   16% spend in csrgemmNnz (memory allocation)
#   proj_nochunk.png

./proj --X $DATA/graph500-scale18-ef16_adj.mtx --unweighted 1 --proj-debug 1
# OOM!

./proj --X $DATA/graph500-scale18-ef16_adj.mtx --unweighted 1 --proj-debug 1 --num-chunks 2
# proj_num_edges          = 2973926895
# dim_out                 = 174147
# proj_num_edges (noloop) = 2973752748
# timer                   = 26478
# Profiling notes:
#   Could interleave memory allocation, memory transfer, and compute


# -------------------------------------
# Gunrock

cd /home/bjohnson/projects/davis/gunrock/tests/proj
make clean; make

# ./bin/test_proj_9.1_x86_64 --graph-type market --graph-file ../../dataset/small/chesapeake.mtx

./bin/test_proj_9.1_x86_64 --graph-type market --graph-file $DATA/ml_1000000_square.mtx \
    --quick --num-runs 10
# Loading Matrix-market coordinate-formatted graph ...
# Reading from /home/bjohnson/projects/davis/hive_tests/proj/data/ml_1000000_square.mtx:
#   Parsing MARKET COO format edge-value-seed = 1539910697
#  (20693 nodes, 1000000 directed edges)... 
# Done parsing (0 s).
#   Converting 20693 vertices, 1000000 directed edges ( ordered tuples) to CSR format...
# Done converting (0s).
# ==============================================
#  advance-mode=LB
# Using advance mode LB
# Using filter mode CULL
# __________________________
# 0    0   0   queue3      oversize :  124158 ->   1000002
# 0    0   0   queue3      oversize :  124158 ->   1000002
# --------------------------
# Run 0 elapsed: 62.254190, #iterations = 1
# Run 1 elapsed: 60.307026, #iterations = 1
# Run 2 elapsed: 61.609030, #iterations = 1
# Run 3 elapsed: 60.275078, #iterations = 1
# Run 4 elapsed: 60.352087, #iterations = 1
# Run 5 elapsed: 60.064793, #iterations = 1
# Run 6 elapsed: 60.026169, #iterations = 1
# Run 7 elapsed: 60.559988, #iterations = 1
# Run 8 elapsed: 60.793877, #iterations = 1
# Run 9 elapsed: 60.241938, #iterations = 1
# edge_counter=63090182
# [proj] finished.
#  avg. elapsed: 60.648417 ms
#  iterations: 30506979
#  min. elapsed: 60.026169 ms
#  max. elapsed: 62.254190 ms
#  src: 0
#  nodes_visited: 30518624
#  edges_visited: 30518592
#  nodes queued: 140732727768847
#  edges queued: 140732727768672
#  load time: 398.319 ms
#  preprocess time: 967.426000 ms
#  postprocess time: 1268.399000 ms
#  total time: 2879.134178 ms


./bin/test_proj_9.1_x86_64 --graph-type market --graph-file $DATA/ml_5000000_square.mtx \
    --quick --num-runs 10
# Loading Matrix-market coordinate-formatted graph ...
# Reading from /home/bjohnson/projects/davis/hive_tests/proj/data/ml_5000000_square.mtx:
#   Parsing MARKET COO format edge-value-seed = 1539910750
#  (54797 nodes, 5000000 directed edges)... 
# Done parsing (1 s).
#   Converting 54797 vertices, 5000000 directed edges ( ordered tuples) to CSR format...
# Done converting (0s).
# ==============================================
#  advance-mode=LB
# Using advance mode LB
# Using filter mode CULL
# __________________________
# 0    0   0   queue3      oversize :  328782 ->   5000002
# 0    0   0   queue3      oversize :  328782 ->   5000002
# --------------------------
# Run 0 elapsed: 334.959984, #iterations = 1
# Run 1 elapsed: 335.789919, #iterations = 1
# Run 2 elapsed: 334.650040, #iterations = 1
# Run 3 elapsed: 333.799839, #iterations = 1
# Run 4 elapsed: 338.119984, #iterations = 1
# Run 5 elapsed: 334.287167, #iterations = 1
# Run 6 elapsed: 335.074186, #iterations = 1
# Run 7 elapsed: 332.584858, #iterations = 1
# Run 8 elapsed: 334.558010, #iterations = 1
# Run 9 elapsed: 335.484982, #iterations = 1
# edge_counter=157051456
# [proj] finished.
#  avg. elapsed: 334.930897 ms
#  iterations: 30289891
#  min. elapsed: 332.584858 ms
#  max. elapsed: 338.119984 ms
#  src: 0
#  nodes_visited: 30301536
#  edges_visited: 30301504
#  nodes queued: 140737163245343
#  edges queued: 140737163245168
#  load time: 1481.16 ms
#  preprocess time: 980.844000 ms
#  postprocess time: 8658.879042 ms
#  total time: 13260.521173 ms

./bin/test_proj_9.1_x86_64 --graph-type market --graph-file $DATA/ml_full_square.mtx \
    --quick --num-runs 10
# OOM!

./bin/test_proj_9.1_x86_64 --graph-type market --graph-file $DATA/graph500-scale18-ef16_adj.mtx \
    --quick --num-runs 10
# OOM!


# ======================================================================================
# ================================= vv SCRATCH vv ======================================







WORKDIR=$(pwd)
cd ~/projects/davis/gunrock/tests/proj
make clean
make

# --
# Reference implementation

cd /home/bjohnson/projects/hive/cpp/graph_projection
mkdir -p results
make clean
make

# Small tests
OMP_NUM_THREADS=1 ./graph_projection --edgelistfile sample_edgelist.csv --simple 0 --num-vertices 9 --num-edges 9
OMP_NUM_THREADS=1 ./graph_projection --edgelistfile sample_edgelist.csv --simple 1 --num-vertices 9 --num-edges 9

./graph_projection --edgelistfile chesapeake.edgelist --simple 0 --num-vertices 39 --num-edges 340
./graph_projection --edgelistfile dir_chesapeake.edgelist --simple 0 --num-vertices 39 --num-edges 170


# Small MovieLens
cp ~/projects/davis/hive_tests/proj/ml-20m/small_ratings_clean.tsv small_ratings_clean.tsv

THREADS=(1 2 4 8 16 32 64)
echo "" > results/small_ratings_clean
for THREAD in ${THREADS[*]}; do
    echo $THREAD
    OMP_NUM_THREADS=$THREAD ./graph_projection --edgelistfile small_ratings_clean.tsv --simple 1 \
        --num-vertices 20693 --num-edges 1000000 >> results/small_ratings_clean
done

# RMAT graph -- incorrect?
wget https://graphchallenge.s3.amazonaws.com/synthetic/graph500-scale18-ef16/graph500-scale18-ef16_adj.tsv.gz
gunzip graph500-scale18-ef16_adj.tsv.gz

THREADS=(1 2 4 8 16 32 64)
echo "" > results/rmat
for THREAD in ${THREADS[*]}; do
    echo $THREAD
    OMP_NUM_THREADS=$THREAD ./graph_projection  --edgelistfile graph500-scale18-ef16_adj.tsv \
        --num-vertices 262144 --num-edges 4194304 >> results/rmat
done

OMP_NUM_THREADS=16 ./graph_projection  --edgelistfile tmp \
    --num-vertices 174147 --num-edges 7600696

# --
# GraphBLAS

cd projects/davis/graphblas_proj/
export GRAPHBLAS_PATH=$HOME/projects/davis/GraphBLAS
make clean
make

# small ml20m
./proj --X ~/projects/davis/hive_tests/proj/ml-20m/small_ratings.mtx --unweighted 1 --proj-debug 1 --print-results 0 --onto-cols 1

# small whole ml20m
./proj --X ~/projects/davis/hive_tests/proj/ml-20m/ratings.mtx --unweighted 1 --proj-debug 1 --print-results 0 --onto-cols 1

# RMAT graph
# !! Need to run this manually, because of 1-based indexing, etc
# python ~/edgelist2mtx.py \
#     --symmetry general \
#     --inpath /home/bjohnson/projects/hive/cpp/graph_projection/graph500-scale18-ef16_adj.tsv \
#     --outpath graph500-scale18-ef16_adj.mtx
# ./proj --X graph500-scale18-ef16_adj.mtx --unweighted 1 --proj-debug 1 --print-results 0 --onto-cols 1
# !! Too large for GPU memory
