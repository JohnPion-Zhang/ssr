#!/bin/bash

#开放ssh端口、回环、外网、默认策略
config_default(){
    systemctl stop firewalld
    systemctl disable firewalld
    yum install -y iptables-services
    systemctl start iptables
    systemctl enable iptables
    ssh_port=$(awk '$1=="Port" {print $2}' /etc/ssh/sshd_config)
    iptables -A INPUT -p tcp -m tcp --dport ${ssh_port} -j ACCEPT
    iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    service iptables save
    echo "初始配置完成"
}

#禁止邮箱
config_mail(){
    iptables -A OUTPUT -m multiport --dports 24,25,26,50,57,105,106,109,110,143,158,209,218,220,465,587,993,995,1109.60177,60179 -j DROP
    service iptables save
    echo "禁止邮箱完毕"
}

#禁止关键字
config_keyword(){
    iptables -A OUTPUT -m string --string "torrent" --algo bm -j DROP
    iptables -A OUTPUT -m string --string ".torrent" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "peer_id=" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "announce" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "info_hash" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "get_peers" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "find_node" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "BitToorent" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "announce_peer" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "BitTorrent protocol" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "announce.php?passkey=" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "magnet:" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "xunlei" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "sandai" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "Thunder" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "XLLiveUD" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "youtube.com" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "google.com" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "youku.com" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "iqiyi.com" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "qq.com" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "huya.com" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "douyu.com" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "twitch.tv" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "panda.tv" --algo bm -j DROP
    service iptables save
    echo "禁止关键字完毕"
}

#开放自定义端口
config_port(){
    echo "开放一个自定义的端口段"
    read -p "输入开始端口：" start_port
    read -p "输入结束端口：" stop_port
    iptables -A INPUT -p tcp -m tcp --dport ${start_port}:${stop_port} -j ACCEPT
    iptables -A INPUT -p udp -m udp --dport ${start_port}:${stop_port} -j ACCEPT
}

#连接数限制
config_conn(){
    echo "限制一个端口段的连接数"
    read -p "输入开始端口：" start_conn
    read -p "输入结束端口：" stop_conn
    read -p "输入每个ip允许的连接数：" conn_num
    iptables -A INPUT -p tcp --dport ${start_conn}:${stop_conn} -m connlimit --connlimit-above ${conn_num} -j DROP
    iptables -A INPUT -p udp --dport ${start_conn}:${stop_conn} -m connlimit --connlimit-above ${conn_num} -j DROP
    echo "限制连接数完毕"
}

