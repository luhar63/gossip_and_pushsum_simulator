
#!/bin/bash
mix escript.build

NODES=${1:-500}
declare -a TOPOS=("full" "line" "rand2D" "3Dtorus" "honeycomb" "randhoneycomb")
declare -a ALGO=("gossip")
FAIL=${2:-20}
echo "running ${ALGO} on ${TOPO} from 100 to 1000"
for algo in ${ALGO[@]}
do
    for topo in ${TOPOS[@]}
    do
        time_out=20
        command="./my_program ${NODES} $topo $algo ${FAIL}"
        echo "Running ./my_program ${NODES} $topo $algo ${FAIL}"
        $command
        # expect -c "set echo \"-noecho\"; set timeout $time_out; spawn -noecho $command; expect timeout { exit 1 } eof { exit 0 }"
        
        echo "--------------"
    done
done