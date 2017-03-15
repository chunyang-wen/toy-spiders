#!/bin/bash

# Send updated books to Gmail

BooksCollection="Books"
BooksCollectionFailed="BooksFailed"

hasUpdate=0
MessageFile="Message"
Title="[Monitor] Updates from allitebooks"
Receiver="YOUR-MAIL"

function AddMessage() {
	echo "$@" >> ${MessageFile}
	echo "" >> ${MessageFile}
}

function AddMessageFile() {
	sed -e 's/^/+ */' -e 's/$/*/' "$@" >> ${MessageFile}
	echo "" >> ${MessageFile}
}

function AddMessageBold() {
	echo "**$@**" >> ${MessageFile}
	echo "" >> ${MessageFile}
}

function AddMessageItalic() {
	echo "*$@*" >> ${MessageFile}
	echo "" >> ${MessageFile}
}

function AddMessageList() {
	sed -e 's/^/+ */' "$@" >> ${MessageFile}
	echo "" >> ${MessageFile}
}

function AddMessageTitle() {
	level=$1
	msg=$2
	out=""
	while [ $level -gt 0 ]
	do
		out=$out"#"
		((level-=1))
	done
	echo "${out} ${msg}" >> ${MessageFile}
	echo "" >> ${MessageFile}
}

echo -n > ${MessageFile}
#AddMessageBold "Chunyang Wen:"
AddMessageTitle 2 "Daily update stats:"
if [ -s "${BooksCollection}Updated" ]
then
	hasUpdate=1
	AddMessageTitle 3 "Updated successfully books:"
	AddMessageFile "${BooksCollection}Updated"
fi

if [ -s "${BooksCollectionFailed}Updated" ]
then
	hasUpdate=1
	AddMessage "Updated Failed books:"
	AddMessageFile "${BooksCollectionFailed}Updated"
fi

AddMessageItalic "B.R."
AddMessageItalic "Chunyang"

if [ $hasUpdate -ne 0 ]
then
	#cat ${MessageFile}
	#cat ${MessageFile} | mutt -s "${Title}" "${Receiver}"
	pandoc ${MessageFile} -f markdown -t html -s -o ${MessageFile}.html
	#cat ${MessageFile}.html | mutt -s "${Title}" "${Receiver}" -e 'set content_type="text/html"'
	echo "Sending starts"
	nohup mutt -s "${Title}" "${Receiver}" -e 'set content_type="text/html"' < ${MessageFile}.html &>/dev/null &
	wait
	sendStatus=$?
	echo "Sending ends"
	echo "Sending status: ${sendStatus}"
	exit ${sendStatus}
fi

