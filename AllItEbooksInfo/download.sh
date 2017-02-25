#!/bin/sh
# Author: Chunyang Wen(chunyang.wen@gmail.com)

# Used to download PDF files from http://www.allitebooks.com/

Domain="http://www.allitebooks.com/"
# If Category and SubCategory is Empty, we try to download all books.
# Category and SubCategory can be get from the homepage. Be smart and find them yourself.
Catergory="programming"
SubCategory="c"

Prefix="${Domain}/${Catergory}/${SubCategory}/page/"

# PageLimit means pages need to wget of each category
# It can be set to a large number, program will terminate when wget meets error.
PageLimit=1000
SleepGap=1s # for avoiding being forbidden.

TempFiles=`pwd`"/${Catergory}/${SubCategory}/tempfiles/" # store temporary files
PDFFolder=`pwd`"/${Catergory}/${SubCategory}/PDFFiles/"  # store pdf files

# Used to track all books downloaded.
BooksCollection="Books"
BooksCollectionFailed="BooksFailed"

# TargetDir: Directory to move pdfs when storage is not enough.
# !Note!: It is the final folder we store pdf files.
# Currently, we use count of books to decide whether a move is needed.
Count=0
MoveLimit=10
TargetDir="/home/yang/computer/PDFFiles/${Catergory}/${SubCategory}/"

mkdir -p ${TempFiles}
mkdir -p ${PDFFolder}
mkdir -p ${TargetDir}

for i in `seq 1 $PageLimit`
do
	File="${TempFiles}/page${i}.html.tmp"
	URL="${TempFiles}/page${i}.html.URL.tmp"
	wget -q "${Prefix}/${i}" -O ${File}
	if [ $? != 0 ]
	then
		echo "[Notice] Analyze meets end"
		break
	fi
	awk '$0~/entry-title/ && $0!~/--/' ${File} | awk -vFS='"' '{print $4}' > ${URL}
	echo "[Notice] Founding URL Number = `wc -l ${URL}|awk '{print $1}'` on Page ${i}"
	while read url
	do
		sleep ${SleepGap}
		echo "[Notice] Processing: ${url}"
		Name=`basename ${url}`
		URLTemp="${TempFiles}/${Name}.txt.tmp"
		wget -q ${url} -O ${URLTemp}
		DownloadURL=$(awk -vFS='"' '$0~/\.pdf/{print $2}' ${URLTemp})
		echo "[Notice] Retrive download URL: ${DownloadURL}"
		sleep ${SleepGap}
		FileName=`basename "${DownloadURL}"`
		echo "[Notice] Downloading ${FileName}"
		wget -q "${DownloadURL}" -O "${PDFFolder}/${FileName}"
		if [ $? -ne 0 ]
		then
			echo "[Error] Downloading ${FileName}"
			echo ${FileName%.pdf} >> ${BooksCollectionFailed}

		else
			echo ${FileName%.pdf} >> ${BooksCollection}
		fi
		((Count++))
		if [ ${Count} -eq ${MoveLimit} ]
		then
			echo "[Notice] Moving files to Disk"
			mkdir -p ${TargetDir}
			rename -f 's/ /-/g' ${PDFFolder}/*.pdf
			mv ${PDFFolder}/*.pdf ${TargetDir}
			((Count=0))
		fi
	done < ${URL}
	rm -rf "${TempFiles}/*.tmp"

	echo "[Notice] Download Page ${i} end"
	sleep ${SleepGap}
done

rename -f 's/ /-/g' ${PDFFolder}/*.pdf
if [ `ls ${PDFFolder} | wc -l` -ne 0 ]
then
	mv ${PDFFolder}/*.pdf ${TargetDir}
fi

# Garbage collection
rm -rf ${TempFiles}
rm -rf ${PDFFolder}


