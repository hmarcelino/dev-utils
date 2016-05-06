#!/bin/bash

function get_confirmation {
    read -p "Are you sure you want to $1? Enter 'y': " conf_val

    case $conf_val in
        [yY] )  ;;
        *) printInfo "Aborting..."; exit 9;;
    esac
}

function get_password {
  local password=""

  stty -echo
  read password
  stty echo

  echo $password
}
