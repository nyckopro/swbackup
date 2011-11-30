#!/bin/bash
# @author	Nicolas Escobar a.k.a nycko
# @mail		nyckopro [at] gmail [dot] com
# @license	GNU/GPL

PATH_FTP="/tmp";
PATH_SCRIPT="./scripts";

DATE=$(date +%H%M_%d-%m);
HOUR=$(date +%H);
MIN=$(date +%M);
DAY=$(date +%u);
FILECONF="switchs.list";

if [ ! -f "$FILECONF" ];then
	echo "$FILECONF not found, creanding...";
	echo "#IP:community" >> $FILECONF
	exit;
fi

if [ ! -d "$PATH_SCRIPT" ];then
	echo "$PATH_SCRIPT not found, creanding...";
	mkdir $PATH_SCRIPT;
	exit;
fi

DATAs=$(cat switchs.list | egrep -v "^#");

for DATA in $DATAs; do 
	IP=$(echo $DATA | awk -F \: '{print $1}');
	COMM=$(echo $DATA | awk -F \: '{print $2}');

	TYPESW=$(snmpwalk -Cc -Os -v1 -c $COMM $IP sysObjectID 2>/dev/null| awk '{print $4}');
		
	echo -en "Backup $IP ...";
	case $TYPESW in
		"enterprises.2011.10.1.43") $PATH_SCRIPT/huawei5624.exp $IP $DATE > /dev/null
				FILE=""$PATH_FTP"/"$IP"_"$DATE".cfg";
				;;
	       	"enterprises.2011.10.1.200" | "enterprises.2011.10.1.13" | "enterprises.2011.10.1.10")	$PATH_SCRIPT/huawei3928.exp $IP $DATE >/dev/null
				FILE=""$PATH_FTP"/"$IP"_"$DATE".cfg";
				;;
		"enterprises.9.1.696"|"enterprises.9.1.428"|"enterprises.9.1.324" )	$PATH_SCRIPT/cisco.exp $IP $DATE >/dev/null 
				FILE=""$PATH_FTP"/"$IP"_"$DATE"-startup-config.txt";
				;;
		"enterprises.9.1.516" )	$PATH_SCRIPT/cisco3750.exp $IP $DATE >/dev/null 
				FILE=""$PATH_FTP"/"$IP"_"$DATE"-startup-config.txt";
				;;
		"enterprises.43.10.27.4.1.2.11" | "enterprises.43.10.27.4.1.2.2") $PATH_SCRIPT/3com4226.sh $IP $DATE $COMM >/dev/null
				FILE=""$PATH_FTP"/"$IP"_"$DATE".txt";
				;;
		"enterprises.43.1.16.4.3.44" | "enterprises.43.1.16.4.3.77")	$PATH_SCRIPT/3com4210.exp $IP $DATE>/dev/null
				FILE=""$PATH_FTP"/"$IP"_"$DATE".cfg";
				;;
		*	)	
				CHECKALIVE=$(fping $IP 2> /dev/null | awk '{print $3}');
				

				if [ "$CHECKALIVE" == "alive" ];then

					if [ "$TYPESW" == "" ];then	
						echo "NO SNMP";
					else
						echo -en "Error: Tipo de SW no soportado [$TYPESW]\t";
						echo -e "\033[$((100+4))G \033[1;34;40m[\033[1;37;40mFAIL\033[1;34;40m]\033[1;37;40m\033[1;0m";
					fi

				else
					echo "unreachable";
				fi
				continue;
				;;
	esac
	
	sleep 5;	
	if [ -f "$FILE" ];then
		echo -e "\033[$((100+4))G \033[1;34;40m[\033[1;37;40mDONE\033[1;34;40m]\033[1;37;40m\033[1;0m";
	else
		echo -e "\033[$((100+4))G \033[1;34;40m[\033[1;37;40mFAIL\033[1;34;40m]\033[1;37;40m\033[1;0m";
	fi

done
