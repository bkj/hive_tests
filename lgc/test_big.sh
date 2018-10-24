#!/bin/bash

# test_big.sh

for file in ak2010 belgium_osm cit-Patents coAuthorsDBLP delaunay_n13 delaunay_n21 delaunay_n24 europe_osm hollywood-2009 indochina-2004 kron_g500-logn21 roadNet-CA road_usa soc-LiveJournal1 soc-orkut
do
  ./bin/test_pr_nibble_9.1_x86_64 --graph-type market --graph-file ../dataset/large/$file/$file.mtx --src 0 --max-iter 20 --eps 0.0000001
done
