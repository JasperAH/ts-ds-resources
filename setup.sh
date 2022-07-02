sleep 95
/usr/sbin/modprobe vfio-pci

exp=`cat /local/experiment`
id_file=/etc/openvswitch/system-id.conf
uuidgen > $id_file
ovs-vsctl set Open_vSwitch . external_ids:system-id=$(cat $id_file)


nodename=`geni-get client_id`
sed "s/<containername>/openmpi${nodename}/g" /root/docker_yml/openmpi/docker-compose.yml.template > /root/docker_yml/openmpi/docker-compose.yml

#sed "s/<containername>/spark${nodename}/g" /root/docker_yml/spark/docker-spark/docker-compose-master.yml.template > /root/docker_yml/spark/docker-spark/docker-compose-master.yml
#sed "s/<containername>/spark${nodename}/g" /root/docker_yml/spark/docker-spark/docker-compose-slave.yml.template > /root/docker_yml/spark/docker-spark/docker-compose-slave.yml

sed "s/<containername>/spark${nodename}/g" /root/docker_yml/spark/docker-hadoop-spark/docker-compose-slave.yml.template > /root/docker_yml/spark/docker-hadoop-spark/docker-compose-slave.yml

sed "s/<containername>/mongodb${nodename}/g" /root/docker_yml/mongodb/docker-compose.yml.template > /root/docker_yml/mongodb/docker-compose.yml

sed "s/<containername>/iperf3${nodename}/g" /root/docker_yml/iperf3/docker-compose-client.yml.template > /root/docker_yml/iperf3/docker-compose-client.yml
sed "s/<containername>/iperf3server${nodename}/g" /root/docker_yml/iperf3/docker-compose-server.yml.template > /root/docker_yml/iperf3/docker-compose-server.yml

CENTRAL_IP=10.10.10.1        # never changes, master ip
LOCAL_IP=`ip a | grep -oP "10\.10\.10\.[0-9]+" | grep -P '10.10.10.(?!255)'`
ENCAP_TYPE=geneve

ovs-vsctl set Open_vSwitch . \
    external_ids:ovn-remote="tcp:$CENTRAL_IP:6642" \
    external_ids:ovn-nb="tcp:$CENTRAL_IP:6641" \
    external_ids:ovn-encap-ip="$LOCAL_IP" \
    external_ids:ovn-encap-type="geneve"

sleep 90

cp -r /var/lib/docker /blockstore/
systemctl restart docker
#rm /var/log/ovn/ovn-controller.log
#docker system prune -a
#docker image prune --all



# SYNC BETWEEN NODES
su - JasperAH -c "touch /nfs/sync/${nodename}"
# while (not all nodes present in /nfs/sync): sleep
FILES=(node0 node1 node2)
#FILES=`ls /etc/hosts | grep -e ""`
for file in "${FILES[@]}"
do
  while [ ! -f "/nfs/sync/${file}" ]; do
    sleep 1
  done
  echo "${file} active"
done
# if (all nodes present in /nfs/sync): break & delete files in /nfs/sync
if [[ "$nodename" == "node0"* ]]; then
  su - JasperAH -c "rm /nfs/sync/*"
fi


if [[ "$nodename" == "node0"* ]]; then
  /usr/bin/docker network create -d openvswitch --subnet=192.168.10.0/24 ovs
fi

sleep 5

echo "Experiment: ${exp}"

if [[ "$exp" == "MongoDB" ]]; then
  if [[ "$nodename" == "node0"* ]]; then
    echo "node0: main node"
    /usr/local/bin/docker-compose -f /root/docker_yml/mongodb/docker-compose.yml up -d
    sleep 5
    docker-compose -f /root/docker_yml/iperf3/docker-compose-server.yml up -d
    sleep 10
    /root/create_flows.sh
    sleep 5
    /usr/bin/docker exec -ti mongodbnode0 /root/init_replication.sh
  elif [[ "$nodename" == "node1"* || "$nodename" == "node2"* ]]; then
    echo "node1-2: supplementary nodes"
    /usr/local/bin/docker-compose -f /root/docker_yml/mongodb/docker-compose.yml up -d
    sleep 5
    /root/create_flows.sh
  elif [[ "$nodename" == "node3"* ]]; then
    echo "node3: experiment"
    sleep 40
    echo "start experiment"
    # todo: configure params
    # todo: create docker-compose for this
    #rm -f /local/mpt/latest-version/*.csv ; /usr/bin/docker run --rm -v /local/mpt/latest-version:/local/mpt/latest-version -w /local/mpt/latest-version openjdk:19 java -jar mongodb-performance-test.jar -m insert update_one delete_one -d 60 -t 10 10 10 -db test -c perf -h mongodbnode0
    #su - JasperAH -c "cp /local/mpt/latest-version/*.csv /nfs/results/"
  elif [[ "$nodename" == "node4"* ]]; then
    echo "node4: interference"
    sleep 25
    # pacing timer @ 100ms
    docker-compose -f /root/docker_yml/iperf3/docker-compose-client.yml up -d
    sleep 5
    /root/create_flows.sh
  fi
elif [[ "$exp" == "Spark" ]]; then
  if [[ "$nodename" == "node0"* ]]; then
    echo "node0: main node"
    docker-compose -f /root/docker_yml/spark/docker-spark/docker-compose-master.yml up -d
    sleep 5
    docker-compose -f /root/docker_yml/iperf3/docker-compose-server.yml up -d
    sleep 10
    /root/create_flows.sh
    sleep 15
    # start experiment here in spark-master container
    # TODO
  elif [[ "$nodename" == "node1"* || "$nodename" == "node2"* || "$nodename" == "node3"* ]]; then
    echo "node1-3: supplementary nodes"
    sleep 15
    docker-compose -f /root/docker_yml/spark/docker-spark/docker-compose-slave.yml up -d
    sleep 10
    /root/create_flows.sh
  elif [[ "$nodename" == "node4"* ]]; then
    echo "node4: interference"
    sleep 30
    # pacing timer @ 100ms
    docker-compose -f /root/docker_yml/iperf3/docker-compose-client.yml up -d
    sleep 5
    /root/create_flows.sh
  fi
elif [[ "$exp" == "MPI" ]]; then
  if [[ "$nodename" == "node0"* ]]; then
    echo "node0: main node"
    docker-compose -f /root/docker_yml/openmpi/docker-compose.yml up -d
    sleep 5
    docker-compose -f /root/docker_yml/iperf3/docker-compose-server.yml up -d
    sleep 10
    /root/create_flows.sh
  elif [[ "$nodename" == "node1"* || "$nodename" == "node2"* ]]; then
    echo "node1-2: supplementary nodes"
    docker-compose -f /root/docker_yml/openmpi/docker-compose.yml up -d
    sleep 5
    /root/create_flows.sh
  elif [[ "$nodename" == "node3"* ]]; then
    echo "node3: experiment"
    sleep 25
    # do experiment; TODO (maybe add this to node1/2 and start experiment on node0 locally)
    # sleep 5
    # /root/create_flows.sh
  elif [[ "$nodename" == "node4"* ]]; then
    echo "node4: interference".
    sleep 20
    # pacing timer @ 100ms
    # /usr/bin/iperf3 --pacing-timer 100000 192.168.1.1
    docker-compose -f /root/docker_yml/iperf3/docker-compose-client.yml up -d
    sleep 5
    /root/create_flows.sh
  fi
fi