#!/bin/bash
#This is script use in system CentOS7 init...
#set -x
package() {
  yum -y install vim ntpdate net-tools
}

system() {
  sed -i '7s/enforcing/disabled/' /etc/selinux/config
  echo "* soft nofile 65536" >> /etc/security/limits.conf
  echo "* hard nofile 65536" >> /etc/security/limits.conf
  echo "* soft nproc 65536" >> /etc/security/limits.conf
  echo "* hard nproc 65536" >> /etc/security/limits.conf
  sed -i 's/4096/65536/' /etc/security/limits.d/20-nproc.conf
  [ $? -eq 0 ] || exit 1
  echo "*/50 * * * * /usr/sbin/ntpdate pool.ntp.org &> /dev/null" > /var/spool/cron/root
  echo "net.ipv4.tcp_max_syn_backlog = 65536" >>/etc/sysctl.conf
  echo "net.core.netdev_max_backlog = 32768" >> /etc/sysctl.conf
  echo "net.core.somaxconn = 32768" >> /etc/sysctl.conf
  echo "net.core.wmem_default = 8388608" >> /etc/sysctl.conf
  echo "net.core.rmem_default = 8388608" >> /etc/sysctl.conf
  echo "net.core.rmem_max = 16777216" >> /etc/sysctl.conf
  echo "net.core.wmem_max = 16777216" >>/etc/sysctl.conf
  echo "net.ipv4.tcp_timestamps = 0" >> /etc/sysctl.conf
  echo "net.ipv4.tcp_synack_retries = 2" >> /etc/sysctl.conf
  echo "net.ipv4.tcp_syn_retries = 2" >>/etc/sysctl.conf
  echo "net.ipv4.tcp_tw_recycle = 1" >> /etc/sysctl.conf
  echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
  echo "net.ipv4.tcp_mem = 94500000 915000000 927000000" >> /etc/sysctl.conf
  echo "net.ipv4.tcp_max_orphans = 3276800" >> /etc/sysctl.conf
  echo "net.ipv4.ip_local_port_range = 1024 65536" >> /etc/sysctl.conf
  echo "net.nf_conntrack_max = 25000000" >> /etc/sysctl.conf
  echo "net.netfilter.nf_conntrack_max = 25000000" >> /etc/sysctl.conf
  echo "net.netfilter.nf_conntrack_tcp_timeout_established = 180" >> /etc/sysctl.conf
  echo "net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120" >> /etc/sysctl.conf
  echo "net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60" >> /etc/sysctl.conf
  echo "net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120" >>/etc/sysctl.conf
  sysctl -p
  [ $? -eq 0 ] || exit 1
}

ssh_config=/etc/ssh/sshd_config
profile=/etc/profile
security() {
  sed -i '17s/#//' $ssh_config 
  sed -i '17s/22/65412/' $ssh_config
  sed -i '132s/yes/no/' $ssh_config
  sed -i '63s/5/3/' /boot/grub2/grub.cfg
  sed -i '67s/5/3/' /boot/grub2/grub.cfg
  sed -i '46s/1000/100/' $profile
  echo "HISTTIMEFORMAT="%Y-%m-%d:%H:%M:  "" >> $profile
  useradd chenqf
  echo "Q!anda013579" |passwd --stdin chenqf
  chown -R chenqf.chenqf /data
  echo "order hosts,bind" >> /etc/host.conf
  echo "multi on" >> /etc/host.conf
}

service() {
systemctl disable NetworkManager postfix tuned irqbalance \
                  kdump lvm2-monitor microcode default.target \
                  auditd 
systemctl daemon-reoad
systemctl restart sshd
firewall-cmd --zone=public --add-port=65412/tcp --permanent
firewall-cmd --zone=public --add-port=63179/tcp --permanent
firewall-cmd --zone=public --add-port=63180/tcp --permanent
firewall-cmd --zone=public --remove-port=22/tcp --permanent
firewall-cmd --reload
}
clear;sleep 2
echo -e "\033[32m开始初始化,安装软件...\033[0m"
package
sleep 2
echo -e "\033[33m开始进行系统优化设置...\033[0m"
system
sleep 2
echo -e "\033[34m开始系统安全优化设置...\033[0"
security
sleep 2
echo -e "\033[35m开始精简系统多余服务...\033[0m"
service
echo -e "\033[36mCentOS7系统初始化完成！！\033[0m"
