#!/bin/bash

if [[ ! -f .black_list.txt ]];then cat black_list.txt > .black_list.txt;fi
if [[ ! -f .neglect_list.txt ]];then cat neglect_list.txt > .neglect_list.txt;fi

workDir="/root"
project="PMHA"

whiteList=`cat ${workDir}/${project}/neglect_list.txt | sort | uniq`
old_whiteList=`cat ${workDir}/${project}/.neglect_list.txt | sort | uniq`

blackList=`cat ${workDir}/${project}/black_list.txt | sort | uniq`
old_blackList=`cat ${workDir}/${project}/.black_list.txt | sort | uniq`

BlackIPList=""
WhiteIPList=""
OldBlackIPList=""
OldWhiteIPList=""

AllPorts="0:65535"
IPT="/sbin/iptables"
suffix="(,$)"

for i in ${blackList}; do BlackIPList+="$i",;done && [[ "$BlackIPList" =~ $suffix ]] && BlackIPList=${BlackIPList%?}

for j in ${whiteList}; do WhiteIPList+="$j",;done && [[ "$WhiteIPList" =~ $suffix ]] && WhiteIPList=${WhiteIPList%?}

for k in ${old_blackList}; do OldBlackIPList+="$k",;done && [[ "$OldBlackIPList" =~ $suffix ]] && OldBlackIPList=${OldBlackIPList%?}

for o in ${old_whiteList}; do OldWhiteIPList+="$o",;done && [[ "$OldWhiteIPList" =~ $suffix ]] && OldWhiteIPList=${OldWhiteIPList%?}

if [ "$1" == "start" ]; then
  if [[ -f ~/.pmha_run ]]; then
    bash $0 stop
    rm -rf ~/.pmha_run
  fi
  if [[ `md5sum black_list.txt | awk '{print $1}'` != `md5sum .black_list.txt | awk '{print $1}'` ]] ; then

#    $IPT -t filter -D INPUT -p tcp -s ${OldBlackIPList} --sport ${AllPorts} --dport ${AllPorts} -j DROP
    $IPT -t filter -A INPUT -p tcp -s ${BlackIPList} --sport ${AllPorts} --dport ${AllPorts} -j DROP

    cat black_list.txt > .black_list.txt

  else

    $IPT -t filter -A INPUT -p tcp -s ${BlackIPList} --sport ${AllPorts} --dport ${AllPorts} -j DROP

    cat black_list.txt > .black_list.txt
    touch ~/.pmha_run

  fi

  if [[ `md5sum neglect_list.txt | awk '{print $1}'` != `md5sum .neglect_list.txt | awk '{print $1}'` ]] ; then
    
#    $IPT -t filter -D INPUT -p tcp -s ${OldWhiteIPList} --sport ${AllPorts} --dport ${AllPorts} -j ACCEPT
    $IPT -t filter -A INPUT -p tcp -s ${WhiteIPList} --sport ${AllPorts} --dport ${AllPorts} -j ACCEPT
    cat neglect_list.txt > .neglect_list.txt

  else

    $IPT -t filter -A INPUT -p tcp -s ${WhiteIPList} --sport ${AllPorts} --dport ${AllPorts} -j ACCEPT
    cat neglect_list.txt > .neglect_list.txt
    touch ~/.pmha_run

  fi

elif [ "$1" == "stop" ]; then

  $IPT -t filter -D INPUT -p tcp -s ${OldWhiteIPList} --sport ${AllPorts} --dport ${AllPorts} -j ACCEPT
  $IPT -t filter -D INPUT -p tcp -s ${OldBlackIPList} --sport ${AllPorts} --dport ${AllPorts} -j DROP
  rm -rf ~/.pmha_run

fi
