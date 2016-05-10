echo ""
echo "Version: $version"
echo ""
echo "Starting Installation process"

basedir="/opt/$project"
finaldir="$basedir/$project-$version"

# Check the existence of the init.d file
# and in case does not exist copy the init.d
# project script file and register it to the
# correct start ing levels.
if [[ ! -f "/etc/init.d/$project" ]]; then
    sudo bash -c "cat $PWD/etc/init.d/$project | sed "s/{{USER}}/$USER/g" > /etc/init.d/$project"
    sudo chmod u+x /etc/init.d/$project
    sudo chkconfig --add $project
fi

# Check the existence of the log directory
# In case does not exist create one
if [[ ! -d "/var/log/$project" ]]; then
    sudo mkdir /var/log/$project
    sudo chown -R $USER /var/log/$project
fi

# Check the existence of the global directory
# All configuration files under this directory
# will not be overwritten in future installations
if [[ ! -d "/etc/$project" ]]; then
    sudo mkdir /etc/$project
    sudo chown -R $USER /etc/$project
fi

if [[ -d $PWD/etc/$project/ ]]; then
    cp -n "$PWD"/etc/$project/* /etc/$project/
fi

# Check if it is a new installation
if [[ ! -d $basedir ]]; then
    echo "No previous installation found. Starting a new one"
    sudo mkdir $basedir
    sudo chown -R $USER $basedir

    if [[ "$?" != "0" ]]; then
        echo "Couldn't create \"$basedir\" directory."
        echo "Stopping installation process"
        exit 1
    fi
else
    echo "A previous instalation was found. Updating $project"
    echo "Stopping current instance"
    sudo /etc/init.d/$project stop
fi

echo "Copying project $project v: $version to $basedir"
rm -rf $finaldir
cp -R $PWD/$project-$version $finaldir
cat $finaldir/bin/start.sh | sed "s/{{VERSION}}/$version/g" > $finaldir/bin/start.tmp.sh
rm $finaldir/bin/start.sh
mv $finaldir/bin/start.tmp.sh $finaldir/bin/start.sh
chmod u+x $finaldir/bin/start.sh

echo "Updating $project link"
rm -f $basedir/current
ln -s $finaldir $basedir/current

echo "Starting $project"
sudo /etc/init.d/$project start

echo "$project installation finished"
