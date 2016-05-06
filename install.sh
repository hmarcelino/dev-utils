#!/bin/bash

INSTALLER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $INSTALLER_DIR/share/utils/print.sh

SUB="dev"
CMD=.bash_profile
if [ ! -f ~/"$CMD" ]; then
    CMD=.bashrc
fi

echo 
println $YELLOW "============================================="
println $YELLOW "Installing $SUB utils commands"
println $YELLOW "============================================="

# A check for jenkins. He doesn't have access to the shell.
if [[ -n `grep "$SUB init" ~/$CMD` ]]; then
    echo "$SUB commands are already installed in your $CMD"

else
    if command -v $SUB | grep "$SUB" &>/dev/null ; then
       echo "$SUB commands are already installed in your $CMD"
       echo
    else
       echo "installed $SUB commands, have fun!"
       echo 'eval "$('$INSTALLER_DIR'/bin/'$SUB' init -)"' >> ~/$CMD
    fi
fi


printf "Set AWS Credentials [y/n] ? [y] "
read set_credentials

if [[ $set_credentials == "y" || $set_credentials == "" ]]; then

    printf "AWS Access Key Id: "
    read aws_access_key_id

    printf "AWS Secret Access Key: "
    read aws_secret_access_key

    echo "" > $INSTALLER_DIR/share/aws/credentials
    echo "aws_access_key_id = $aws_access_key_id" >> $INSTALLER_DIR/share/aws/credentials
    echo "aws_secret_access_key = $aws_secret_access_key" >> $INSTALLER_DIR/share/aws/credentials

    echo ""
    println_success "AWS credentials successfully stored in:"
    echo "  >>> $INSTALLER_DIR/share/aws/credentials"
    echo ""
else

    echo "Skipping aws credentials setup"
    echo ""

fi

$INSTALLER_DIR/bin/$SUB doctor
echo ""
