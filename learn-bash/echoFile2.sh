#!/bin/bash


usage() {
	echo "Usage:"
	echo "    prepareSql [-f] [-t]"
	echo 
	echo "Arguments:"
	echo "    -f  file"
	echo "    -t  type"
}

main() {
	echo "Start sql generation"
	for line in $(tail -n +2 $INPUT | tr '\n\r' ' '); 
	do 
		export C_ID=$(echo $line | cut -d ',' -f 1);
		export A_ID=$(echo $line | cut -d ',' -f 2);
		echo "delete from DB2.CONTACT_ADDRESSES where ADDRESS_TYPE = $TYPE and ADDRESS_ID = $A_ID and COMPANY_ID = $C_ID;" >> delete.sql;
		echo "($TYPE, $A_ID, $C_ID, 'N', 'TEST for OHM-31701', CURRENT TIMESTAMP, 'OHM-31701', CURRENT TIMESTAMP )" >> values.sql;
		printf "."
	done
	print "\n"
	echo "insert into DB2.CONTACT_ADDRESSES (ADDRESS_TYPE, ADDRESS_ID, COMPANY_ID, DEFAULT_ADDRESS, CREATED_BY, CREATE_DATE, CHANGED_BY, CHANGE_DATE) values " >> insert.sql

	echo $(tail values.sql | paste -sd "," - | sed -e 's,)\,,)\,\n\r,gm')  >> insert.sql

	cat delete.sql insert.sql > output.sql
	rm delete.sql
	rm insert.sql
	rm values.sql
	echo "Sql statements saved in file output.sql"
}

if [[ $1 == '--help' ]]
	then
	usage
	exit 0
fi


while [[ $# -gt 0 ]]
do
	key="$1"

	case $key in
	    -f|--file)
	    INPUT="$2"
	    shift
	    ;;
	    -t|--type)
	    TYPE="$2"
	    shift
	    ;;
	esac
	shift
done

main