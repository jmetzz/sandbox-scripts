#!/bin/bash

INPUT=$1
echo $INPUT


OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

echo "input file exist"


while read CompanyID AddressID
do
	echo "Company : $CompanyID"
	echo "Address : $AddressID"
done < $INPUT

IFS=$OLDIFS

#addresstype=9999
#ssconvert "${filename}".xls "${filename}".csv 2> /dev/null 


echo "==============="

 tail -n +2 ../output.csv | while IFS=, read CompanyID AddressID; do echo "Company : $CompanyID"; echo "Address : $AddressID"; done


 