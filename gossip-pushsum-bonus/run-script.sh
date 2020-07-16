#!/bin/bash

mix escript.build

TOPO=${1:-full}
ALGO=${2:-gossip}
FAIL=${3:-20}
echo "running ${ALGO} on ${TOPO} from 100 to 1000"
for (( nodes=100; nodes<=1000; nodes=nodes+100 ))
do
    time_out=20
    command="./my_program $nodes ${TOPO} ${ALGO} ${FAIL}"
    echo "Running ./my_program $nodes ${TOPO} ${ALGO} ${FAIL}"
    $command
    # expect -c "set echo \"-noecho\"; set timeout $time_out; spawn -noecho $command; expect timeout { exit 1 } eof { exit 0 }"
    
    echo "--------------"
done