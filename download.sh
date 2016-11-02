#!/bin/sh -xe
# download data from jiuzhang

# jiuhzhang solutions' url prefix
PREFIX="http://www.jiuzhang.com/solutions/"

# file name to read all problems' names
FILE="leetcode.txt"

# folder to store all the solutions
FOLDER="srcs/"

while read LINE
do
    rm -rf "index.html"
    echo -n "Downloading ${LINE} "
    URL="${PREFIX}/${LINE}"
    wget $URL &>/dev/null
    if [ $? -ne 0 ]; then
        echo "Fail"
        continue
    fi
    echo "Suc"
    mkdir -p "${FOLDER}/${LINE}/"
    OUTPUT=${FOLDER}/${LINE}
    awk -vname=${LINE} -vfolder=$OUTPUT -f parse.awk index.html
    if [ $? -ne 0 ];then
        echo "Maybe no code contained in $URL"
        command rm -rf ${OUTPUT}
        continue
    fi

    # escape HTML transformations
    sed -i 's/&quot;/"/g' ${OUTPUT}/*
    sed -i 's/&lt;/</g' ${OUTPUT}/*
    sed -i 's/&gt;/>/g' ${OUTPUT}/*
    sed -i 's/&amp;/\&/g' ${OUTPUT}/*
    sed -i 's///g' ${OUTPUT}/*
    sed -i 's/<[^>]*>//' ${OUTPUT}/*
    sed -i 's/&#39;/\"/g' ${OUTPUT}/*

    # sleep for a while
    sleep 1s
done < "$FILE"
