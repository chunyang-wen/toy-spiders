#!/bin/sh

# Used to download PDF files from http://www.allitebooks.com/


Prefix="http://www.allitebooks.com/programming/c/page/"

PageLimit=1000
MoveLimit=100
Count=0
SleepGap=1s

TempFiles=`pwd`"/tempfiles/"
PDFFolder=`pwd`"/PDFFiles/"
BooksCollection="Books"

mkdir -p ${TempFiles}
mkdir -p ${PDFFolder}

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
		echo ${FileName%.pdf} >> ${BooksCollection}
		echo "[Notice] Downloading ${FileName}"
		wget -q "${DownloadURL}" -O "${PDFFolder}/${FileName}"
		if [ $? -ne 0 ]
		then
			echo "[Error] Downloading ${FileName}"
		fi
		((Count++))
		if [ ${Count} -eq ${MoveLimit} ]
		then
			echo "[Notice] Moving files to Disk"
			TargetDir="/home/yang/computer/PDFFiles/"
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
mv ${PDFFolder}/*.pdf ${TargetDir}

rm -rf ${TempFiles}
rm -rf ${PDFFolder}


