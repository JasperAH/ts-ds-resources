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


ports=""

for (( i=0; i <${#containers[@]}; i++ ))
do

    otherports=""
    for (( j=0; j < ${#containers[@]}; j++ ))
    do
        if [ "${containers[$i]}" != "${containers[$j]}" ]; then
            otherports="${containers[$j]},${otherports}"
        fi
    done
    otherports="${otherports}${eno50}"
	
	if [ `expr ${containers[$i]} % 2` == 0 ]
	then
		/usr/bin/ovs-ofctl add-flow br-int dl_type=0x0806,in_port=${containers[$i]},actions=${otherports}
		/usr/bin/ovs-ofctl add-flow br-int dl_type=0x0800,in_port=${containers[$i]},actions=${otherports},set_field:10\-\>ip_dscp
	else
		/usr/bin/ovs-ofctl add-flow br-int dl_type=0x0806,in_port=${containers[$i]},actions=${otherports}
		/usr/bin/ovs-ofctl add-flow br-int dl_type=0x0800,in_port=${containers[$i]},actions=${otherports},set_field:38\-\>ip_dscp
	fi

    #/usr/bin/ovs-ofctl add-flow br-int dl_type=0x0800,in_port=${containers[$i]},actions=${otherports}

    ports="${containers[$i]},${ports}"
done

if [ "${ports}" != "" ]; then
    ports=${ports::-1}
	/usr/bin/ovs-ofctl add-flow br-int dl_type=0x0806,in_port=${eno50},actions=${ports}
    /usr/bin/ovs-ofctl add-flow br-int dl_type=0x0800,in_port=${eno50},actions=${ports},set_field:10\-\>ip_dscp
fi