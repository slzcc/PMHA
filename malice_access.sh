#!/bin/bash

workDir="/root"
project="PMHA"

HostIP="101.200.83.130"

CapFile="/tmp/`date +%F:%H:%M.cap`"
ReIPFile="/tmp/`date +%F:%H:%M`_ReIPList.txt"

tcpdump -i eth1 -nn host ${HostIP} and ! port 22 and ! icmp -c 2000  >>  ${CapFile}

cat ${CapFile} | grep '\[S\]'  | awk '{print $3}'| awk -F. 'OFS="."{$NF="";print}'|sed 's/\.$//' | egrep "^([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$" | sort|uniq -d -c > ${ReIPFile}

cat ${ReIPFile} | while read line  ; do
  if [[ `echo $line | awk '{print $1}'` -ge 20 ]]; then
    echo $line | awk '{print $2}' >> ${workDir}/${project}/.new_ip_list.txt;
  fi;
done
rm -rf ${CapFile}
cat ${workDir}/${project}/.new_ip_list.txt | sort | uniq > ${workDir}/${project}/black_list.txt
