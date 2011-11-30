#!/bin/bash

SEARCH="ifDescr ifAlias ifOperStatus 1.3.6.1.4.1.43.10.1.14.1.2.1.4 1.3.6.1.4.1.43.10.1.14.1.2.1.2 enterprises.43.10.1.14.1.3.1.6";
IP=$1;
DATE=$2;
COMM=$3

INDEXS=$(snmpwalk -Os -Cc -v1 -c $COMM $IP ifIndex | awk '{print $4}');
echo -e "\tDescription\t\t\tAlias\t\t Status\t    VLAN" > /tmp/"$IP"_"$DATE".txt

for INDEX in $INDEXS; do
   
   for OID in $SEARCH; do
     RES=$(snmpwalk -Os -Cc -v1 -c $COMM $IP $OID.$INDEX | awk -F \: '{print $2}' | tr -d '\n');
     if [ "$RES" == " up(1)" ];then
	echo -e " [ $RES  ]" | tr -d '\n' >> /tmp/"$IP"_"$DATE".txt 
     else
	if [ "$RES" != "" ];then
		echo -e " [$RES ]" | tr -d '\n' >> /tmp/"$IP"_"$DATE".txt 
	fi
     fi
   done 
   
   echo -e "\n" >> /tmp/"$IP"_"$DATE".txt
done

