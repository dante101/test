#!/bin/bash
for i in $(find . -maxdepth 2 -type f)
do 
md5sum $i  >> summ-list.txt  
done
