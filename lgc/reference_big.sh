#!/bin/bash

# reference_big.sh

for file in ak2010 belgium_osm cit-Patents coAuthorsDBLP delaunay_n13 delaunay_n21 delaunay_n24 europe_osm hollywood-2009 indochina-2004 kron_g500-logn21 roadNet-CA road_usa soc-LiveJournal1 soc-orkut
do
  python3 partition.py --algorithm pageRank_nibble --inpath ../../dataset/large/$file/$file.edgelist --reference-node 0 --rho 8.0e-6 --epsilon 1.0e-7
done
