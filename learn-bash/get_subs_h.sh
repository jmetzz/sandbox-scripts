#!/bin/bash

function rename_show {
OLD_VALUE=$1
NEW_VALUE=$2
LOCATION=$3

for file in `find "${LOCATION}" -name "*${OLD_VALUE}"`; do
    mv -f "$file" "${file/${OLD_VALUE}/${NEW_VALUE}}"
done
}

function getShowSubs {
SHOW_FOLDER=$1
if [ "$BASE_PATH" = "$SHOW_FOLDER" ]
then 
	SHOW_FOLDER="" 
fi
cd /cygdrive/h/Vroksub/
./VrokSub.exe "$(cygpath -w ${BASE_PATH})${SHOW_FOLDER}" en /newonly 
rename_show ".en.srt" ".srt" "${BASE_PATH}${SHOW_FOLDER}"
echo "Renamed sub for show in folder ${SHOW_FOLDER}."
echo
}

#getShowSubs

OLD_IFS=$IFS
export BASE_PATH=$1


find "$BASE_PATH" -type d -print0 | while IFS= read -r -d $'\0' FOLDER; do
	
	echo "$FOLDER"
	FOLDER_NAME=${FOLDER##$BASE_PATH}
	if [ ! -z "$FOLDER_NAME" ];
	then
		echo "Getting sub for show in folder $BASE_PATH"
		getShowSubs "${FOLDER_NAME}"
	fi	
done


IFS=$OLD_IFS