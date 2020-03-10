#!/bin/bash

function Colorset() {
  #颜色配置
  echo=echo
  for cmd in echo /bin/echo; do
    $cmd >/dev/null 2>&1 || continue
    if ! $cmd -e "" | grep -qE '^-e'; then
      echo=$cmd
      break
    fi
  done
  CSI=$($echo -e "\033[")
  CEND="${CSI}0m"
  CDGREEN="${CSI}32m"
  CRED="${CSI}1;31m"
  CGREEN="${CSI}1;32m"
  CYELLOW="${CSI}1;33m"
  CBLUE="${CSI}1;34m"
  CMAGENTA="${CSI}1;35m"
  CCYAN="${CSI}1;36m"
  CSUCCESS="$CDGREEN"
  CFAILURE="$CRED"
  CQUESTION="$CMAGENTA"
  CWARNING="$CYELLOW"
  CMSG="$CCYAN"
}

function Logprefix() {
  #输出log
  echo -n ${CGREEN}'CraftYun >> '
}

function Checksystem() {
  cd
  Logprefix;echo ${CMSG}'[Info]检查系统'${CEND}
  #检查系统
  if [[ $(id -u) != '0' ]]; then
    Logprefix;echo ${CWARNING}'[Error]请使用root用户安装!'${CEND}
    exit
  fi

  if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
    DISTRO='CentOS'
  else
    DISTRO='unknow'
  fi

  if [[ ${DISTRO} == 'unknow' ]]; then
    Logprefix;echo ${CWARNING}'[Error]请使用Centos系统安装!'${CEND}
    exit
  fi

  if grep -Eqi "release 5." /etc/redhat-release; then
      RHEL_Version='5'
  elif grep -Eqi "release 6." /etc/redhat-release; then
      RHEL_Version='6'
  elif grep -Eqi "release 7." /etc/redhat-release; then
      RHEL_Version='7'
  fi

  if [[ ${RHEL_Version} == '5' ]]; then
    Logprefix;echo ${CWARNING}'[Error]请使用Centos6/7安装!'${CEND}
    exit
  fi
}

function Coloseselinux() {
  #关闭selinux
  Logprefix;echo ${CMSG}'[Info]关闭Selinux'${CEND}
  [ -s /etc/selinux/config ] && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	setenforce 0 >/dev/null 2>&1
}

function Askuser() {
  Logprefix;echo ${CMSG}'[Info]查找到以下内核:'${CEND}
  rpm -qa | grep kernel
  Logprefix;echo ${CMSG}'[Info]按下回车键开始卸载，或使用CTRL+C退出'${CEND}
  read
  yum -y remove kernel-*
  Logprefix;echo ${CMSG}'[Info]卸载成功,按下回车安装kernel-devel、kernel-headers,或使用CTRL+C退出'${CEND}
  read
  yum -y install kernel-ml-devel kernel-ml-headers
  Logprefix;echo ${CMSG}'[Info]卸载完成'${CEND}
}

function ShowLogo() {
  clear
  # Logo  ******************************************************************
  CopyrightLogo='
                            Centos Clear kernel
                          Powered by FanHuaCloud
                       http://blog.craftyun.cn All Rights Reserved

  =========================================================================='
  echo "$CopyrightLogo"
}

ShowLogo
Colorset
Checksystem

#安装开始
Askuser
