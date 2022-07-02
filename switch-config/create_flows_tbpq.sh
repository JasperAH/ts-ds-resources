#!/bin/bash

eno50=`ovs-ofctl show br-int | grep addr | grep -v -e "LOCAL" -e "ovn" | grep -e "eno50" | grep -oP "([0-9]+)\(" | grep -oP "[0-9]+"`
containers=`ovs-ofctl show br-int | grep addr | grep -v -e "LOCAL" -e "ovn" -e "eno50" | grep -oP "([0-9]+)\(" | grep -oP "[0-9]+"`
contids=`ovs-ofctl show br-int | grep addr | grep -v -e "LOCAL" -e "ovn" -e "eno50" | grep -oP "([0-9]+)\(([0-9]|[a-z])+" | grep -oP "[0-9]+\(\K.*"`

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

    ports="${containers[$i]},${ports}"
done

if [ "${ports}" != "" ]; then
    ports=${ports::-1}
	/usr/bin/ovs-ofctl add-flow br-int dl_type=0x0806,in_port=${eno50},actions=${ports}
    /usr/bin/ovs-ofctl add-flow br-int dl_type=0x0800,in_port=${eno50},actions=${ports},set_field:10\-\>ip_dscp
fi

# $ ovs-vsctl set interface tap1 ingress_policing_rate=10000
# $ ovs-vsctl set interface tap1 ingress_policing_burst=1000
# rate in Kbps
rate=1000000
# burst in Kb
burst=100000


for (( i=0; i <${#contids[@]}; i++ ))
do
	/usr/bin/ovs-vsctl set interface ${contids[$i]} ingress_policing_rate=${rate}
	/usr/bin/ovs-vsctl set interface ${contids[$i]} ingress_policing_burst=${burst}
done