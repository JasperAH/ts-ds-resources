#!/bin/bash

eno50=`ovs-ofctl show br-int | grep addr | grep -v -e "LOCAL" -e "ovn" | grep -e "eno50" | grep -oP "([0-9]+)\(" | grep -oP "[0-9]+"`
containers=`ovs-ofctl show br-int | grep addr | grep -v -e "LOCAL" -e "ovn" -e "eno50" | grep -oP "([0-9]+)\(" | grep -oP "[0-9]+"`

IFS2=$IFS
IFS=$'\n'
containers=($containers)
IFS=$IFS2

/usr/bin/ovs-ofctl del-flows br-int in_port=eno50
/usr/bin/ovs-ofctl del-flows br-int out_port=eno50

sleep 5


#echo "eno50: ${eno50}"
ports=""

for (( i=0; i <${#containers[@]}; i++ ))
do
    #echo "container $i: ${containers[$i]}"
    #echo "ovs-ofctl add-flow br-int in_port=${eno50},actions=${containers[$i]}"

    otherports=""
    for (( j=0; j < ${#containers[@]}; j++ ))
    do
        if [ "${containers[$i]}" != "${containers[$j]}" ]; then
            otherports="${containers[$j]},${otherports}"
        fi
    done
    otherports="${otherports}${eno50}"

    #echo "ovs-ofctl add-flow br-int in_port=${containers[$i]},actions=${eno50}"
    /usr/bin/ovs-ofctl add-flow br-int in_port=${containers[$i]},actions=${otherports}

    ports="${containers[$i]},${ports}"
done

if [ "${ports}" != "" ]; then
    ports=${ports::-1}
    /usr/bin/ovs-ofctl add-flow br-int in_port=${eno50},actions=${ports}
fi