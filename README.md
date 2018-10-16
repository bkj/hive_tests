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
    - implement as SpMM
    - implement other weighting functions
    - test Yuechao's OOM 
 * partial writeup
     - OOM once graph is large enough?
     - How can we handle this gracefully?
     - Should implement this w/ SpMM 
        - different weighting functions may complicate things, but the weighting functions in the reference code don't make a ton of sense
        - Running Scala w/ false is like multipliying G.T.dot(G_ones) where G_ones is G but w/ ones instead of values
        - Running Scala w/ true doesn't obviously map to matrix multiplication w/ normal semiring

### graph_search
    - implement biased random sampling
 * partial writeup
 
### application classification
    - start writeup
    - more datasets for testing ?

### pr_nibble
     - need to start writeup
 - standard Gunrock datasets

--
TODO

- Implement SpMM version of `GraphSearch`
- Implement biased random sampling in `GraphSearch`
