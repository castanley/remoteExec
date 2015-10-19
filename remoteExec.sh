#!/bin/bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Script Name:  remoteExec.sh
# Script Desc:  Launch commands to remote machines
# Script Date:  9-01-15
# Created By:   Christopher Stanley
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

user="cstanley@"
hosts=`cat server.list`

hList()
{
    echo "Please provide path to host list, followed by [ENTER]:"
    read hList
    hosts=`cat $hList`
    menu
}

checkQ()
{
    if [ "$1" == "q" ]; then
        menu #Go back to menu
    fi
}

testCon()
{
echo "---------- Connecting to $i ----------" | tee -a resizeDisk.log
        tmp=$(ssh -tt -q -o StrictHostKeyChecking=no -o ConnectTimeout=1 "$user""$i" "uname")

        if [[ $tmp == *"Linux"* ]]; then
                echo "[$(date +%D_%T)] Successfully Connected to $i" >> resizeDisk.log
        else
                echo "[$(date +%D_%T)] Could not connect to $i - Connection failed" | tee -a resizeDisk.log
                menu #Go back to menu
        fi
}

singExec()
{
    singExecCmd()
    {

        echo "Please type your command, followed by [ENTER]: (Input q to go back)"
        read cmd

        checkQ $cmd #Check if Q is inputed, if so go bach to menu

        testCon #Test Connection
        tmp=$(ssh -tt -q -o StrictHostKeyChecking=no -o ConnectTimeout=1 "$user""$i" \"\"$cmd\"\")
        echo "$tmp"
        echo ""

        singExecCmd
    }
    echo "Please provide server hostname, followed by [ENTER]: (Input q to go back)"
    read i

    checkQ $i #Check if Q is inputed, if so go bach to menu

    singExecCmd

}

vgDisp()
{
        for i in $hosts
        do
                testCon #Test Connection
                tmp=$(ssh -tt -q -o StrictHostKeyChecking=no -o ConnectTimeout=1 "$user""$i" "sudo vgdisplay")
                echo "$tmp" | grep Free | awk {'print $7 " " $8'}
        done
        menu #Go back to menu
}

clusExec()
{
        echo "Please type your command, followed by [ENTER]: (Input q to go back)"
        read cmd

        checkQ $cmd #Check if Q is inputed, if so go bach to menu

        for i in $hosts
        do
                testCon #Test Connection
                tmp=$(ssh -tt -q -o StrictHostKeyChecking=no -o ConnectTimeout=1 "$user""$i" \"\"$cmd\"\")
                echo "$tmp"
        done

        clusExec
}

menu()
{
        OPTIONS="host_list single cluster exit"
        select opt in $OPTIONS; do
                if [ "$opt" = "host_list" ]; then
                 hList #Call cgDisp Function
                elif [ "$opt" = "single" ]; then
                 singExec #Call cgDisp Function
                elif [ "$opt" = "cluster" ]; then
                 clusExec
                 exit
                elif [ "$opt" = "exit" ]; then
                 echo Exitting
                 exit
                else
                 clear
                 echo bad option
                fi
        done
}
menu
