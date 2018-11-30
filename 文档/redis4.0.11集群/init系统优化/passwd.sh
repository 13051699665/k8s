#!/bin/bash
aa=/root/mima.txt
[ -f $aa ] && rm -rf $aa
for j in {"!","@","#","$","%","^","+","*","(",")","-","[","]","<",">",".","/"}
do
	echo "`date +%s|sha256sum|base64|head -c 16`$j" >> $aa
	sleep 0.5
	echo " " >> $aa
done
