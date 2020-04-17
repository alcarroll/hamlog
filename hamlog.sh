#! /bin/bash
function hambash()
{

########## CONFIG ###########
## Set your callsign
mycall="YOURCALLHERE"

####### END OF CONFIG #######
#DO NOT EDIT BELOW THIS LINE#
#############################

current_local=$(date +%Y%m%d_%H%M%)
current_utc=$(date --utc +%Y%m%d_%H%M)
currentcall=$(grep mycall ./.config | awk -F= '{print $2}')
currentcontest=$(grep contestname ./.config | awk -F= '{print $2}')
contestmodestatus="Disabled"
contestmodetype="Pounce"
contestrst="59"
contestname="None"
contestcqfreq="None"
contestseial="0"

usage="
(hambash) [ -l ] [-m] [-c] [-C] [-h n] -- display help for Hambash
where:
    -l log a contact 
    -m set your callsign
    -c set current contest 
    -C enable/disable contest mode
    -h 
"

if [ $# -eq 0 ]
  then
    printf "\nHambash requires arguments:\n\n$usage"
    else
    local OPTIND option
    while getopts ":lmc" option; do
     case $option in
        l) if [ "$contestmodestatus" == "Enabled" ] && [ "$contestmodetype" == "CQ" ]; then
                ### Contest CQ code
                # need to work in contact mode
                contacttime=$current_utc
                contactfreq=$contestcqfreq
                contactsendrst=$contestrst
                contactrcvrst=$contestrst
                contestserial=$($contestserial + 1)
                printf "\nYour serial: $contestserial\n"
                read -ep "Receive callsign: " contactrcvcall
                read -ep "\nReceive ARRL sec :" contactrcvsec
                read -ep "\nReceive class :" contactrcvclass
                ### Output to log code

            elif [ "$contestmodestatus" == "Enabled" ] && [ "$contestmodetype" == "Pounce" ]; then
                ### Contest Pounce code
                contacttime=$current_utc
                contactfreq=$contestcqfreq
                contactsendrst=$contestrst
                contactrcvrst=$contestrst
                contestserial=$($contestserial + 1)
                printf "\nYour serial: $contestserial\n"
                read -ep "Contact freq: " contactfreq
                read -ep "\nReceive callsign: " contactrcvcall
                read -ep "\nReceive ARRL sec: " contactrcvsec
                read -ep "\nReceive class: " contactrcvclass
                ### Output to log code

            elif [ "$contestmodestatus" == "Disabled" ]; then
                ### Non contest mode code
                contacttime=$current_utc
                read -ep "Contact freq: " contactfreq
                read -ep "\nReceive callsign: " contactrcvcall
                read -ep "\nReceive RST: " contactrcvrst
                read -ep "\nSend RST: " contactsendrst
                ### Output to log code

            else
                ### error handling
            fi ;;

        m) printf "\nYour callsign is currently set to: $currentcall\n"
            printf "1) Change callsign\n2)Keep current callsign\n"
            read -ep "Option: " changecall
            if [ "$changecall" == 1 ]
                read -ep "Enter new callsign: " newcall
                awk -i 's/mycall=$currentcall/mycall=$newcall/' ./.config
                currentcall=$newcall
                printf "Callsign set to $newcall"
            else
                printf "Callsign remains set to $currentcall"
            fi ;;
  
        c) printf "\nYour contest is currently set to: $currentcontest\n"
            printf "1) Change contest\n2)Keep current contest\n"
            read -ep "Option: " changecontest
            if [ "$changecontest" == 1 ]
                read -ep "Enter new contest: " newcontestname
                awk -i 's/contestname=$currentcontest/contest=$newcontestname/' ./.config
                currentcontest=$newcontestname
                printf "Callsign set to $currentcontest"
            else
                printf "Contest remains set to $currentcontest"
            fi ;;
  
        C) printf "\nContest mode is currently $contestmodestatus\n"
            printf "1) Enable contest mode\n2)Disable contest mode\n"
            read -ep "Option: " changeconteststatus
            if [ "$changeconteststatus" == 1 ]
                contestmodestatus="Enabled"
                printf "Contest mode desired:\n"
                read -ep "1) CQ Mode\n2) Search and Pounce Mode\n" changecontestmodetype
                    if [ "$contestmodetype" == "1" ]
                        contestmodetype="CQ"
                        read -ep "Freq you are working: " newcontestcqfreq
                        currentcqfreq=$(grep contestcqfreq ./.config | awk -F= '{print $2}')
                        awk -i 's/contestcqfreq=currentcqfreq/contestcqfreq=$newcontestcqfreq/' ./.config
                        contestrst="Enabled"
                        contestserial=0
                    else
                        contestmodetype="Pounce"
                        contestrst="Enabled"
                        contestserial=0
                    fi
            else
                contestmodestatus="Disabled"
                printf "Contest mode disabled\n"
                contestrst="Disabled"
            fi ;;
       \?) echo -e "\nInvalid option:\n" >&2
           echo "$usage" >&2 ;;
     esac
done
fi
}