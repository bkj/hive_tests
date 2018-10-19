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

