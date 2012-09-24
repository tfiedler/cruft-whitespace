#!/bin/bash
# NumHP.sh - returns values necessary for setting up hugepages in Linux
# Always test the sanity of these values as you would any other
# system setting. 

# Debugging
#set -x
#set -v

# general usage
set noclobber

HPG_SZ=`grep Hugepagesize /proc/meminfo | awk '{print $2}'`
KERN=`uname -r | awk -F. '{ printf("%d.%d\n",$1,$2); }'`
TM=`grep MemTotal /proc/meminfo | awk '{print $2}'`     

if [ ! -z $1 ]; then
    echo -n "Enter the size in GB you would like reserved for HugePages: "
    read a
    GB=${a}
else
    GB=$1
fi

echo -n "Assume memory in GB (Enter for real memory): "
read a
if [ -z $a ]; then
    TM=${TM}
else
    TM=`echo "$a * 1048567" | bc -q`
fi

# GB converted to B
B=`echo "${GB}*1073741824" | bc -q`

if [ $TM -gt "30000000" ]; then
    #4GB
    MEMLOCK_REDUCE="4194304"
elif [ $TM -gt "14000000" ]; then
    #2GB
    MEMLOCK_REDUCE="2097152"
else 
    #1GB
    MEMLOCK_REDUCE="1048576"
fi

# There is no harm in setting this high
MEMLOCK_SZ=`echo "${TM}-${MEMLOCK_REDUCE}" | bc -q`

if [ ! ${KERN} = "2.6" ]; then
    echo "Kernel version seems to be wrong."
else
    NumHP=`echo "${B}/($HPG_SZ*1024)" | bc -q`
    echo "change vm.nr_hugepages /etc/sysctl.conf to: "
    echo "vm.nr_hugepages = ${NumHP}"
    echo ""
    echo "modify /etc/security/limits.conf: "
    echo "oracle hard memlock ${MEMLOCK_SZ}"
    echo "oracle soft memlock ${MEMLOCK_SZ}"
fi
