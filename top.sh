#!/bin/bash
MAX_RESULTS=10

print_top_n_cpu_consumers() {
echo "*********** CPU Usage ****************"
if [[ ! -z $USER ]] && [[ ! -z $HOST ]] 
	then
ssh $USER@$HOST <<EOF
top -b -n 1 -o %CPU | awk '{print \$1,\$2,\$9,\$12}' | head -n $((MAX_RESULTS+7)) | tail -$((MAX_RESULTS+1))
EOF
else
	top -b -n 1 -o %CPU | awk '{print $1,$2,$9,$12}' | head -n $((MAX_RESULTS+7)) | tail -$((MAX_RESULTS+1))
fi	
}

print_top_n_memory_consumers() {
echo "*********** Memory Usage ****************"
if [[ ! -z $USER ]] && [[ ! -z $HOST ]] 
	then
ssh $USER@$HOST <<EOF
top -b -n 1 -o %MEM | awk '{print \$1,\$2,\$10,\$12}' | head -n $((MAX_RESULTS+7)) | tail -$((MAX_RESULTS+1))
EOF
else
	top -b -n 1 -o %MEM | awk '{print $1,$2,$10,$12}' | head -n $((MAX_RESULTS+7)) | tail -$((MAX_RESULTS+1))
fi	
}

print_top_n_disk_io_consumers() {
echo "*********** Disk I/O Usage ****************"
if [[ ! -z $USER ]] && [[ ! -z $HOST ]] 
	then
ssh  -t $USER@$HOST "sudo iotop -kqP | head -n $((MAX_RESULTS+3)) | tail -$((MAX_RESULTS+1))"
else
	sudo iotop -kqP | head -n $((MAX_RESULTS+3)) | tail -$((MAX_RESULTS+1))
fi	
}

help() {
	echo "Usage: -h <HOST> -u <USER> -n <LIMIT> -s <CPU|MEM|IO>"
}

# parse input arguments
while getopts ":u:h:s:n:" option; do
    case "${option}" in
        u)
            USER=${OPTARG}
            ;;
        h)
            HOST=${OPTARG}
            ;;
        s)
			SORT_BY=${OPTARG}
            ;;
        n)
			MAX_RESULTS=${OPTARG}
            ;;
        *)
            help
            ;;
    esac
done
shift $((OPTIND-1))


if [[ ${SORT_BY^^} = "MEM" ]] 
	then
	print_top_n_memory_consumers
elif [[ ${SORT_BY^^} = "IO" ]]
	then
	print_top_n_disk_io_consumers
else
	print_top_n_cpu_consumers
fi

