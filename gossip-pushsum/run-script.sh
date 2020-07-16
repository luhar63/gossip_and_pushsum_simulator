#!/bin/bash

mix escript.build

TOPO=${2:-full}
ALGO=${2:-gossip}
echo "running ${ALGO} on ${TOPO} from 100 to 1000"
for (( nodes=100; nodes<=1000; nodes=nodes+100 ))
do
    echo "Running ./gossip $nodes ${TOPO} ${ALGO}"
    ./my_program $nodes ${TOPO} ${ALGO}
    echo "--------------"
done