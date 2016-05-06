#!/bin/bash

INFO="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
NOCOLOR="\033[0m"

function print_info {
    printf "${INFO}%s${NOCOLOR}" "$1"
}

function print_success {
    printf "${GREEN}%s${NOCOLOR}" "$1"
}

function print_warning {
    printf "${YELLOW}%s${NOCOLOR}" "$1"
}

function print_error {
    printf "${RED}%s${NOCOLOR}"
}


function println {
    echo -e "$1$2${NOCOLOR}"
}

function println_info {
    echo -e "${INFO}$1${NOCOLOR}"
}

function println_success {
    echo -e "${GREEN}$1${NOCOLOR}"
}

function println_warning {
    echo -e "${YELLOW}$1${NOCOLOR}"
}

function println_error {
    echo -e "${RED}$1${NOCOLOR}"
}
