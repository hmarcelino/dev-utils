#!/bin/bash

# Call this and make this run in the background
# Don't forget to keep a variable the PID for
# this process.
function start_spinner(){
    delay=0.75
    spinstr='|/-\'

    while [ "true" ]; do
        temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
}

# Call this with the spinner PID
function stop_spinner(){
    printf "\b\b\b\b\b"

    kill $spinner_pid
    wait $spinner_pid 2>/dev/null
}
