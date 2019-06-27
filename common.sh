#!/bin/bash
##################################################################
# Author: Swapnil Mhamane <swapnilgmhamane@gmail.com>
# Purpose: Bash Helper functions and utility.
# Usage:
#       source common.sh
# Description:
#   This script is collection of commonaly required
#   helper/utility function for writing bash script.
##################################################################

##################################################################
#                         CONSTANTS                              #
##################################################################
# Types constants
declare -r TRUE=0
declare -r FALSE=1

# Style constants
declare -r bold=$(tput bold)
declare -r underline=$(tput sgr 0 1)
declare -r reset=$(tput sgr0)

# Color constants
declare -r purple=$(tput setaf 171)
declare -r red=$(tput setaf 1)
declare -r green=$(tput setaf 2)
declare -r yellow=$(tput setaf 3)
declare -r blue=$(tput setaf 4)
declare -r white=$(tput setaf 7)

# Config file constants
declare -r PASSWD_FILE=/etc/passwd
##################################################################

##################################################################
#                       HEADERS AND LOGGING                      #
##################################################################

function header() {
    printf "\n${bold}${purple}==========  %s  ==========${reset}\n" "$@"
}

function new_line() {
    echo ""
}

function arrow() {
    printf "➜ $@\n"
}

function success() {
    printf "${green}[ ✔ ] %s${reset}\n" "$@"
}

function error() {
    printf "${red}[ ✘ ] %s${reset}\n" "$@"
}

function warn() {
    printf "${yellow}[ 🔔 ] %s${reset}\n" "$@"
}

function underlined() {
    printf "${underline}${bold}%s${reset}\n" "$@"
}

function bold() {
    printf "${bold}%s${reset}\n" "$@"
}

function note() {
    printf "${underline}${bold}${blue}Note:${reset} ${blue}%s${reset}\n" "$@"
}

function separator(){
    local char="*"
    local line
    for i in $(seq 1 80); do
        line="${line}${char}"
    done
    echo "${line}"
}

function banner_mid() {
    echo "* $* *"
}

function banner_border() {
    banner_mid "$*" | sed 's/./*/g'
}

function banner() {
    banner_border "$*"
    banner_mid "$*"
    banner_border "$*"
}

# header "Styles and formates"
# arrow "This is arrowed statement."
# new_line
# success "Tests succeded."
# error "Tests error."
# warn "This is warning."
# note "This is note."
# banner "This is banner."

##################################################################

##################################################################
#                       STRING UTILITY                           #
##################################################################
# Purpose:
#   Converts a string to lower case.
# Arguments:
#   $1 -> String to convert to lower case
# Return:
#   output <- lower case string
function to_lower()
{
    local str="$@"
    local output
    output=$(tr '[A-Z]' '[a-z]'<<<"${str}")
    echo $output
}
##################################################################
# Purpose:
#   Converts a string to upper case.
# Arguments:
#   $1 -> String to convert to upper case
# Return:
#   output <- uppercase string
function to_upper()
{
    local str="$@"
    local output
    output=$(tr '[a-z]' '[A-Z]'<<<"${str}")
    echo $output
}
##################################################################

##################################################################
#                   ERROR HANDLING                               #
##################################################################
# Purpose: Display an error message and die.
# Arguments:
#   $1 -> Message
#   $2 -> Exit status (optional)
function die()
{
    local m="$1"	# message
    local e=${2-1}	# default exit status 1
    error "$m"
    exit $e
}
##################################################################

##################################################################
#                       MISSELLENEOUS                            #
##################################################################
# Purpose: Return true $user exists in /etc/passwd.
# Arguments:
#   $1 -> Username to check in /etc/passwd
# Return:
#   output <- True or False
# Usage:
#   if is_user_exists; then
#       some action
#   else
#       some other action
#   fi
function is_user_exists()
{
    local u="$1"
    grep -q "^${u}" $PASSWD_FILE && return $TRUE || return $FALSE
}
##################################################################
# Purpose: Test which OS the user runs
# Arguments:
#   $1 -> OS to test
# Return:
#   output <- True or False
# Usage:
#   if is_os 'darwin'; then
#       macos specfic action
#   fi
function is_os()
{
    if [[ "${OSTYPE}" == $1* ]]; then
        return $TRUE
    fi
    return $FALSE
}
##################################################################

##################################################################
#                             INPUT                              #
##################################################################
# Purpose: Get the confirmation from user to proceed further.
# Arguments:
#   $1->  Message
# Return:
#   output <- True or False
# Usage:
#   if get_confirmation $msg; then
#       some action
#   else
#       some other action
#   fi
function get_confirmation()
{
    local msg=$1
    local confirm
    read -p "${bold}$msg, confirm[${green}y${white}/${red}n${white}]?${reset} " confirm
    if [[ "$confirm" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        return $TRUE
    fi
    return $FALSE
}

# if get_confirmation; then
#     success "Confiremd."
# else
#     error "Not confirmed."
# fi
##################################################################
# Purpose: User must confirm else die.
# Arguments:
#   $1 -> Message
function must_confirm()
{
    local msg=$1
    if get_confirmation "$msg"; then
        return
    fi
    exit 0
}
##################################################################


##################################################################
#                        SHELL COMMAND                           #
##################################################################
# Purpose: Return True if command exists
# Arguments:
#   $1 -> cmd to test
# Return:
#   output <- True or False
# Usage:
#   if type_exists 'git'; then
#       some action
#   else
#       some other action
#   fi
function type_exists()
{
    if [ $(type -P $1) ]; then
    return $TRUE
    fi
    return $FALSE
}
##################################################################

##################################################################
#                           TODO                                 #
##################################################################
# Add flag
# Add subcommand

# usage="$(basename "$0") [-h] [-s n] -- program to calculate the answer to life, the universe and everything

# where:
#     -h  show this help text
#     -s  set the seed value (default: 42)"

# seed=42
# while getopts ':hs:' option; do
#   case "$option" in
#     h) echo "$usage"
#        exit
#        ;;
#     s) seed=$OPTARG
#        ;;
#     :) printf "missing argument for -%s\n" "$OPTARG" >&2
#        echo "$usage" >&2
#        exit 1
#        ;;
#    \?) printf "illegal option: -%s\n" "$OPTARG" >&2
#        echo "$usage" >&2
#        exit 1
#        ;;
#   esac
# done
# shift $((OPTIND - 1))
##################################################################