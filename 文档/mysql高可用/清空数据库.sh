cmake  -DCMAKE_INSTALL_PREFIX=/mnt/data/mysql36806 -DMYSQL_DATADIR=/mnt/data/mysql36806/data -DMYSQL_UNIX_ADDR=/tmp/mysql36806.sock -DDEFAULT_CHARSET=utf8 -DMYSQL_TCP_PORT=36806 -DMYSQL_USER=mysql -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_BOOST=/mnt/data/mysql36806/boost_1_59_0.tar.gz


mysql_install_db --defaults-file=/etc/my.cnf --basedir=/mnt/data/mysql36807/ --datadir=/mnt/data/mysql36807/data --user=mysql

update user set authentication_string=password('d$Tsi-&^L88qUz') where user='root';

change master to master_host='10.24.200.229',master_port=36806,master_user='repl',master_password='Q!anda0',master_log_file='mysql-bin.000106',master_log_pos=791;

/mnt/mysql/bin/mysqld_safe --defaults-file=/etc/my.cnf --basedir=/mnt/mysql/ --datadir=/mnt/mysql/data/ --port=36806&

 SELECT * from slave_master_info;
 
 mysqlbinlog -j --start-position=0 /mnt/mysql/data/mysql-bin.000106 | less
 mysqldump -uroot -p -d qiandaowbs > qiandaowbs.sql   #只备份数据库结构，不包含数据
重建库和表
一。只导出表结构
 
 
导出整个数据库结构（不包含数据）
mysqldump -h localhost -uroot -p123456  -d database > dump.sql
 
导出单个数据表结构（不包含数据）
mysqldump -h localhost -uroot -p123456  -d database table > dump.sql

二。只导出表数据
导出整个数据库数据
mysqldump -h localhost -uroot -p123456  -t database > dump.sql

三。导出结构+数据
导出整个数据库结构和数据
mysqldump -h localhost -uroot -p123456 database > dump.sql
 
导出单个数据表结构和数据
mysqldump -h localhost -uroot -p123456  database table > dump.sql


生成清空所有表的SQL
mysql -N -s information_schema -e "SELECT CONCAT('TRUNCATE TABLE ',TABLE_NAME,';') FROM TABLES WHERE TABLE_SCHEMA='eab12'"
输出结果如下：
TRUNCATE TABLE AUTHGROUPBINDINGS;
TRUNCATE TABLE AUTHGROUPS;
TRUNCATE TABLE AUTHUSERS;
TRUNCATE TABLE CORPBADCUSTOMINFO;
TRUNCATE TABLE CORPSMSBLACKLISYInfo;
TRUNCATE TABLE CORPSMSFILTERINFO;
TRUNCATE TABLE CORPSMSINFO;
TRUNCATE TABLE EABASEREGINFOS;
TRUNCATE TABLE EACORPBLOB;
TRUNCATE TABLE EACORPINFO;
....
....
这样就更完善了：
mysql -N -s information_schema -e "SELECT CONCAT('TRUNCATE TABLE ',TABLE_NAME,';') FROM TABLES WHERE TABLE_SCHEMA='eab12'" | mysql eab12
即清空eab12中所有的表。
但是如果有外键的话，很可能会报错。因此还需要加个-f
mysql -N -s information_schema -e "SELECT CONCAT('TRUNCATE TABLE ',TABLE_NAME,';') FROM TABLES WHERE TABLE_SCHEMA='eab12'" | mysql -f eab12
多执行几次，直到不报错
 
