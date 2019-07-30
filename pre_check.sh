#!/bin/sh

<< ////
 This script validates wheather system has required  Ram,Cpus and Disk space when executed.
////

echo "Minimum requirements:
         Ram: 24000 MB
         Cpus: 48
         Disk Space: 500000 MB"

memory=$(free -g | awk 'NR==2{printf "%s\n", $4 }')
cpu=$(grep -c ^processor /proc/cpuinfo)
all_disks=$(lsblk | awk '$6=="disk"' | awk '{print $1}' | grep ^sd[a-z])

sum=0
for line in $all_disks;do
	partions=$(lsblk | grep $line | awk '$6=="part"' | awk '{print $1}' | cut -c 3-)
	if [ -z "$partions" ]
	then
		units=$(df-h | grep $line | head -n 1 | awk '{print $4}' | tail -c 2)
		size=$(df -h | grep $line | head -n 1 | awk '{print $4}')
	   if [ -z "$units" ]
	   then
		if [ $units == "T" ];then
                        conversion=$((size * 1000000))
                fi
                if [ $units == "G" ];then
                        conversion=$((size * 1000))
                fi
                if [ $units == "M" ];then
                	conversion=$((size))
                fi
	   fi
      		sum=$((sum + conversion))
	else
		size_part=0
        	for each in $partions;do
			unit=$(df -h | grep $each | head -n 1 | awk '{print $4}' | tail -c 2)
			size_part=$(df -h | grep $each | head -n 1 | awk '{print $4}' | rev | cut -c 2- | rev)
                    if [ ! -z "$unit" ]
		    then
			if [ $unit == "T" ];then
		                convert=$((size_part * 1000000))
       			fi
			if [ $unit == "G" ];then
                                convert=$((size_part * 1000))
                        fi

        		if [ $unit == "M" ];then
                		convert=$((size_part))
        		fi

                	sum=$((sum + convert))
		   fi
       	        done
	fi
done

echo "System has:"
echo "	Avail Ram : $memory MB"
echo "	Avail Cpus : $cpu"
echo "	Avail Disk Space: $sum MB"

if [[ ( $memory -le 24000 ) && ( $cpu -le 48 ) && ( $sum -le 500000)  ]];then
        echo "Minimum requirements not satisfied "
        exit 1
else
        echo "Minimum requiremets satisfied"
fi


