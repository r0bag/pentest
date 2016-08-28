#!/bin/bash
declare IP_RANGE;
declare SCAN_NAME;

echo "Running an Nmap ping sweep for live hosts."
echo "Give me the name of the scan: "
read SCAN_NAME
echo "Input the IP range: "
read IP_RANGE
nmap -v -n -sn -PE -PP -PS21,22,23,25,80,113,31339 -PA80,113,443,10042 --source-port 53 -T4 $IP_RANGE -oG $SCAN_NAME

echo "These host(s) is/are alive: "

cat $SCAN_NAME | grep "()" | grep -i UP | cut -d " " -f2 | sort -R > ${SCAN_NAME}_UP

cat ${SCAN_NAME}_UP


