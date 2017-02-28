#!/bin/sh
#Author: Chunyang Wen (chunyang.wen@gmail.com)

# Used to split files in folder to different folders


# each LoopFactor's files will be stored splited into target folder.
Count=0
LoopFactor=500
FolderIndex=0

SrcFolder="/home/yang/computer/PDFFilesAll/"
TargetFolderPrefx="/home/yang/computer/PDFFilesAll/Prefix500_"


for i in `ls ${SrcFolder} | sort`
do
	TargetFolder=${TargetFolderPrefx}${FolderIndex}
	mkdir -p ${TargetFolder}
	mv ${SrcFolder}"/"${i} ${TargetFolder}
	echo "Moving: "${i}
	((Count+=1))

	if [ ${Count} -ge ${LoopFactor} ]
	then
		((Count%=${LoopFactor}))
		((FolderIndex+=1))
	fi

done

