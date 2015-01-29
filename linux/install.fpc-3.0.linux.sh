#!/bin/sh
# This is the universal Linux script to install Free Pascal and Lazarus

# If you need to fix something and or want to contribute, send your 
# changes to sysrpl at codebot dot org with "linux free pascal install"
# in the subject line.

# Change the line below to define your own install folder
BASE=$HOME/Development/FreePascal

# BASE can be whatever you want, but it should:
#   A) Be under your $HOME folder
#   B) Not already exist

# TODO Prompt the user for the install folder and provide BASE as the default

# Define our Free Pascal and Lazarus versions numbers
FPC=3.0
LAZ=1.4

# The full version number of the stable compiler and the one we are building
FPC_STABLE=2.6.4
FPC_BUILD=3.0.1

# TODO Allow the user to pick their compiler and ide versions

# Prevent this script from running as root 
if [ "$(id -u)" = "0" ]; then
   echo "This script should not be run as root"
   exit 1
fi

# function require(program) 
require() {
	if ! type "$1" > /dev/null; then
		echo "  $1 not found"
		echo 
		echo "An error occured"
		echo 
		echo "This script requires the program $1 which was not found on your system"
		echo 
		echo "On Debian or Ubuntu type the following to install $1:"
		echo "  sudo apt-get install $2"
		echo "Then re-run this script"
		echo 
		echo "On other distributions refer to your package manager"
		echo 
		exit 1
	fi	
	echo "  $1 found"
}

# Require the following programs 
require "make" "build-essential"
require "patch" "patch"
require "wget" "wget"
require "7za" "p7zip-full"

# TODO Provide missing program install command help based on current distro

# Present a description of this script
clear
echo "This is the universal Linux script to install Free Pascal and Lazarus"
echo "---------------------------------------------------------------------"
echo
echo "It will download the sources for:"
echo "  Free Pascal $FPC"
echo "  Lazarus $LAZ"
echo
echo "Then build working versions in folder:"
echo "  $BASE"
echo
echo "To uninstall, simply type:"
echo "  rm -rf $BASE"
echo
echo "This script will not interfere with your existing development environment"
echo

# Ask for permission to proceed
read -r -p "Continue (y/n)? " REPLY

case $REPLY in
    [yY][eE][sS]|[yY]) 
		echo
		;;
    *)
		# Exit the script if the user does not type "y" or "Y"
		echo "Aborting script"
		echo 
		exit 1
		;;
esac

# Exit the script if $BASE folder already exist
if [ -d "$BASE" ]; then
	echo "Folder \"$BASE\" already exists"
	echo "Aborting script"
	echo 
	exit 1
fi

# Create our install folder
mkdir $BASE
cd $BASE

# Determine operating system architecture
CPU=$(uname -m)

if [ "$CPU" = "i686" ]
then
	CPU="i386"
fi

# Download from my Amazon S3 bucket as a courtesy to others
URL=http://cache.codebot.org/lazarus

# Download a temporary version of fpc stable
wget -P $BASE $URL/fpc-$FPC_STABLE.$CPU-linux.7z
7za x $BASE/fpc-$FPC_STABLE.$CPU-linux.7z -o$BASE
rm $BASE/fpc-$FPC_STABLE.$CPU-linux.7z

# Add fpc stable to our path
export PPC_CONFIG_PATH=$BASE/fpc-$FPC_STABLE/bin
OLDPATH=$PATH
PATH=$OLDPATH:$PPC_CONFIG_PATH

# Generate a valid fpc.cfg file
$PPC_CONFIG_PATH/fpcmkcfg -d basepath=$BASE/fpc-$FPC_STABLE/lib/fpc/\$FPCVERSION -o $PPC_CONFIG_PATH/fpc.cfg

# Download the new compiler source code
wget -P $BASE $URL/fpc-$FPC.7z
7za x $BASE/fpc-$FPC.7z -o$BASE
rm $BASE/fpc-$FPC.7z

# Make the new compiler
cd $BASE/fpc
make all
make install INSTALL_PREFIX=$BASE/fpc
cp $BASE/fpc/lib/fpc/$FPC_BUILD/* $BASE/fpc/bin

# Delete the temporary version of fpc stable
# TODO Consider leaving fpc stable in place to build cross compilers
rm -rf $BASE/fpc-$FPC_STABLE

# Add the compiler we just built to our paths
PPC_CONFIG_PATH=$BASE/fpc/bin
PATH=$OLDPATH:$PPC_CONFIG_PATH

# Generate another valid fpc.cfg file
$PPC_CONFIG_PATH/fpcmkcfg -d basepath=$BASE/fpc/lib/fpc/\$FPCVERSION -o $PPC_CONFIG_PATH/fpc.cfg

# Download the lazarus source code
wget -P $BASE $URL/lazarus-$LAZ.7z
7za x $BASE/lazarus-$LAZ.7z -o$BASE
rm $BASE/lazarus-$LAZ.7z
cd $BASE/lazarus

# function replace(folder, files, before, after) 
replace() {
	BEFORE=$(echo "$3" | sed 's/[\*\.]/\\&/g')
	BEFORE=$(echo "$BEFORE" | sed 's/\//\\\//g')
	AFTER=$(echo "$4" | sed 's/[\*\.]/\\&/g')
	AFTER=$(echo "$AFTER" | sed 's/\//\\\//g')
	find "$1" -name "$2" -exec sed -i "s/$BEFORE/$AFTER/g" {} \;
}

# Original location
ORIGIN="/home/delluser/Development/Base"

# Replace paths from their original location to the new one
replace "$BASE/lazarus/config" "*.xml" "$ORIGIN" "$BASE"
replace "$BASE/lazarus" "lazarus.sh" "$ORIGIN" "$BASE"
replace "$BASE/lazarus" "lazarus.desktop" "$ORIGIN" "$BASE"
mv $BASE/lazarus/lazarus.desktop $BASE/lazarus.desktop

# Apply a patch, see changes.patch for details
patch -p0 -i $BASE/lazarus/changes.diff

# Make the new lazarus
make all

# Install anchor docking in the ide
./lazbuild ./components/anchordocking/design/anchordockingdsgn.lpk
make useride

# Strip down the new programs
strip -S lazarus
strip -S lazbuild
strip -S startlazarus

# Restore our path
PATH=$OLDPATH

# Install complete
echo "Installation complete"
echo 

# Start up our new lazarus
./lazarus