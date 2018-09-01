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
source ../../log4sh/script/log4.sh -v INFO # -d "+%Y-%m-%d %H:%M:%S" # use -f $__file for log

## Clear the screen
clear

DEBUG "__dir  = "$__dir
DEBUG "__file = "$__file
DEBUG "__base = "$__base
DEBUG "__root = "$__root

tempfile=.sysinfolog

## Utils
newline() {
  echo "|"
}

## OS info

## RAM usage
_ramusage() {
 free -h | grep -v + >> .sysinfologtemp 
 # header
 echo -e "Memory Usages| Total|Used |Free" >> $tempfile
 cat .sysinfologtemp | grep "Mem" | awk '{print " Ram | "$2 "|" $3 "|" $4}' >> $tempfile
 #echo -e "Swap Usages| Total|Used |Free" >> $tempfile
 cat .sysinfologtemp | grep "Swap" | awk '{print " Swap | "$2 "|" $3 "|" $4}' >> $tempfile
 rm .sysinfologtemp
 newline >> $tempfile
}
## File System

## Check System Uptime
_uptime() {
  uptime=$(uptime | awk '{print $3,$4}' | cut -f1 -d,)
  echo "System Uptime Days/(HH:MM)| "$uptime >> $tempfile
  newline >> $tempfile
}

## Load average
_loadaverage() {
  loadaverage=$(top -n 1 -b | grep "load average:" | awk '{print $11 $12 $13}')
  echo -e "Load Average|" $loadaverage >> $tempfile
  newline >> $tempfile
}

## Main
# retrieve all info
_uptime

_loadaverage

_ramusage

# Print result in table format
column -t -s '|' $tempfile

# remove temporary file
DEBUG "Remove temp file '$tempfile'"
rm $tempfile

# Restore IFS
IFS=$SAVEIFS

# Exit
exit 0
