#!/bin/bash
#Author:13051699665@163.com
#设置变量key，存储密码的所有可能性（密码库），如果还需要其他字符请自行添加其他密
码字符
#使用$#统计密码库的长度
key="0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*([{+_=<>.,:;?-.–\/\\|\“‘"
num=${#key}
i=/tmp/passwd.txt
if [ -f $i ]
 then
  rm -rf $i
fi
#设置初始密码为空
pass=''
#循环8次，生成8为随机密码
#每次都是随机数对密码库的长度取余，确保提取的密码字符不超过密码库的长度
#每次循环提取一位随机密码，并将该随机密码追加到pass变量的最后
for j in {1..8}
do
    index=$[RANDOM%num]
    pass=$pass${key:$index:2}
done
echo $pass >> $i
