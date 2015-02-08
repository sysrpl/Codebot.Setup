#!/bin/sh
# Author of this script: http://www.getlazarus.org
# This is the universal Linux script to install Free Pascal and Lazarus

# If you need to fix something and or want to contribute, send your 
# changes to admin at getlazarus dot org with "linux free pascal install"
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
echo "This is the universal Linux script to install Free Pascal and Lazarus test"
echo "--------------------------------------------------------------------------"
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
		echo "done."
		echo 
		exit 1
		;;
esac

# Ask for permission to create a local application shortcut
echo "After install do you want to Lazarus shortcut created a in:"
read -r -p "$HOME/.local/share/applications (y/n)? " SHORTCUT
echo 

# Block comment for testing
: <<'COMMENT'
COMMENT

# Exit the script if $BASE folder already exist
if [ -d "$BASE" ]; then
	echo "Folder \"$BASE\" already exists"
	echo 
	echo "Delete this folder or change the variable BASE in this script"
	echo "Then re-run this script"
	echo 
	echo "done."
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

# Note we use our bucket instead of sourceforge or svn for the following 
# reason: 
#   It would be unethical to leach other peoples bandwidth and data
#   transfer charges. As such, we rehost the same fpc stable binary, fpc 
#   test sources, and lazarus test sources from sourceforge and free
#   pascal svn servers using our own Amazon S3 bucket.

# Download from our Amazon S3 bucket 
URL=http://cache.getlazarus.org/archives

# Download a temporary version of fpc stable
wget -P $BASE $URL/fpc-$FPC_STABLE.$CPU-linux.7z
7za x $BASE/fpc-$FPC_STABLE.$CPU-linux.7z -o$BASE
rm $BASE/fpc-$FPC_STABLE.$CPU-linux.7z

# Add fpc stable to our path
OLDPATH=$PATH
export PPC_CONFIG_PATH=$BASE/fpc-$FPC_STABLE/bin
export PATH=$PPC_CONFIG_PATH:$OLDPATH

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
# Make cross compilers
if [ "$CPU" = "i686" ]
then
	make crossinstall OS_TARGET=linux CPU_TARGET=x86_64 INSTALL_PREFIX=$BASE/fpc
else
	make crossinstall OS_TARGET=linux CPU_TARGET=i386 INSTALL_PREFIX=$BASE/fpc	
fi
make crossinstall OS_TARGET=win32 CPU_TARGET=i386 INSTALL_PREFIX=$BASE/fpc
make crossinstall OS_TARGET=win64 CPU_TARGET=x86_64 INSTALL_PREFIX=$BASE/fpc
cp $BASE/fpc/lib/fpc/$FPC_BUILD/* $BASE/fpc/bin

# Delete the temporary version of fpc stable
# TODO Consider leaving fpc stable in place to build cross compilers
rm -rf $BASE/fpc-$FPC_STABLE

# Add the compiler we just built to our paths
export PPC_CONFIG_PATH=$BASE/fpc/bin
export PATH=$PPC_CONFIG_PATH:$OLDPATH

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
replace "$BASE/lazarus" "lazarus.desktop" "Version=$LAZ" ""
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

# Install an application shortcut
case $SHORTCUT in
    [yY][eE][sS]|[yY]) 
		if type desktop-file-install > /dev/null; then
			desktop-file-install --dir="$HOME/.local/share/applications" "$BASE/lazarus.desktop"
		else
			cp "$BASE/lazarus.desktop" "$HOME/.local/share/applications"
		fi
		echo
		;;
    *)
		echo 
		;;
esac

# Install complete
xdg-open "http://www.getlazarus.org/installed/?platform=linux" &> /dev/null;
echo "Free Pascal and Lazarus install complete"
echo 

# Start up our new lazarus
./lazarus
