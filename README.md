### hive_tests

graph_search
- - standard datasets w/ randomly chosen seeds + random scores
    - TA1 datasets?
    
vertex_nomination
    - standard datasets w/ randomly chosen seeds
    - TA1 datasets?

application_classification
    - D3 dataset
    - TA1 datasets?

SGM
    - connectome
    - kasios

Graph projections
    - LANL network data
    - MovieLens 20M

LCG
    - standard datasets w/ randomly chosen seeds
    - TA1 datasets?

--

### VN
 * standard gunrock datasets
 * partial writeup

### SGM
    - start writeup
    - test on connectome graphs
    - finish optimizing auction algorithm

### PROJ
    - implement other weighting functions
    - TODO: chunked multiplication, to support much larger graphs
 * partial writeup

- This is currently broken on `dev-refactor`? Works on `sgpyc`'s `bkj-testing-hotfix` though

### graph_search
    - more profiling
    - more datasets
    - rerun Gunrock benchmarks w/ O3 (?)
    - implement function that terminates run when no nodes are active
 
### application classification
    - start writeup
    - more datasets for testing ?

### pr_nibble
    - work with Carl

--
TODO

- Implement SpMM version of `GraphSearch`
- Implement biased random sampling in `GraphSearch`
>>>>>>> eb1e45ad1452337e986e4478d49b09effa1f9bd5
