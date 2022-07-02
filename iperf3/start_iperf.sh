#!/bin/bash
sleep 10
/usr/bin/apt update
/usr/bin/apt install -y python3 python3-pip git

/usr/bin/python3 -m pip install setuptools
/usr/bin/python3 -m pip install numpy


cd /root
/usr/bin/git clone https://github.com/JasperAH/iperf3-python.git
cd iperf3-python
/usr/bin/python3 setup.py install
cd ..

/usr/bin/python3 /root/iperfnoisepattern.py <iperf3nodeN>

#sleep 10000
#/usr/bin/iperf3 --bidir --pacing-timer 100000 -t 60000 -c iperf3-server