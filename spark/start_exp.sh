#!/bin/bash
# Run from spark-master
for i in {0..9}
  do
    echo `date`
    echo "$i"
    /bin/bash /hibench/bin/run_all.sh
  done