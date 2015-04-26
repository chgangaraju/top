#!/bin/bash
MAX_RESULTS=10

print_top_n_cpu_consumers() {
echo "*********** CPU Usage ****************"
if [[ ! -z $USER ]] && [[ ! -z $HOST ]] 
	then
ssh $USER@$HOST <<EOF
ps axo pcpu,comm,pid,euser | sort -nr | head -n $MAX_RESULTS
EOF
else
	ps axo pcpu,comm,pid,euser | sort -nr | head -n $MAX_RESULTS
fi	
}

print_top_n_memory_consumers() {
echo "*********** Memory Usage ****************"
if [[ ! -z $USER ]] && [[ ! -z $HOST ]] 
	then
ssh $USER@$HOST <<EOF
ps axo %mem,comm,pid,euser | sort -nr | head -n $MAX_RESULTS
EOF
else
	ps axo %mem,comm,pid,euser | sort -nr | head -n $MAX_RESULTS
fi	
}

install_package() {
if ! which $1 >/dev/null; then
	PKG_MANAGER=$( command -v  yum || command -v apt-get ) || echo "Neither yum nor apt-get found"
	sudo $PKG_MANAGER install -y $1
fi
}


#disk_io_without_iotop() {
# Read info from /proc/<pid>/io

# get the difference of rchar,wchar between some interval and sort them

# Get process based on pid

# Print top 10
#}

print_top_n_disk_io_consumers() {
echo "*********** Disk I/O Usage ****************"

if [[ ! -z $USER ]] && [[ ! -z $HOST ]] 
	then
	ssh -tq $USER@$HOST "
if ! which iotop >/dev/null; then 
	PKG_MANAGER=\$( command -v  yum || command -v apt-get ) || echo \"Neither yum nor apt-get found\" 
	sudo \$PKG_MANAGER install -y iotop 
	exit
fi "
ssh  -t $USER@$HOST "sudo iotop -kqP | head -n $((MAX_RESULTS+3)) | tail -$((MAX_RESULTS+1))"
else
	install_package iotop
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
