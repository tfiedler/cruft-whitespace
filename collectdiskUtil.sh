#!/bin/bash
#set -x

Period=60 #seconds
count=0
DISK=$1

while (:)
do
    # Collection #1
    diskActivRunLenTime1=`grep ${DISK} /proc/diskstats | awk '{print $13}'`

    # hang for $Period seconds. Might not always be n seconds, but
    # its close enough...
    sleep ${Period} # close enough

    # Collection #2
    diskActivRunLenTime2=`grep ${DISK} /proc/diskstats | awk '{print $13}'`

    # Math
    DiskBlkioTicks=$((${diskActivRunLenTime2}-${diskActivRunLenTime1}))

    # More math
    DiskActivitybusy=`echo "($DiskBlkioTicks/(${Period}*1000)) * 100" | bc -l`

    # Iterations
    count=$(($count+1))

    # ... and results
    printf "${count} ${DISK} %0.2f\n" $DiskActivitybusy
done




