#!py -2
#!/bin/python2.7
# You can execute the scripts on CLI to get an idea of output without needing to run on node
"""Create nodes & auto-add to switch with /24 IP address. Nodes are defined by a (custom) disk image. Allows for executing commands on node and extraction of url-based packages. 

Instructions:
- Select switch type (dell recommended -- it allows for more precise QoS numbers).
- Select number of desired nodes.

Edit nodes via the script. Disk image can be modified, and commands/scripts/downloadable extractables can be added, as shown in the `Nodes` block.

**NOTE** Support for large number of nodes is t.b.d. as of yet, as switches generally have a limited number of ports (but this cap is not specified nor enforced).
"""
############# Imports #############

# Import the Portal object.
import geni.portal as portal
# Import the ProtoGENI library.
import geni.rspec.pg as rspec
# Import the Emulab specific extensions.
import geni.rspec.emulab as emulab

############# Globals #############

ip_addresses = ["192.168.1."+str(x) for x in range(1,255)]
ip_addresses_control = ["10.10.10."+str(x) for x in range(1,255)]
ip_subnet_mask = "255.255.255.0"

node_interfaces = []

############## Init ###############

# Create a Request object to start building the RSpec.
request = portal.context.makeRequestRSpec()

portal.context.defineParameter("switchtype", "Switch type",
                   portal.ParameterType.STRING, "dell-s4048",
                   [('mlnx-sn2410', 'Mellanox SN2410'),
                    ('dell-s4048',  'Dell S4048')])

portal.context.defineParameter("n_nodes", "Number of nodes", portal.ParameterType.INTEGER, 1, [x for x in range(1,250)])

experiments = ["", "MongoDB", "Spark", "MPI"]
portal.context.defineParameter("experiment", "Experiment", portal.ParameterType.STRING, "", experiments)

params = portal.context.bindParameters()

############# Nodes #############
# disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU20-64-STD"
#disk_image = "urn:publicid:IDN+utah.cloudlab.us+image+sched-serv-PG0:dockersetup_flows";
#disk_image = "urn:publicid:IDN+utah.cloudlab.us+image+sched-serv-PG0:hibench:2"
#disk_image = "urn:publicid:IDN+utah.cloudlab.us+image+sched-serv-PG0:hibench:3"
disk_image = "urn:publicid:IDN+utah.cloudlab.us+image+sched-serv-PG0:hibench-ovn"
hardware_type = "xl170" #"c6525-25g" # e.g. m400, try xl170 with dell switch?

nodes = []
for i in range(params.n_nodes):
    nodes.append(request.RawPC("node"+str(i)))
    nodes[i].disk_image = disk_image
    bs = nodes[i].Blockstore("bs"+str(i),"/blockstore")
    bs.size = "80GB"
    # nodes[i].hardware_type = hardware_type
    iface = nodes[i].addInterface()
    iface.addAddress(rspec.IPv4Address(ip_addresses[i],ip_subnet_mask))
    node_interfaces.append(iface)

    # Install and execute scripts on the node. THIS TAR FILE DOES NOT ACTUALLY EXIST!
    #nodes[i].addService(rspec.Install(url="http://example.org/sample.tar.gz", path="/local"))
    #nodes[i].addService(rspec.Execute(shell="bash", command="/local/example.sh"))
    # nodes[i].addService(rspec.Execute(shell="bash", command="/usr/sbin/modprobe vfio-pci"))
    # nodes[i].addService(rspec.Execute(shell="bash", command="/usr/local/bin/dpdk-devbind.py --bind=vfio-pci ens1f0"))
    # nodes[i].addService(rspec.Execute(shell="bash", command="/usr/local/bin/dpdk-devbind.py --bind=vfio-pci ens1f1"))

    # nodes[i].addService(rspec.Execute(shell="bash", command="/usr/bin/docker network create -d openvswitch --subnet=192.168.10.0/24 ovs"))


############ Switch #############

switch = request.Switch("switch")
switch.hardware_type = params.switchtype

switch_interfaces = []
# for _ in range(params.n_nodes):
for _ in range(len(node_interfaces)):
    switch_interfaces.append(switch.addInterface())

############# Links #############

links = []
# for i in range(params.n_nodes):
for i in range(len(node_interfaces)):
    link = request.L1Link("link"+str(i))
    link.addInterface(node_interfaces[i])
    link.addInterface(switch_interfaces[i])
    links.append(link)


########## Remote Data ######### 
nfsServerName = "nfs"
nfsLanName    = "nfsLan"
nfsDirectory  = "/nfs"
nfsOsImage = "urn:publicid:IDN+utah.cloudlab.us+image+sched-serv-PG0:write-nfs-chown";

nfsLan = request.LAN(nfsLanName)
nfsLan.best_effort       = True
nfsLan.vlan_tagging      = True
nfsLan.link_multiplexing = True

for i in range(len(node_interfaces)):
    nodeiface = nodes[i].addInterface()
    nodeiface.addAddress(rspec.IPv4Address(ip_addresses_control[i],ip_subnet_mask))
    nfsLan.addInterface(nodeiface)



if(params.experiment == experiments[2] or True):
    nfsServer = request.RawPC(nfsServerName)
    nfsServer.disk_image = nfsOsImage
    nfsIface = nfsServer.addInterface()
    nfsIface.addAddress(rspec.IPv4Address(ip_addresses_control[253],ip_subnet_mask))
    nfsLan.addInterface(nfsIface)

    dsnode = request.RemoteBlockstore("dsnode", nfsDirectory)
    #dsnode.dataset = "urn:publicid:IDN+utah.cloudlab.us:sched-serv-pg0+stdataset+exp-data"
    dsnode.dataset = "urn:publicid:IDN+utah.cloudlab.us:sched-serv-pg0+stdataset+exp_data"
    

    dsnode.addService(rspec.Execute(shell="bash", command="sudo /root/start_nfs.sh"))

    # Link between the nfsServer and the ISCSI device that holds the dataset
    dslink = request.Link("dslink")
    dslink.addInterface(dsnode.interface)
    dslink.addInterface(nfsServer.addInterface())
    # Special attributes for this link that we must use.
    dslink.best_effort = True
    dslink.vlan_tagging = True
    dslink.link_multiplexing = True


########## Experiment ######### 
# This does not work out due to timing issues. crontab @reboot works better

for i in range(len(node_interfaces)):
    nodes[i].addService(rspec.Execute(shell="bash", command="echo \""+params.experiment+"\" > /local/experiment"))
# if(params.experiment == experiments[1] and params.n_nodes == 5):
#     duration = 60 # see how this works with iperf duration
#     # start mongodb containers on nodes 0,1,2
#     for i in range(3):
#         nodes[i].addService(rspec.Execute(shell="bash", command="/usr/sbin/sudo docker-compose -f /root/docker_yml/mongodb/docker-compose.yml up -d"))
    
#     # init cluster
#     nodes[0].addService(rspec.Execute(shell="bash", command="/usr/bin/sudo docker exec mongodb /root/init_replication.sh"))

#     # insert data (needed for update and delete)
#     nodes[3].addService(rspec.Execute(shell="bash", command="java -jar /local/mpt/latest-version/mongodb-performance-test.jar -dropdb -m insert -d 60 -t 10 -db test -c perf -h 192.168.1.1"))

#     # start iperf server on benchmark target server & connect from interference server
#     nodes[0].addService(rspec.Execute(shell="bash", command="iperf3 -s"))
#     nodes[4].addService(rspec.Execute(shell="bash", command="iperf3 -c 192.168.1.1 -b 1000M --bidir -t "+str(duration*1.2)))

#     # execute experiment
#     nodes[3].addService(rspec.Execute(shell="bash", command="rm -f /local/mpt/latest-version/*.csv ; java -jar /local/mpt/latest-version/mongodb-performance-test.jar -m insert update_one delete_one -d "+str(duration)+" -t 10 10 10 -db test -c perf -h 192.168.1.1"))