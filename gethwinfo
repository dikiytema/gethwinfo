#!/usr/bin/env bash
# additional info:
# version from:  Dec-1-2013

PATH="/sbin:/bin:/usr/sbin:/usr/bin:/sbin"

print_error()
{
  echo "  * ERROR: $@"
  exit 1
}

env_checkup()
{
  echo "Checking root privileges"
  [[ `whoami` == root ]] || print_error "Root permissions are required" 

	echo  "Checking dmodecode binary"
  [[ -f `which dmidecode 2>/dev/null` ]] || print_error "dmidecode didn't install" 
}

ip_lists()
{
  echo "Checking server ip addr:"
	IP_LIST=$(ifconfig | grep -B1 "inet addr" | awk '{ if ( $1 == "inet" ) { print $2 } else if ( $2 == "Link" ) { printf "%s:" ,$1 } }' | awk -F: '{ print $1 ": " $3 }')
  echo  "${IP_LIST}"
}

detect_distro()
{

ARCH=$(uname -m)
KERNEL=$(uname -r)
 
  echo "Determininig OS distributive:"
  if [[ -f `which lsb_release` ]]; then
	  OS=$(lsb_release -sri)
  elif [[ -f /etc/debian_version ]]; then
    OS="Debian $(cat /etc/debian_version)"
  elif [[ -f /etc/redhat-release ]]; then
    OS=`cat /etc/redhat-release`
  else
    OS="$(uname -s) $(uname -r)"
  fi
  echo  "Server has ${OS} arch ${ARCH} and kernel ${KERNEL}"
}

dmidecode_parser()
{

  CPU_INFO=$(dmidecode --type 4 | grep -E -o '(Version:.*|Manufacturer:.*|Core Enabled:.*|Thread Count:.*|Max Speed:.*|Current Speed:.*)')
	CPU_CORES=$(dmidecode --type 4 | grep "Socket Designation:" |wc -l)
  echo -e "Server has following cpu info:${CPU_INFO}\nCpu cores:${CPU_CORES}"


	MOTHERBOARD_INFO=$(dmidecode --type 2 | grep -E -o '(Manufacturer:.*|Product Name:.*)')
	echo "${MOTHERBOARD_INFO}"

	MEMORY_INFO=$(dmidecode  --type 17 | grep -E -o '(Size:.*|Form Factor:.*|Type:.*|Speed:.*|Manufacturer:.*)')
	MEMORY_CAPASITY=$(dmidecode --type 17| grep  'Size:' | awk '{print $2}')
	MEMORY_COUTN=$(dmidecode  --type 17| grep  'Size:' | wc -l)
  echo "Server has following memory: $MEMORY_INFO Count of memory modules ${MEMORY_COUTN}x${MEMORY_CAPASITY}Mb"
}
env_checkup
ip_lists
detect_distro
dmidecode_parser
