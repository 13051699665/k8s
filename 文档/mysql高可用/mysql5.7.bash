yum -y install libtermcap-devel imake autoconf automake libtool m4 libstdc++-devel gcc-c++ zlib-devel ncurses-devel bison make cmake

chattr -i /etc/gshadow
chattr -i /etc/shadow
chattr -i /etc/group
chattr -i /etc/passwd
groupadd mysql
useradd -M -g mysql -s /sbin/false mysql
chattr +i /etc/gshadow
chattr +i /etc/shadow
chattr +i /etc/group
chattr +i /etc/passwd
mkdir -pv /mnt/mysql
mkdir -pv /mnt/mysql/data

tar -zxf boost_1_59_0.tar.gz -C /mnt/
tar zxf mysql-5.7.13.tar.gz
cmake -DCMAKE_INSTALL_PREFIX=/mnt/mysql -DMYSQL_DATADIR=/mnt/mysql/data -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DMYSQL_TCP_PORT=36806 -DMYSQL_USER=mysql -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_BOOST=/mnt/boost_1_59_0 -DEXTRA_CHARSETS=all

make -j `grep processor /proc/cpuinfo | wc -l`
make install
-- Installing: /mnt/mysql/support-files/my-default.cnf
-- Installing: /mnt/mysql/support-files/mysqld_multi.server
-- Installing: /mnt/mysql/support-files/mysql-log-rotate
-- Installing: /mnt/mysql/support-files/magic
-- Installing: /mnt/mysql/share/aclocal/mysql.m4
-- Installing: /mnt/mysql/support-files/mysql.server

mkdir -pv /mnt/mysql/{logs,temp}
chown -R mysql:mysql /mnt/mysql
/mnt/mysql/bin/mysqld --initialize-insecure --user=mysql --basedir=/mnt/mysql --datadir=/mnt/mysql/data
cp /mnt/mysql/support-files/my-default.cnf /etc/my.cnf
vim /etc/my.cnf

[client]
port=36806
socket=/mnt/mysql/mysql.sock
[mysqld]
character-set-server=utf8
collation-server=utf8_general_ci

skip-external-locking
skip-name-resolve

user=mysql
port=36806
basedir=/mnt/mysql
datadir=/mnt/mysql/data
tmpdir=/mnt/mysql/temp
# server_id = .....
socket=/mnt/mysql/mysql.sock
log-error=/mnt/mysql/logs/mysql_error.log
pid-file=/tmp/mysql.pid
open_files_limit=10240
back_log=600
max_connections=500
max_connect_errors=6000
wait_timeout=605800
#open_tables=600
#table_cache = 650
#opened_tables = 630

max_allowed_packet=32M
sort_buffer_size=4M
join_buffer_size=4M
thread_cache_size=300
query_cache_type=1
query_cache_size=256M
query_cache_limit=2M
query_cache_min_res_unit=16k

tmp_table_size=256M
max_heap_table_size=256M

key_buffer_size=256M
read_buffer_size=1M
read_rnd_buffer_size=16M
bulk_insert_buffer_size=64M

lower_case_table_names=1

default-storage-engine=INNODB

innodb_buffer_pool_size=2G
innodb_log_buffer_size=32M
innodb_log_file_size=128M
innodb_flush_method=O_DIRECT
#####################
#thread_concurrency=32
long_query_time=2
slow-query-log=on
slow-query-log-file=/mnt/mysql/logs/mysql-slow.log

[mysqldump]
quick
max_allowed_packet=32M

[mysqld_safe]
log-error=/mnt/mysql/logs/mysqld.log
pid-file=/mnt/mysql/mysqld.pid

cp -f /mnt/mysql/support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
service mysqld start
service mysqld stop
service mysqld restart

ln -s /mnt/mysql/bin/* /usr/local/bin/
ln -s /mnt/mysql/lib/* /usr/lib/
ln -s /mnt/mysql/include/mysql/* /usr/include/

update mysql.user set authentication_string=password('gfds@#$^9876POIU') where user='root' and Host = 'localhost';
/mnt/mysql/bin/mysql -e "grant all on *.* to root@'localhost' identified by 'gfds@#$^9876POIU';"
/mnt/mysql/bin/mysql -e "grant all on *.* to root@'127.0.0.1' identified by 'gfds@#$^9876POIU';"
alter user 'root'@'localhost' identified by 'gfds@#$^9876POIU';
service mysqld restart

mysql master->slave

master在my.cnf添加如下
server_id=59
log_bin=mysql-bin
binlog_format=mixed

service mysqld restart
grant replication client,replication slave on *.* to 'repl'@'10.80.80.158' identified by 'Q!anda0';
flush privileges;
show grants for 'repl'@'10.80.80.158';
flush logs;
show master status \G

slave在my.cnf添加如下
server_id=158
relay_log=mysql-relay

service mysqld restart
change master to master_host='10.80.81.59',master_port=36806,master_user='repl',master_password='Q!anda0',master_log_file='mysql-bin.000002',master_log_pos=154;
start slave;
mysql>show slave status \G;

vim /etc/profile
export PATH=/mnt/mysql/bin:$PATH
source /etc/profile

如果中途编译失败了，需要删除cmake生成的预编译配置参数的缓存文件和make编译后生成的文件，再重新编译。
rm -f CMakeCache.txt
make clean


partx -a /dev/vdb
BLKPG: Device or resource busy
error adding partition 1
partx -a /dev/vdb2 /dev/vdb