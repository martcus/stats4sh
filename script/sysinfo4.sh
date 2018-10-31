#!/usr/bin/env bash
#--------------------------------------------------------------------------------------------------
# Sysinfo4shell script
# Copyright (c) Marco Lovazzano
# Licensed under the GNU General Public License v3.0
# http://github.com/martcus
#--------------------------------------------------------------------------------------------------

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace

# IFS stands for "internal field separator". It is used by the shell to determine how to do word splitting, i. e. how to recognize word boundaries.
SAVEIFS=$IFS
IFS=$(echo -en "\n\b") # <-- change this as it depends on your app

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

# log4.sh inclusion
source log4.sh -v INFO # -d "+%Y-%m-%d %H:%M:%S" # use -f $__file for log

## Clear the screen
echo ""

DEBUG "__dir  = "$__dir
DEBUG "__file = "$__file
DEBUG "__base = "$__base
DEBUG "__root = "$__root

tempfile=.sysinfolog
# Define variable to reset terminal 
reset=$(tput sgr0)

## Utils
newline() {
    echo "|"
}

## OS info

## RAM usage
_ramusage() {
    echo -e '\E[32m'"Memory Usages"$reset >> $tempfile
    free -h | sed 's/^/ |/' >> $tempfile

    newline >> $tempfile
}

## Check System Uptime
_uptime() {
    uptime=$(uptime | awk '{print $3,$4}' | cut -f1 -d,)
    echo -e '\E[32m'"Uptime Days/(HH:MM)|"$reset$uptime >> $tempfile
    
    newline >> $tempfile
}

## Load average
_loadaverage() {
    loadaverage=$(top -n 1 -b | grep "load average:" | awk '{print $11 $12 $13}')
    echo -e '\E[32m'"Load Average|"$reset$loadaverage >> $tempfile
    
    newline >> $tempfile
}

## Architecture
_arch() {
	# Check OS Type
	os=$(uname -o)
	echo -e '\E[32m'"Operating System Type|"$reset$os >> $tempfile

	# Check OS Release Version and Name
    name=$(< /etc/os-release grep 'NAME' | grep -v 'VERSION' | grep -v 'VERSION_ID' | grep -v 'PRETTY_NAME' | cut -f2 -d=)
    echo -e  '\E[32m'"OS Name|"$reset$name >> $tempfile
    version=$(< /etc/os-release grep 'VERSION' | grep -v 'NAME' | grep -v 'VERSION_ID' | grep -v 'PRETTY_NAME' | cut -f2 -d=)
    echo -e  '\E[32m'"OS Version|"$reset$version >> $tempfile

    # Check Architecture
	arch=$(uname -m)
	echo -e '\E[32m'"Architecture|"$reset$arch >> $tempfile
    
	# Check Kernel Release
	kernel=$(uname -r)
	echo -e '\E[32m'"Kernel Release|"$reset$kernel >> $tempfile
    
	# Check hostname
	echo -e '\E[32m'"Hostname|"$reset$HOSTNAME >> $tempfile
    
	# Check Internal IP
	#internalip=$(hostname -I)
	#echo -e '\E[32m'"Internal IP|"$reset$internalip >> $tempfile
    
	# Check External IP
	#externalip=$(curl -s ipecho.net/plain;echo)
	#echo -e '\E[32m'"External IP|"$reset$externalip >> $tempfile
    
	# Check DNS
	nameservers=$(< /etc/resolv.conf sed '1 d' | awk '{print $2}')
	echo -e '\E[32m'"Name Servers|"$reset$nameservers >> $tempfile

    newline >> $tempfile
}

_cpu() {
    echo -e '\E[32m'"CPU|"$reset >> $tempfile
    lscpu | sed 's/^/ |/' >> $tempfile

    newline >> $tempfile
}

_diskusage() {
    echo -e '\E[32m'"Disk Usages|"$reset >> $tempfile
    df -h | sed 's/^/ |/' >> $tempfile

    newline >> $tempfile
}

_process() {
    echo -e '\E[32m'"Top 5 process|"$reset >> $tempfile
	ps auxf | sort -nr -k 4 | head -5 | sed 's/^/ |/' >> $tempfile

    newline >> $tempfile
}

## Main
DEBUG "Retrieve information"

_uptime

_loadaverage

_ramusage

_process

_arch

_cpu

_diskusage

DEBUG "Done\n"

# Print result in table format
column -t -s '|' $tempfile

# remove temporary file
DEBUG "Remove temp file '$tempfile'"
rm $tempfile

# Restore IFS
IFS=$SAVEIFS

# Exit
exit 0
