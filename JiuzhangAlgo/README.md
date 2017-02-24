Code used to get all avaiable implementation from jiuzhang.

It works because:

+ url from leetcode and jiuzhang have same patterns
+ html from jiuzhang has simple structure

Following steps to take if you want to update srcs: first backup srcs and remove it

+ get all list of problem names from leetcode (use awk and vim to get from homepage of leetcode)
+ download.sh, use wget to get all the files (modify file name to read)
