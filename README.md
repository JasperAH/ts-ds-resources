# This Repository

Resources to aid in reproducibility for "The Performance of Distributed Applications: A Traffic Shaping Perspective".

# Folders

| **Folder**    | **Contents**                                                     |
|---------------|------------------------------------------------------------------|
| Graphs        | Scripts for generating graphs and tables from experiment results |
| Iperf3        | Docker-compose files and interference traffic generator.         |
| MongoDB       | Docker-compose files for MongoDB and YCSB                        |
| MPI           | Dockerfile and docker-compose file for setting up MPI            |
| Spark         | Docker-compose file and HiBench configurations                   |
| Switch-config | Switch configuration settings                                    |

# Other files
These are files to build the disk image, with services to be setup (docker, consul, ...) as well as cronjobs and startup files.

# Usage
Use the `.service` files as guidelines, some edits (e.g. IP addresses) may be needed. This also holds for the `docker` related files, which additionally may contain template fields. `ovs_setup_pointers.txt` may provide additional information in case setting up OVS in tandem with docker/consul/overlay driver causes issues.
- Use `consul.service` to setup Consul on one node.
- Use `docker.service` to setup Docker on all nodes.
- Use `ovn-docker-overlay-driver.service` to setup the [overlay driver](https://github.com/shettyg/ovn-docker/blob/master/ovn-docker-overlay-driver)
  - ln 86-87: add .detach() before .strip('"')
  - ln 269: add .detach() after ret
- The `Iperf3`, `MongoDB`, `MPI` and `Spark` folders contain `docker` related files for setting up these respective applications on OVS.
- The `Graphs` folder contains scripts for generating graphs from obtained results
- The `Switch-config` folder contains configurations for (virtual)network switches
