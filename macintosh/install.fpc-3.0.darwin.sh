#!/bin/sh
# This is the universal OSX script to install Free Pascal and Lazarus

# If you need to fix something and or want to contribute, send your 
# changes to sysrpl at codebot dot org with "osx free pascal install"
# in the subject line.

# Change the line below to define your own install folder
BASE="$HOME/Development/FreePascal"

# BASE can be whatever you want, but it should:
#   A) Be under your $HOME folder
#   B) Not already exist

# TODO Prompt the user for the install folder and provide BASE as the default

# Prevent this script from running as root
if [ "$(id -u)" = "0" ]; then
   echo "This script should not be run as root"
   exit 1
fi

FPC="3.0"
OS_TARGET="darwin"
OS_VERSION=$(sw_vers -productVersion | awk -F "." '{print $2}')

# Add port commands to the path if it's not already there
if [[ ! "$PATH" == *"/opt/local/bin"* ]]; then
	PATH=/opt/local/bin:$PATH
fi

# Begin block comment
# if [ 1 -eq 0 ]; then

if [ "$OS_VERSION" -eq 7 ]; then
	echo "Detected OSX Lion"
elif [ "$OS_VERSION" -eq 8 ]; then
	echo "Detected OSX Mountain Lion"
elif [ "$OS_VERSION" -eq 9 ]; then
	echo "Detected OSX Mavericks"
elif [ "$OS_VERSION" -eq 10 ]; then
	echo "Detected OSX Yosemite"
elif [ "$OS_VERSION" -eq 11 ]; then
	echo "Detected OSX El Capitain"
else
	echo "This installer requires OSX 10.7 (Lion) or above"
	echo "done."
	echo 
	exit 1
fi

if ! xcode-select -p &> /dev/null ; then
	echo "Setup has detected that xcode tools are not installed"
	read -p "Press [ENTER] to install xcode tools"
	sudo xcode-select --install &> /dev/null ;
	echo "Please wait for xcode tools to install"
	echo
	sleep 10s
	read -p "After code tools are installed press [ENTER] to continue"
	echo
	if ! xcode-select -p &> /dev/null ; then
		echo "Setup has detected that xcode tools were not completely installed"
		echo "Please wait for xcode tools to install and re-run this script"
		echo "done."
		echo
	fi
else
	echo "Found xcode tools"	
fi

if ! port version &> /dev/null ; then
	echo "Setup has detected that macports is not installed"
	read -p "Press [ENTER] to install macports"
	echo "Please wait for macports to install"
	MACPORTS=/tmp/macports.pkg
	if [ ! -f "$MACPORTS" ]; then
	  if [ "$OS_VERSION" -eq 7 ]; then
		  PKGURL=https://distfiles.macports.org/MacPorts/MacPorts-2.3.4-10.7-Lion.pkg
	  elif [ "$OS_VERSION" -eq 8 ]; then
		  PKGURL=https://distfiles.macports.org/MacPorts/MacPorts-2.3.4-10.8-MountainLion.pkg
	  elif [ "$OS_VERSION" -eq 9 ]; then
		  PKGURL=https://distfiles.macports.org/MacPorts/MacPorts-2.3.4-10.9-Mavericks.pkg
	  elif [ "$OS_VERSION" -eq 10 ]; then
		  PKGURL=https://distfiles.macports.org/MacPorts/MacPorts-2.3.4-10.10-Yosemite.pkg
	  elif [ "$OS_VERSION" -eq 11 ]; then
		  PKGURL=https://distfiles.macports.org/MacPorts/MacPorts-2.3.4-10.11-ElCapitan.pkg
	  fi
	  curl "$PKGURL" -o "$MACPORTS"
	fi
	open $MACPORTS
	echo
	sleep 10s
	read -p "After macports is installed press [ENTER] to continue"
	echo
	if ! port version &> /dev/null ; then
		echo "Setup has detected that macports was not completely installed"
		echo "Please wait for macports to install and re-run this script"
		echo "done."
		echo
	fi
else
	echo "Found macports"	
fi

if ! ggdb --version &> /dev/null ; then
	echo "Setup has detected that the gnu debugger is not installed"
	read -p "Press [ENTER] to install the gnu debugger"
	sudo port install gdb
	echo
	if ! ggdb --version &> /dev/null ; then
		echo "Setup has detected that the gnu debugger did not install"
		echo "done."
		echo
	fi
else
	echo "Found gnu debugger"	
fi

if ! 7za --help &> /dev/null ; then
	echo "Setup has detected that the 7-zip is not installed"
	read -p "Press [ENTER] to install 7-zip"
	sudo port install p7zip
	echo
	if ! 7za --help &> /dev/null ; then
		echo "Setup has detected that 7-zip did not install"
		echo "done."
		echo
	fi
else
	echo "Found 7-zip"	
fi

SIGNED="$(codesign -dv /opt/local/bin/ggdb 2>&1)"

if [[ $SIGNED == *"object is not signed"* ]]
then
	echo
	echo "Setup has detected that the gnu debugger is not currently code signed." 
	echo
	echo "After install is complete you will be provided instructions on how to sign the" 
	echo "debugger. This will allow it authorization to attach to programs for debugging."
	echo
	read -p "Press [ENTER] to continue"
fi

# TODO Provide missing program install command help based on current distro

# Present a description of this script
clear
echo "This is the universal OSX script to install Free Pascal and Lazarus"
echo "-------------------------------------------------------------------"
echo
echo "It will install copies of:"
echo "  Free Pascal $FPC"
echo "  Lazarus $LAZ"
echo
echo "To this folder:"
echo "  $BASE"
echo
echo "To uninstall, simply type:"
echo "  rm -rf $BASE"
echo
echo "This script not interfere with your existing development environment"
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
mkdir -p "$BASE"
cd "$BASE"

# Download and extract the archive
ARCHIVE="fpc-$FPC.$OS_TARGET.7z"
curl "http://cache.getlazarus.org/archives/$ARCHIVE" -o "$ARCHIVE"
7za x "$ARCHIVE"
rm "$ARCHIVE"

# fi
# End block comment

# function Replace(folder, search, replace, filespec)
replace() {
	cd "$BASE/$1"
	shift
	PWD
	SEARCH=$(echo "$1" | sed 's/[\*\.]/\\&/g')
	SEARCH=$(echo "$SEARCH" | sed 's/\//\\\//g')
	shift
	REPLACE=$(echo "$1" | sed 's/[\*\.]/\\&/g')
	REPLACE=$(echo "$REPLACE" | sed 's/\//\\\//g')
	shift
	# Replace using perl
	perl -pi -w -e "s/${SEARCH}/${REPLACE}/g;" $1 &> /dev/null
}

ORIGIN="/Users/macuser/Development/FreePascal"
replace "lazarus/config" "$ORIGIN" "$BASE" "*.*"
replace "fpc/bin" "$ORIGIN" "$BASE" "*.cfg" 
replace "lazarus/lazarus.app/Contents/MacOS" "$ORIGIN" "$BASE" "lazarus"
echo 

cd $BASE
ditto ./lazarus/lazarus.app ./Lazarus.app

echo "Free Pascal 3.0 with Lazarus install complete"

if [[ $SIGNED == *"object is not signed"* ]]
then
	echo
	echo "The gnu debugger is not currently code signed" 
	echo
	echo "Read http://lazarus.codebot.org/darwin/debugger for instructions on"
	echo "how to code sign the debugger"
	echo
	open "http://lazarus.codebot.org/darwin/debugger"
	echo
fi

cd "$BASE"
touch "You can now run 'Lazarus.app' or drag it to 'Applications'"
open "$BASE"
