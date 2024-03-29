#!/bin/bash
# Author: lostsh
# description: Use telnet and dig to check if given email is in records

help(){
    if [ $# -gt 0 ]; then
        echo -e "\t[ ! ] $1\n"
    fi
    echo -e "\t[ = ] Help page"
    echo -e "\t$0 -h --help \t\t Display this help page"
    echo -e "\t$0 --init-env \t C"
    echo -e "\t$0 --conf-mail [args]\t Inst"
    echo -e "\t\t[args]: \t "
    echo -e "\t$0 --packages \t Ch"
    echo -e "\n\tInfo: anti-spam protection ..."
    echo
}

## Get the mx server from a given domain
get_mx_server(){
    dig -t MX $1 +dnssec +short | cut -d' ' -f2 | head -n1
}

## Check if user $2 exist on server $1
check_email_on_server(){
{
    echo "open $1 25"
    sleep 1
    echo "helo hi"
    sleep 0.5
    echo "mail from: <$2>"
    sleep 1
    echo "rcpt to: <$2>"
    sleep 1
    echo "^]"
    echo "quit"
} | telnet
}

## default mx server is gmail
server_mx="gmail-smtp-in.l.google.com"

# check if given email ($1) is in records
check_email(){
    email_address=$1
    #regex {var#*@}: remove all chars before the @
    domain=${email_address#*@}
    mx_server="$(get_mx_server $domain)"
    check_email_on_server $mx_server $email_address
}

# parse the piped input into short format
## if given $1 and $2 are respectively
## valid and invalid chars for output
parse_check_email(){
    # setting the output characters
    char_ok="O"
    char_ko="X"
    if [ -n "$1" ] && [ -n "$2" ]; then
        char_ok="$1"
        char_ko="$2"
    fi

    # gathering input from pipe
    telnet_out=""
    while read pipe_in; do
        telnet_out="$telnet_out\n$pipe_in"
    done

    # parsing the output
    #echo -e $telnet_out | grep -e "^2..[[:space:]]2" -e "^5.."
    echo -e $telnet_out | grep "^5.." >/dev/null
    if [ $? -eq 0 ]; then
        # find code 500: email is not in records
        echo "$char_ko"
    else
        resp_code="$(echo -e $telnet_out | grep '^2..[[:space:]]2' | wc -l)"
        if [ $resp_code -gt 1 ]; then
            # mean there are two OK so email is valid
            echo "$char_ok"
        else
            # Unhandled behavior
            echo -ne "\t[ ! ] Parsing telnet out went wrong\n"
            echo "Exception: unhandled tenet output" >&2
        fi
    fi
}

##########
## Main ##
##########
if [ $# -lt 1 ]; then
    #help "No arguments provided"
    while read input_email; do
        #echo -ne "$input_email\t\t"
        #check_email $input_email 2>&1 | parse_check_email "🙂" "😨"
        email_valid="$(check_email $input_email 2>&1 | parse_check_email '🙂' '😨')"
        printf "%s\t%s\n" $input_email $email_valid | expand -t 40
    done
fi

while [ -n "$1" ]; do
    case $1 in
        "-h" | "--help")
            help
        ;;
        "-e" | "--email")
            echo -ne "\t[ + ] Checking email  (on: $server_mx)\n"
            if [ -z "$2" ]; then echo -e "\t[ ! ] Email not provided.\nBy\n"; exit 1; fi;
            check_email_on_server $server_mx $2
            shift
            ;;
        "-s" | "--mx-server")
            server_mx="$2"
            echo -e "\t[ > ] Mail server is: $server_mx"
            shift
        ;;
        "-d" | "--domain")
            echo -ne "\t[ + ] Gathering MX record from domain\n"
            mx_record="$(get_mx_server $2)"
            if [ -n "$mx_record" ]; then
                server_mx="$mx_record"
                echo -ne "\t[ > ] Mail server is: $server_mx\n"
            else
                echo -ne "\t[ < ] Mail server not found on domain\n"
            fi
            shift
        ;;
        *"@"*"."*)
	        #echo -ne "\t[ ! ] Not implemented yet\n" >&2
	        echo -ne "\t[ ¤ ] Querying mail server\n"
	        check_email $1
            ;;
        *)
            help "Wrong argument $1"
        ;;
    esac
    shift #next argument
done