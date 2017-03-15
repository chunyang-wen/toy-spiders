a=0
b=2

if [ ! -z "$(grep "Haha" Books)" ]
then
	echo "yeah"
fi

if [ $a -eq 1 -o $b -eq 2 ]
then
	echo "HH"
fi

((a++))
echo $a

TryLimit=3
Tries=$TryLimit
while [ $Tries -gt 0 ]
do
	sh report.sh
	if [ $? -eq 0 ]
	then
		break
	else
		echo "Sending failed, retry later"
	fi
	sleep 30s
	((Tries-=1))
done

