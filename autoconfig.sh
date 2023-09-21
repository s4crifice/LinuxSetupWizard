#!/bin/bash

# Function to handle interrupt signals (e.g., Ctrl+C)
handle_interrupt() {
    echo -e "${RED}${BOLD}\nScript interrupted...\n${RESET}${RESET}"
    exit 1
}

# Set up interrupt signal handling
trap handle_interrupt SIGINT

# ASCII art text for display
ascii_art="
Made by:
 ___      ___ _______      ___    ___ ________  ________     
|\  \    /  /|\  ___ \    |\  \  /  /|\   __  \|\   __  \    
\ \  \  /  / | \   __/|   \ \  \/  / | \  \|\  \ \  \|\  \   
 \ \  \/  / / \ \  \_|/__  \ \    / / \ \  \\\  \ \   _  _\  
  \ \    / /   \ \  \_|\ \  /     \/   \ \  \\\  \ \  \\  \| 
   \ \__/ /     \ \_______\/  /\   \    \ \_______\ \__\\ _\ 
    \|__|/       \|_______/__/ /\ __\    \|_______|\|__|\|__|                                                                                                                                                 
"

# Define color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

# Set default sleep duration
SLEEP_DURATION=${SLEEP_DURATION:=1}

# Function to display a progress bar
progress-bar() {
    local duration
    local columns
    local space_available
    local fit_to_screen  
    local space_reserved

    space_reserved=6
    duration=${1}
    columns=$(tput cols)
    space_available=$(( columns-space_reserved ))

    if (( duration < space_available )); then 
        fit_to_screen=1; 
    else 
        fit_to_screen=$(( duration / space_available )); 
        fit_to_screen=$((fit_to_screen+1)); 
    fi

    already_done() { for ((done=0; done<(elapsed / fit_to_screen) ; done=done+1 )); do printf "▇"; done }
    remaining() { for (( remain=(elapsed/fit_to_screen) ; remain<(duration/fit_to_screen) ; remain=remain+1 )); do printf " "; done }
    percentage() { printf "| %s%%" $(( ((elapsed)*100)/(duration)*100/100 )); }
    clean_line() { printf "\r"; }

    for (( elapsed=1; elapsed<=duration; elapsed=elapsed+1 )); do
        already_done; remaining; percentage
        sleep "$SLEEP_DURATION"
        clean_line
    done
    clean_line
}

# Function to update and upgrade packages
update_upgrade() {
    local null_path="$1"
    apt-get update >> "$null_path"
    apt-get upgrade -y >> "$null_path"
}

# Function to install VirtualBox guest additions
vb_guest_additions() {
    local null_path="$1"
    apt-get install -y virtualbox-guest-utils >> "$null_path"
}

# Function to install various tools
tools() {
    local null_path="$1"
    apt-get install -y seclists curl dnsrecon enum4linux feroxbuster gobuster impacket-scripts nbtscan nikto nmap onesixtyone oscanner >> "$null_path"
    apt-get install -y redis-tools smbclient smbmap snmp sslscan sipvicious tnscmd10g whatweb wkhtmltopdf docker.io docker-compose >> "$null_path"
}

# Ask the user if they want to start the automated configuration
echo "Start automated configuration? (Y/N)"
read ans

c="/dev/null"

# Check the user's response
if [[ "$ans" == "Y" || "$ans" == "y" || "$ans" == "Yes" || "$ans" == "yes" ]]; then
    clear
    echo -e "$ascii_art"
    echo -e "${BOLD}Automated configuration started${RESET}"

    # Execute update and upgrade, displaying a progress bar
    if update_upgrade "$c"; then
        progress-bar "25"
        echo -e "${GREEN}Update and upgrade completed!${RESET}"
        echo ""
    else
        echo -e "${RED}Error in function 1${RESET}"
    fi

    # Execute VirtualBox guest additions installation, displaying a progress bar
    if vb_guest_additions "$c"; then
        progress-bar "9"
        echo -e "${GREEN}VB additions completed!${RESET}"
        echo ""
    else
        echo -e "${RED}Error in function 2${RESET}"
    fi

    # Execute tools installation, displaying a progress bar
    if tools "$c"; then
        progress-bar "17"
        echo -e "${GREEN}Tools installation completed!${RESET}"
        echo ""
    else
        echo -e "${RED}Error in function 3${RESET}"
    fi

    echo -e "${BOLD}Automated configuration completed${RESET}"

fi

# Check if the user chose not to start the automated configuration
elif [[ "$ans" == "N" || "$ans" == "n" || "$ans" == "No" || "$ans" == "no" ]]; then
    echo -e "${RED}${BOLD}Script terminated${RESET}${RESET}"
else
    echo -e "${ORANGE}${BOLD}Wrong input${RESET}"
fi
