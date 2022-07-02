#!/bin/bash
sleep 10
apt update
apt install -y python

DATEDIR=`date "+%y%m%d_%H%M%S"`
YCSB_HOME=/local/ycsb
YCSB_RESULTS=${YCSB_HOME}/results
OPSCOUNT=1000000
RECCOUNT=1000000

mkdir -p ${YCSB_RESULTS}/${DATEDIR}

${YCSB_HOME}/bin/ycsb load mongodb-async -s -P ${YCSB_HOME}/workloads/workloada -p operationcount=${OPSCOUNT} -p recordcount=${RECCOUNT} -p mongodb.url=mongodb://mongodbnode0:27017/ycsb?w=0 > ${YCSB_RESULTS}/${DATEDIR}/outputLoada.txt
${YCSB_HOME}/bin/ycsb run mongodb-async -s -P ${YCSB_HOME}/workloads/workloada -p operationcount=${OPSCOUNT} -p recordcount=${RECCOUNT} -p mongodb.url=mongodb://mongodbnode0:27017/ycsb?w=0 > ${YCSB_RESULTS}/${DATEDIR}/outputRuna.txt

${YCSB_HOME}/bin/ycsb load mongodb-async -s -P ${YCSB_HOME}/workloads/workloadb -p operationcount=${OPSCOUNT} -p recordcount=${RECCOUNT} -p mongodb.url=mongodb://mongodbnode0:27017/ycsb?w=0 > ${YCSB_RESULTS}/${DATEDIR}/outputLoadb.txt
${YCSB_HOME}/bin/ycsb run mongodb-async -s -P ${YCSB_HOME}/workloads/workloadb -p operationcount=${OPSCOUNT} -p recordcount=${RECCOUNT} -p mongodb.url=mongodb://mongodbnode0:27017/ycsb?w=0 > ${YCSB_RESULTS}/${DATEDIR}/outputRunb.txt

${YCSB_HOME}/bin/ycsb load mongodb-async -s -P ${YCSB_HOME}/workloads/workloadc -p operationcount=${OPSCOUNT} -p recordcount=${RECCOUNT} -p mongodb.url=mongodb://mongodbnode0:27017/ycsb?w=0 > ${YCSB_RESULTS}/${DATEDIR}/outputLoadc.txt
${YCSB_HOME}/bin/ycsb run mongodb-async -s -P ${YCSB_HOME}/workloads/workloadc -p operationcount=${OPSCOUNT} -p recordcount=${RECCOUNT} -p mongodb.url=mongodb://mongodbnode0:27017/ycsb?w=0 > ${YCSB_RESULTS}/${DATEDIR}/outputRunc.txt

${YCSB_HOME}/bin/ycsb load mongodb-async -s -P ${YCSB_HOME}/workloads/workloadd -p operationcount=${OPSCOUNT} -p recordcount=${RECCOUNT} -p mongodb.url=mongodb://mongodbnode0:27017/ycsb?w=0 > ${YCSB_RESULTS}/${DATEDIR}/outputLoadd.txt
${YCSB_HOME}/bin/ycsb run mongodb-async -s -P ${YCSB_HOME}/workloads/workloadd -p operationcount=${OPSCOUNT} -p recordcount=${RECCOUNT} -p mongodb.url=mongodb://mongodbnode0:27017/ycsb?w=0 > ${YCSB_RESULTS}/${DATEDIR}/outputRund.txt

${YCSB_HOME}/bin/ycsb load mongodb-async -s -P ${YCSB_HOME}/workloads/workloade -p operationcount=${OPSCOUNT} -p recordcount=${RECCOUNT} -p mongodb.url=mongodb://mongodbnode0:27017/ycsb?w=0 > ${YCSB_RESULTS}/${DATEDIR}/outputLoade.txt
${YCSB_HOME}/bin/ycsb run mongodb-async -s -P ${YCSB_HOME}/workloads/workloade -p operationcount=${OPSCOUNT} -p recordcount=${RECCOUNT} -p mongodb.url=mongodb://mongodbnode0:27017/ycsb?w=0 > ${YCSB_RESULTS}/${DATEDIR}/outputRune.txt

${YCSB_HOME}/bin/ycsb load mongodb-async -s -P ${YCSB_HOME}/workloads/workloadf -p operationcount=${OPSCOUNT} -p recordcount=${RECCOUNT} -p mongodb.url=mongodb://mongodbnode0:27017/ycsb?w=0 > ${YCSB_RESULTS}/${DATEDIR}/outputLoadf.txt
${YCSB_HOME}/bin/ycsb run mongodb-async -s -P ${YCSB_HOME}/workloads/workloadf -p operationcount=${OPSCOUNT} -p recordcount=${RECCOUNT} -p mongodb.url=mongodb://mongodbnode0:27017/ycsb?w=0 > ${YCSB_RESULTS}/${DATEDIR}/outputRunf.txt