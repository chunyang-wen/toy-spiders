#!/bin/bash

# Used to download PDF files from http://www.allitebooks.com/

function Notice() {
	# Green
	echo -e "[\e[32mNOTICE\e[0m] $@"
}

function Error() {
	# Red
	echo -e "[\e[31mERROR\e[0m] $@"
}

function Warn() {
	# Yellow
	echo -e "[\e[33mWARN\e[0m] $@"
}

echo "============================================"
Notice "`date +%m-%d\ %H:%M` Update starts."

Domain="http://www.allitebooks.com/"
Catergory=$1
SubCategory=$2

Prefix="${Domain}/${Catergory}/${SubCategory}/page/"

# PageLimit means pages need to wget of each category
# It can be set to a large number, program will terminate when wget meets error.
PageLimit=10000
SleepGap=1s # for avoiding being forbidden.

TempFiles=`pwd`"/${Catergory}/${SubCategory}/tempfiles/" # store temporary files
PDFFolder=`pwd`"/${Catergory}/${SubCategory}/PDFFiles/"  # store pdf files

# Used to track all books downloaded.
BooksCollection=`pwd`"/Books"
BooksCollectionFailed=`pwd`"/BooksFailed"

# TargetDir: Directory to move pdfs when storage is not enough.
# !Note!: It is the final folder we store pdf files.
# Currently, we use count of books to decide whether a move is needed.
Count=0
MoveLimit=10
TargetDir="/home/yang/computer/PDFFilesAllUpdated/${Catergory}/${SubCategory}/`date +%Y%m%d`/"

# For incremental updates
UpdateEnd=0

mkdir -p ${TempFiles}
mkdir -p ${PDFFolder}
mkdir -p ${TargetDir}

# clear update
echo "" > "${BooksCollection}Updated"
echo "" > "${BooksCollectionFailed}Updated"

for i in `seq 1 $PageLimit`
do
	File="${TempFiles}/page${i}.html.tmp"
	URL="${TempFiles}/page${i}.html.URL.tmp"
	wget -q "${Prefix}/${i}" -O ${File}
	if [ $? -ne 0 ]
	then
		Notice "Analyze meets end"
		break
	fi
	if [ ${UpdateEnd} -ne 0 ]
	then
		Notice "Already download for ${FileName%.pdf}"
		Notice "No more new books"
		break
	fi
	awk '$0~/entry-title/ && $0!~/--/' ${File} | awk -vFS='"' '{print $4}' > ${URL}
	Notice "Founding URL Number = `wc -l ${URL}|awk '{print $1}'` on Page ${i}"
	while read url
	do
		sleep ${SleepGap}
		Notice "Processing: ${url}"
		Name=`basename ${url}`
		URLTemp="${TempFiles}/${Name}.txt.tmp"
		wget -q ${url} -O ${URLTemp}
		DownloadURL=$(awk -vFS='"' '$0~/\.pdf/{print $2}' ${URLTemp})
		Notice "Retrive download URL: ${DownloadURL}"
		FileName=`basename "${DownloadURL}"`

		# for incremental update
		LastBookSuc=`tail -1 ${BooksCollection}`
		LastBookFailed=`tail -1 ${BooksCollectionFailed}`
		if [ "${FileName%.pdf}" = "${LastBookFailed}" -o "${FileName%.pdf}" = "${LastBookSuc}" ]
		then
			UpdateEnd=1
			break
		fi
		#grep -P "^${FileName%.pdf}$" "${BooksCollection}" &>/dev/null && UpdateEnd=1 && break
		#[ ${UpdateEnd} -eq 0 ] && grep -P "^${FileName%.pdf}$" ${BooksCollectionFailed} &>/dev/null && UpdateEnd=1 && break

		Notice "Downloading ${FileName}"
		sleep ${SleepGap}
		wget -q "${DownloadURL}" -O "${PDFFolder}/${FileName}"
		if [ $? -ne 0 ]
		then
			Warn "Downloading ${FileName} Failed"
			#echo ${FileName%.pdf} >> "${BooksCollectionFailed}Updated"
			sed -i '1i '"${FileName%.pdf}"'' "${BooksCollectionFailed}Updated"
			rm -rf "${PDFFolder}/${FileName}"
		else

			#echo ${FileName%.pdf} >> "${BooksCollection}Updated"
			sed -i '1i '"${FileName%.pdf}"'' "${BooksCollection}Updated"
		fi
		((Count++))
		if [ ${Count} -eq ${MoveLimit} ]
		then
			Notice "Moving files to Disk"
			mkdir -p ${TargetDir}
			rename -f 's/ /-/g' ${PDFFolder}/*.pdf
			find ${PDFFolder} -name "*.pdf" -exec sed -i '/allitebooks/d' {} \;
			mv ${PDFFolder}/*.pdf ${TargetDir}
			((Count=0))
		fi
	done < ${URL}
	rm -rf "${TempFiles}/*.tmp"

	Notice "Download Page ${i} end"
	sleep ${SleepGap}
done

rename -f 's/ /-/g' ${PDFFolder}/*.pdf
if [ `ls ${PDFFolder} | wc -l` -ne 0 ]
then
	find ${PDFFolder} -name "*.pdf" -exec sed -i '/allitebooks/d' {} \;
	mv ${PDFFolder}/*.pdf ${TargetDir}
fi


# Try to upload files to baidu yun
set -e

YunFolder="PDFFiles/"
#python -m bypy -v mkdir ${YunFolder}

for i in `ls ${TargetDir}`
do
	Notice "`date +%H:%M`: Uploading ${i} start."
	python -m bypy upload ${TargetDir}"/"${i} ${YunFolder}
	if [ $? -ne 0 ]
	then
		Error "`date +%H:%M`: Uploading ${i} failed."
	else
		Notice "`date +%H:%M`: Uploading ${i} successfully."
	fi

done

# Garbage collection
rm -rf ${TempFiles}
rm -rf ${PDFFolder}

# clean update folders
sed -i '/^$/d' "${BooksCollection}Updated"
sed -i '/^$/d' "${BooksCollectionFailed}Updated"

if [ `ls ${TargetDir} | wc -l` -eq 0 ]
then
	# No updates, remove folder
	Notice "No updates"
	rm -rf ${TargetDir}
fi
Notice "`date +%H:%M`: Send mail starts"
TryLimit=3
Tries=$TryLimit
while [ $Tries -gt 0 ]
do
	sh report.sh
	if [ $? -eq 0 ]
	then
		break
	else
		Warn "Sending failed, retry later"
	fi
	sleep 30s
	((Tries-=1))
done

Notice "`date +%H:%M`: Send mail ends, tries before success: $((TryLimit-Tries))"

cat "${BooksCollection}Updated" >> "${BooksCollection}"
cat "${BooksCollectionFailed}Updated" >> "${BooksCollectionFailed}"

Notice "`date +%m-%d\ %H:%M`  Update ends."
echo "============================================"


