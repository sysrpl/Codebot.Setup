#!/bin/bash
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
LAZ="1.5"
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
elif [ "$OS_VERSION" -eq 12 ]; then
	echo "Detected OSX El Sierra"
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

if ! gdb --version &> /dev/null ; then
	echo "Setup has detected that the gnu debugger is not installed"
	read -p "Press [ENTER] to install the gnu debugger"
	sudo port install gdb
	echo
	if ! gdb --version &> /dev/null ; then
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

SIGNED="$(codesign -dv /usr/local/bin/gdb 2>&1)"

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

# Cross platform expandPath function
function expandPath() {
	if [ `uname`="Darwin" ]; then
		[[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}";
	else
		echo $(readlink -m `$1`)
	fi
}

# Present a description of this script
clear
echo "This is the universal OSX script to install Free Pascal and Lazarus"
echo "-------------------------------------------------------------------"
echo
echo "It will install copies of:"
echo "  Free Pascal $FPC"
echo "  Lazarus $LAZ"
echo
echo "This script not interfere with your existing Lazarus environment"
echo

BASE=$HOME/Development/FreePascal

# Ask a series of questions
while true; do
	# Ask for an install location
	echo "Enter an installation folder or press return to"
	echo "accept the default install location"
	echo 
	echo -n "[$BASE]: "
		read CHOICE
	echo

	# Use BASE as the default
	if [ -z "$CHOICE" ]; then
		CHOICE=$BASE
	fi

	# Allow for relative paths
	CHOICE=`eval echo $CHOICE`
	EXPAND=`expandPath "$CHOICE"`

	# Allow install only under your home folder
	if [[ $EXPAND == $HOME* ]]; then
		echo "The install folder will be:"
		echo "$EXPAND"
		echo
	else
		echo "The install folder must be under your personal home folder"
		echo
		continue
	fi

	# Confirm their choice
	echo -n "Continue? (y,n): "
	read CHOICE
	echo 

	case $CHOICE in
		[yY][eE][sS]|[yY]) 
			;;
		*)
			echo "done."
			echo
			exit 1
			;;
	esac

	# If folder already exists ask to remove it
	if [ -d "$EXPAND" ]; then
		echo "Directory already exist"
		echo -n "Remove the entire folder and overwrite? (y,n): "
		read CHOICE
		case $CHOICE in
			[yY][eE][sS]|[yY]) 
				echo
				rm -rf $EXPAND
				;;
			*)
				echo
				echo "done."
				echo
				exit 1
				;;
		esac
	fi

	break
done

# Create the folder
BASE=$EXPAND
mkdir -p "$BASE"

# Exit if the folder could not be created
if [ ! -d "$BASE" ]; then
  echo "Could not create directory"
  echo
  echo "done."
  echo
  exit 1;
fi

CURRENT=`pwd`
cd $BASE

# Download and extract the archive
ARCHIVE="fpc-$FPC.$OS_TARGET.7z"
curl "http://cache.getlazarus.org/archives/$ARCHIVE" -o "$ARCHIVE"
7za x "$ARCHIVE"
rm "$ARCHIVE"

# fi
# End block comment

# function Replace(folder, search, replace, filespec)
function replace() {
	cd "$BASE/$1"
	shift
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
replace "lazarus/lazarus.app/Contents/MacOS" "$ORIGIN" "$BASE" "lazarus"
replace "fpc/bin" "$ORIGIN" "$BASE" "*.cfg" 
echo 

cd $BASE
ditto ./lazarus/lazarus.app ./Lazarus.app/
cd $BASE

TERMINAL="Free Pascal Terminal.command"
echo "osascript -e 'tell app \"Terminal\"" > "$TERMINAL"
echo "    do script \"export PPC_CONFIG_PATH=\\\"$BASE/fpc/bin\\\" && export PATH=\\\"\$PPC_CONFIG_PATH:\$PATH\\\"\"" >> "$TERMINAL"
echo "end tell'" >> "$TERMINAL"
chmod +x "$TERMINAL"

# Count this as an install
function hit() {
	if type "curl" > /dev/null; then
		curl -s -o /dev/null "$1"
	elif type "wget" > /dev/null; then
		wget -q -O /dev/null "$1"
	fi	
}

hit "http://www.getlazarus.org/installed/?platform=macintosh"

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

open "$BASE"
cd $CURRENT
