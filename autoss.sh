#===================================================================
# Script by Ivan 2016-11-27
# Web:www.ithubs.cn
# version: v3.0
# ===>
# 
#===================================================================

#!/bin/sh
#set -x
outside_web="https://assets.tumblr.com/images/logo/logo_large.png"
routename="TestName"
mode=1
type=1
#获取服务器信息
ithubs_getss_info()
{
	index=1
	rm -f ss*
	#第一组服务器
	sh getss.sh https://freessr.xyz/ $index $mode 1
	index=$?
	#第二组服务器
	sh getss.sh http://www.ishadowsocks.info/ $index $mode 1
	index=$?
	#第三组服务器
	sh getss.sh https://www.dou-bi.co/sszhfx/ $index $mode 2
	index=$?	
	#第四组服务器
	sh getss.sh https://freevpnss.cc/ $index $mode 1
	index=$?		
	
	#如果有更多的服务器，可以在这里自己添加，参照上面的代码自己填写
}

# ^_^以下的代码,如果没看懂,最好不要乱动,不然有可能获取不到服务器^_^

if [ ! "p$1" = "p" ];then
	mode=$1
fi

#获取路由器的系统是华硕还是潘多拉
ithubs_get_os_name()
{
	echo "获取一下路由器的系统名字 ... ..."
	uname -a | cut -d ' ' -f 2 &>temp
	
	routename=0
	grep 'RT-' temp &>null
	if [ "p$?" = "p0" ];then
		routename="AC54U"
	fi
	
	grep 'PandoraBox' temp &>null
	if [ "p$?" = "p0" ];then
		routename="PandoraBox"
	fi

	grep 'PBXiaoMi' temp &>null
	if [ "p$?" = "p0" ];then
		routename="PBXiaoMi"
	fi	

	echo "你的路由系统名字为: $routename"
		
	rm -f temp
	rm -f null
	return 1
}

#获取一个速度最快的服务
ithubs_get_fast_server()
{
	if [ ! -s ss1 ];then
		echo "没有找到可以使用的服务器了,可能所有网站都被和谐了... ..."
		return 0
	fi
	
	echo "选择一个连接速度最快的服务器 ... ..."
	index=0
	tt=9999
	for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29
	do
		if [ ! -s ss$i ];then
			break
		fi
		
		tt2=`sed -n '5p' ss$i`
		if [ "p$tt2" = "p" ];then
			tt2=9999
		fi
		
		res=`awk -v t1=$tt -v t2=$tt2 'BEGIN{print(t1<t2)?"1":"0"}'`
		if [ "p$res" = "p0" ];then
			tt=$tt2
			index=$i
		fi
	done
	
	if [ "p$index" = "p0" ];then
		return 0
	else
		ithubs_get_a_server $index
		return $?
	fi
}

#随机选择一个可用的服务器
ithubs_get_random_server()
{
	if [ ! -s ss1 ];then
		echo "没有找到可以使用的服务器了,可能所有网站都被和谐了... ..."
		return 0
	fi
	
	echo "随机选择一个可用的服务器"
	
    sum=`date +%s`
    num=`ls -l ss* |grep "^-"|wc -l`
	
	if [ "p$num" = "p0" ];then
		return 0
	fi
	
    ran=$(( sum % num + 1 ));

	ithubs_get_a_server $ran
	return $?
}

#华硕的系统,可以再选择一下备用的服务器
ithubs_get_a_backup()
{
	if [ ! -s ss1 ];then
		echo "没有找到可以使用的服务器了,可能所有网站都被和谐了... ..."
		return 0
	fi
	
	echo "随机选择一个可用的备份服务器如下:"
	
    sum=`date +%s`
    num=`ls -l ss* |grep "^-"|wc -l`
	
	if [ "p$num" = "p0" ];then
		return 0
	fi
	
    ran=$(( sum % num + 1 ));

	cat ss$ran
	cat ss$ran >backup
	return 1
}

#获取指定的服务器信息
ithubs_get_a_server()
{
	if [ ! -s ss$1 ];then
		return 0
	fi
	
	echo "经过脚本的最终选择,决定使用以下的服务器进行连接":
	cat ss$1
	cat ss$1 >usedserver
	return 1
}

#删除日志
ithubs_exit_log()
{
	rm -f ss$i
	rm -f null
	rm -f tmp
}

#主函数
ithubs_main()
{
	ithubs_getss_info #获取全部网站的服务器信息

	if [ "p$mode" = "p1" ];then
		ithubs_get_fast_server #拿连接快的服务器
	else
		ithubs_get_random_server #随机拿一个服务器
	fi
	if [ "p$?" = "p0" ];then
		ithubs_exit_log
		echo "获取不到可用的SS服务器,等待脚本重试"
		echo "获取不到可用的SS服务器,等待脚本重试" >>error.log
		return 0
	fi
	
	if [ "p$routename" = "pAC54U" ];then # 华硕的系统再获取一个备用服务器
		ithubs_get_a_backup
	fi
	
	if [ ! -s $routename.os ];then
		echo "脚本文件不全,少了文件:"$routename.os
		ithubs_exit_log
		echo "脚本文件不全,少了文件:"$routename.os >>error.log
		exit 0
	fi
			
	sh $routename.os
	ithubs_exit_log
}

#检查文件完整性
ithubs_check_file()
{
	if [ ! -d /tmp/iss ];then
		mkdir /tmp/iss/
	fi

	cd /tmp/iss/
	
	if [ ! -s /tmp/iss/autoss.sh ];then
		wget -O /tmp/iss/autoss.sh http://www.ithubs.cn/ss/autoss.sh
	fi

	if [ ! -s /tmp/iss/getss.sh ];then
		wget -O /tmp/iss/getss.sh http://www.ithubs.cn/ss/getss.sh
	fi

	if [ ! -s /tmp/iss/AC54U.os ];then
		wget -O /tmp/iss/AC54U.os http://www.ithubs.cn/ss/AC54U.sh
	fi

	if [ ! -s /tmp/iss/PandoraBox.os ];then
		wget -O /tmp/iss/PandoraBox.os http://www.ithubs.cn/ss/PandoraBox.sh
	fi
}

#华硕系统检查连接性
ithubs_rc51u_check()
{
	echo "ithubs_rc51u_check"
}

#潘多拉系统检查连接性
ithubs_pbox_check()
{
	echo "ithubs_pbox_check"
}

#ithubs_main
#exit 0

ithubs_check_file

ithubs_get_os_name #判断一下路由的名字
if [ "p$routename" = "p0" ] || [ "p$routename" = "p0" ];then
	ithubs_exit_log
	echo "脚本不支持现在的这个路由系统"
	echo "脚本不支持现在的这个路由系统" >>error.log
	exit 0
fi

#脚本守护进程
while true
do
	ithubs_check_file
	
	if [ "p$routename" = "pAC54U" ];then
		wget -s -q $outside_web --continue --no-check-certificate &>null
		if [ "p$?" = "p0" ];then #第一次检查
			echo "正常上google"
			rm -f null
			sleep 30
			continue
		else
			sleep 10
			wget -s -q $outside_web --continue --no-check-certificate &>null
			if [ "p$?" = "p0" ];then #第二次检查
				echo "掉了一次线,但还是正常上google"
				rm -f null
				sleep 30
				continue
			else
				wget -s -q $outside_web --continue --no-check-certificate &>null
				if [ "p$?" = "p0" ];then #第三次检查
					echo "掉了两次线,最后还是正常上google"
					rm -f null
					sleep 30
					continue
				else
					echo "掉了三次线,上不了google了,尝试重新去拿服务器信息"
					rm -f null
					ithubs_main
					sleep 120
				fi
			fi
		fi
	fi
	
	if [ "p$routename" = "PandoraBox" ];then
		wget -T 30 -t 1 -q $outside_web --no-check-certificate &>null
		if [ "p$?" = "p0" ];then #第一次检查
			echo "正常上google"
			sleep 30
			continue
		else
			sleep 10
			wget -T 30 -t 1 -q $outside_web --no-check-certificate &>null
			if [ "p$?" = "p0" ];then #第二次检查
				echo "掉了一次线,但还是正常上google"
				sleep 30
				continue
			else
				wget -T 30 -t 1 -q $outside_web --no-check-certificate &>null
				if [ "p$?" = "p0" ];then #第三次检查
					echo "掉了两次线,最后还是正常上google"
					sleep 30
					continue
				else
					echo "掉了三次线,上不了google了,尝试重新去拿服务器信息"
					ithubs_main
					sleep 120
				fi
			fi
		fi
	fi	
		
done
