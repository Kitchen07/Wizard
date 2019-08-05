#!/usr/bin/bash
#

## This Function reads commands from the file and executes line by line
exp_call() {
        HST="$1" USER="$2" PASSWORD="$3" expect -c '
#set timeout 5

set fp [open "commands.txt"]
set commands [split [read $fp] "\n"]
close $fp

    spawn -noecho ssh -o StrictHostKeyChecking=no -l $env(USER) $env(HST)
    expect "assword:"
    send "$env(PASSWORD)\r"
    foreach cmd $commands {
        expect "$"
        send "$cmd\r"
        expect "#"
        send "\r"
    }

    expect "#"
    send "exit\r"
    expect eof
'
}

#### The Main program starts here.

clear

logfile="output_`date +%d-%m-%Y-%H-%M`.log"                           # This File contains the Standards Output (same as the scree) redirected in to it.
statfile="status_`date +%d-%m-%Y-%H-%M`.csv"                          # This File  will hold the list of the Devices with the STATUS as Success / Fail.

### Accepts the User Credentials of the devices to Login.
#
echo -e "\n\nInput Your AD Credentials here to Log into the Devices:\n-------------------------------------------------------\n"
echo -n "Enter your USER NAME for SSH: "
read -e USER
echo -n "Enter your password for SSH: "
read -s -e PASSWORD
echo -en "\nEnter your file with a list of Hosts : "
read -e INPUTLIST

clear
date +"%d-%m-%Y" > $logfile

for host in `cat $INPUTLIST`; do
    echo -e "\n\n****************************** \n ## Device -> $host \n******************************\n"
    ping -q -c2 $host > /dev/null
    if [ $? -eq 0 ]
       then
          exp_call $host $USER $PASSWORD
          echo "$host, Success" >> $statfile
    else
          echo -e $host "Not Pingable, Please check if the Device is Up....\n"
          echo "$host, Unreachable" >> $statfile
    fi
done | tee -a $logfile
echo -e "ALL THE DEVICES FINISHED .... END OF THE PROGRAM...\n" | tee -a $logfile




