#!/bin/awk -f

BEGIN {
    foundTag = 0;
    startPrint = 0;
    fileType = "";
    fileName = "";
    status = 0;
}
/pi-tab-pane/{
    status = 1;
    foundTag = 1;
    startPrint = 1;
    if ($0~/cpp/) {
        fileType="cpp";
    }
    if ($0~/java/) {
        fileType="java";
    }
    if ($0~/python/) {
        fileType="py";
    }
    fileName = folder"/"name"."fileType;
    next
}
{
    if (startPrint > 0) {
        print $0 >> fileName;
    }
}
/<\/pre>/ {
    foundTag = 0;
    startPrint = 0;
}
END {
    if (status == 0) {
        exit(1);
    }
}
