#!/bin/bash
# Author: chunyang.wen@gmail.com

# Send updated books to mailbox

BooksCollection="Books"
BooksCollectionFailed="BooksFailed"

hasUpdate=0
MessageFile="Message"

function AddMessage() {
	echo "$@" >> ${MessageFile}
}

function AddMessageFile() {
	sed 's/^/    /' "$@" >> ${MessageFile}
}

echo -n > ${MessageFile}
AddMessage "Update stats:"
if [ -s "${BooksCollection}Updated" ]
then
	hasUpdate=1
	AddMessage "Updated successfully books:"
	AddMessageFile "${BooksCollection}Updated"
fi

if [ -s "${BooksCollectionFailed}Updated" ]
then
	hasUpdate=1
	AddMessage "Updated Failed books:"
	AddMessageFile "${BooksCollection}Updated"
fi

if [ $hasUpdate -ne 0 ]
then
	#cat ${MessageFile}
	cat ${MessageFile} | mutt -s "UpdateBooks" "your-email-address"
fi

