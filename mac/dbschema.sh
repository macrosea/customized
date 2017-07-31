#!/usr/bin/env bash
DB=$*
#获取指定的数据库名
HOST=10.199.233.196
USER=ar
PW=ar

TBNUM=`echo "show tables from $*;" | mysql -h$HOST -u$USER -p$PW | wc -l`
let "TBNUM=$TBNUM-1"
#获取表个数
TABLES=`echo "show tables from $*;" | mysql -h$HOST -u$USER -p$PW | tail -n $TBNUM`
#获取所有表
for i in $TABLES; do
    #echo "desc $*.$i;" | mysql -h$HOST -u$USER -p$PW >> $i.xls
    echo "show full fields from $*.$i;" | mysql -h$HOST -u$USER -p$PW >> /tmp/$i.xls
#导出到表对应的excel文件
done
