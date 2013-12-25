#!/bin/sh
# additional info:
# version from:  Dec-1-2013

PATH="/sbin:/bin:/usr/sbin:/usr/bin:/sbin:/usr/local/sbin/"

print_error()
{
  echo "ERROR: $@"
  exit 1
}

detect_os()
{
  echo "Checking for OS"

  OS=$(uname -s)
  KERNEL=$(uname -r)
  ARCH=$(uname -m)

  # verify OS
  [[ $OS == FreeBSD || $OS == Linux ]] || print_error "OS $OS not recognized"

  if [[ $OS == FreeBSD ]]; then
    DISTRO=$OS
    DISTRO_VERSION=`echo $KERNEL | awk -F\- '{print $1}'`
  fi

  # Linux processing
  if [[ $OS == Linux ]]; then
    # lsb check
    [[ -f `which lsb_release` ]] && LSB=1 || LSB=0

    if [[ $LSB -eq 1 ]]; then
      DISTRO=`lsb_release -si`
      DISTRO_VERSION=`lsb_release -sr`
    fi

    if [[ $LSB -eq 0 ]]; then
      distro()
      {
        release_file=$1
        distro=$2

        [[ -f $release_file ]] && DISTRO=$distro || return

        DISTRO_VERSION=`grep -o -E '[0-9]+\.[0-9]+.*' $release_file | awk '{print $1}'`
        [[ `echo $DISTRO_VERSION | wc -l` -eq 0 ]] && DISTRO_VERSION=unknown
      }

      # detect known distros
      distro /etc/debian_version Debian
      distro /etc/redhat-release RHEL
      distro /etc/centos-release CentOS
      distro /etc/gentoo-release Gentoo
      distro /etc/system-release AMI
      distro /etc/SuSe-release SUSE
    fi
  fi

  DISTRO_MAJOR_VERSION=`echo $DISTRO_VERSION | awk -F\. {'print $1'}`
  DISTRO_MINOR_VERSION=`echo $DISTRO_VERSION | awk -F\. {'print $1'}`

  echo $DISTRO
  echo $DISTRO_VERSION
}


env_checkup()
{
  echo "Checking for privileges"
  [[ `whoami` == root ]] || print_error "root permissions are required"

}

bin_checkup()
{
 
 if [ "$OS" == "FreeBSD" ] && [[ -f `which dmidecode` ]] ; then
		
    dmidecode_parser ||  system_fbsd_parser
	
  elif	[[ $OS == Linux ]] && [[ -f `which dmidecode` ]]  ; then
	 
		dmidecode_parser ||  echo "need gets information from /proc"
	
	fi

}

ip_lists()
{
  echo "Checking server ip addr"

	[[ $OS == FreeBSD ]] && IP_LIST=$(ifconfig | grep -B1 "inet" | awk '{ if ( $1 == "inet" ) { print $2 }}') 
 
  [[ $OS == Linux ]] &&  IP_LIST=$(ifconfig | grep -B1 "inet addr" | awk '{ if ( $1 == "inet" ) { print $2 } else if ( $2 == "Link" ) { printf "%s:" ,$1 } }' | awk -F: '{ print $1 ": " $3 }')
 
 	echo "${IP_LIST}"
}


dmidecode_parser()
{


	CPU_INFO=$(dmidecode --type 4 | grep -E -o '(Version:.*|Manufacturer:.*|Core Enabled:.*|Thread Count:.*|Max Speed:.*|Current Speed:.*)')
  CPU_CORES=$(dmidecode --type 4 | grep "Socket Designation:" | wc -l)
  echo -e "Server has following cpu info:${CPU_INFO}\nCpu cores:${CPU_CORES}"


  MOTHERBOARD_INFO=$(dmidecode --type 2 | grep -E -o '(Manufacturer:.*|Product Name:.*)')
  echo "${MOTHERBOARD_INFO}"

  MEMORY_INFO=$(dmidecode  --type 17 | grep -E -o '(Size:.*|Form Factor:.*|Type:.*|Speed:.*|Manufacturer:.*)')
  MEMORY_CAPASITY=$(dmidecode --type 17| grep  'Size:' | awk '{print $2}')
  MEMORY_COUTN=$(dmidecode  --type 17| grep  'Size:' | wc -l)
  echo "Server has following memory: $MEMORY_INFO Count of memory modules ${MEMORY_COUTN}x${MEMORY_CAPASITY}Mb"

 
}

system_fbsd_parser()
{
	CPU_INFO=$(cat /var/run/dmesg.boot | grep CPU | head -1)
  echo ${CPU_INFO}


	MEMORY_CAPASITY=$(grep -E "^real memory" /var/run/dmesg.boot | cut -d'(' -f2 | cut -d')' -f1)
  echo ${MEMORY_CAPASITY}

  DISKS=$(iostat -d | head  -1)
	COUNT_DISKS=$(echo $DISKS | wc -w)
  echo "Server has ${COUNT_DISKS} disks ,${DISKS}"
}


detect_os
env_checkup
bin_checkup
ip_lists
