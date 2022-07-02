#!/bin/bash
echo `date`
for i in {0..99}
do
  echo ${i}
  echo `date`
  /usr/bin/mpirun -np 32 -npernode 8 --oversubscribe --mca oob_tcp_if_include 192.168.10.0/24 --mca btl_tcp_if_include 192.168.10.0/24 --mca oob tcp --hostfile /home/mpiuser/hostfile /home/mpiuser/hpcc/hpcc
  mv hpccoutf.txt results/hpccoutf${i}.txt
  sleep 5
done