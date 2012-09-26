#!/bin/bash

tput clear

HOST=$1
BLACKHOLE=/dev/null
CNT=0

while :
do
    unset RC

    CNT=$(($CNT+1))

    ping -c1 -w2 ${HOST} >${BLACKHOLE} 2>&1
    RC=$?

    sleep 1

    if [ ${CNT} -eq 60 ]; then
        echo "$(date) RC = ${RC}"
        CNT=0
    fi
  
    if [ ${RC} -gt 0 ]; then
	echo "$(date) ping failed RC = ${RC}"
        sleep 1
       CNT=0 
    fi
done
