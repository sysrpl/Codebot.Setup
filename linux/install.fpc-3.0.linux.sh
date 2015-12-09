#!/bin/bash
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

# The full version number of the stable compiler and the one we are building
FPC_STABLE=3.0.0
FPC_BUILD=3.0.1

# TODO Allow the user to pick their compiler and ide versions

# Prevent this script from running as root 
if [ "$(id -u)" = "0" ]; then
   echo "This script should not be run as root"
   exit 1
fi

echo "This installer requires the following packages which"
echo "can be installed on Debian distributions by using:"
echo
echo "sudo apt-get install build-essential patch wget p7zip-full"
echo
echo "Lazarus requires these Gtk+ dev packages to operate which"
echo "can be installed on Debian distributions by using:"
echo
echo "sudo apt-get install libgtk2.0-dev libcairo2-dev libpango1.0-dev \\"
echo "  libgdk-pixbuf2.0-dev libatk1.0-dev libghc-x11-dev"
echo

# function require(program) 
function require() {
	if ! type "$1" > /dev/null; then
		echo 
		echo "An error occured"
		echo 
		echo "This script requires the package $1"
		echo "It was not found on your system"
		echo 
		echo "On Debian based distributions type the following to install it"
		echo 
		echo "sudo apt-get install $1"
		echo 
		echo "Then re-run this script"
		echo 
		echo "On other distributions refer to your package manager"
		echo 
		exit 1
	fi	
	echo "$1 found"
}

# Require the following programs 
require "make" "build-essential"
require "patch" "patch"
require "wget" "wget"
require "7za" "p7zip-full"

# function requirePackage(package) 
function requirePackage() {
	if [ ! $(dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
		echo "$1 not found"
		echo 
		echo "An error occured"
		echo 
		echo "This script requires the package $1"
		echo "It was not found on your system"
		echo 
		echo "On Debian based distributions type the following to install it"
		echo 
		echo "sudo apt-get install $1"
		echo 
		echo "Then re-run this script"
		echo 
		exit 1
	fi	
	echo "$1 found"
}

if type "dpkg-query" > /dev/null; then
	requirePackage "libgtk2.0-dev"
	requirePackage "libcairo2-dev"
	requirePackage "libpango1.0-dev"
	requirePackage "libgdk-pixbuf2.0-dev"
	requirePackage "libatk1.0-dev"
	requirePackage "libghc-x11-dev"
fi

echo
echo -n "Press return to continue"
read CHOICE

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
echo "This is the universal Linux script to install Free Pascal and Lazarus"
echo "---------------------------------------------------------------------"
echo
echo "It will download the sources for:"
echo "  Free Pascal 3.0 and Lazarus"
echo
echo "It will not interfere with your existing development environment"
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

# The default folder
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

# Ask for permission to create a local application shortcut
echo "After install do you want to shortcuts created in:"
read -r -p "$HOME/.local/share/applications (y/n)? " SHORTCUT
echo 

# Block comment for testing
: <<'COMMENT'
COMMENT

# Create the folder
BASE=$EXPAND
mkdir -p $BASE

# Exit if the folder could not be created
if [ ! -d "$BASE" ]; then
  echo "Could not create directory"
  echo
  echo "done."
  echo
  exit 1;
fi

cd $BASE

# Create our install folder
mkdir -p $BASE
cd $BASE

# Determine operating system architecture
CPU=$(uname -m)

if [ "$CPU" = "i686" ]; then
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
wget -P $BASE $URL/fpc.7z
7za x $BASE/fpc.7z -o$BASE
rm $BASE/fpc.7z

# Make the new compiler
cd $BASE/fpc
make all
make install INSTALL_PREFIX=$BASE/fpc
# Make cross compilers
if [ "$CPU" = "i386" ]; then
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

find $BASE/fpc/packages -name "units" | xargs rm -rf
find $BASE/fpc/packages -name "test*" | xargs rm -rf
find $BASE/fpc/packages -name "example*" | xargs rm -rf
find $BASE/fpc/compiler -name "units" | xargs rm -rf
find $BASE/fpc/installer -name "units" | xargs rm -rf
find $BASE/fpc/rtl -name "units" | xargs rm -rf

# Download the lazarus source code
wget -P $BASE $URL/lazarus.7z
7za x $BASE/lazarus.7z -o$BASE
rm $BASE/lazarus.7z
cd $BASE/lazarus

# function replace(folder, files, before, after) 
function replace() {
	BEFORE=$(echo "$3" | sed 's/[\*\.]/\\&/g')
	BEFORE=$(echo "$BEFORE" | sed 's/\//\\\//g')
	AFTER=$(echo "$4" | sed 's/[\*\.]/\\&/g')
	AFTER=$(echo "$AFTER" | sed 's/\//\\\//g')
	find "$1" -name "$2" -exec sed -i "s/$BEFORE/$AFTER/g" {} \;
}

# Replace paths from their original location to the new one
ORIGIN="/home/boxuser/Development/Base"
replace "$BASE/lazarus/config" "*.xml" "$ORIGIN" "$BASE"
replace "$BASE/lazarus/config" "*.cfg" "$ORIGIN" "$BASE"
replace "$BASE/lazarus" "lazarus.sh" "$ORIGIN" "$BASE"
replace "$BASE/lazarus" "lazarus.desktop" "$ORIGIN" "$BASE"
ORIGIN="/home/boxuser/Development/FreePascal"
replace "$BASE/lazarus/config" "*.xml" "$ORIGIN" "$BASE"
replace "$BASE/lazarus/config" "*.cfg" "$ORIGIN" "$BASE"
replace "$BASE/lazarus" "lazarus.sh" "$ORIGIN" "$BASE"
replace "$BASE/lazarus" "lazarus.desktop" "$ORIGIN" "$BASE"

chmod +x $BASE/lazarus/lazarus.desktop
chmod +x $BASE/lazarus/lazarus.sh
mv $BASE/lazarus/lazarus.desktop $BASE/lazarus.desktop

FPCDIR="$BASE/fpc"
# Create a terminal configuration
TERMINAL="$FPCDIR/bin/fpc-terminal.sh"
echo "#!/bin/bash" > $TERMINAL
echo "export PPC_CONFIG_PATH=$FPCDIR/bin" >> $TERMINAL
echo "export PATH=\$PPC_CONFIG_PATH:\$PATH" >> $TERMINAL
echo "\$SHELL" >> $TERMINAL
chmod +x $TERMINAL
# Get the current terminal program name
APP=`ps -p $(ps -p $(ps -p $$ -o ppid=) -o ppid=) o args=`
# Create a shortcut file
DESKTOP="$BASE/freepascal.desktop"
echo "[Desktop Entry]" > $DESKTOP
echo "Name=Free Pascal Terminal" >> $DESKTOP
echo "Comment=Open a new terminal with the fpc program made available" >> $DESKTOP
echo "Icon=terminal" >> $DESKTOP
echo "Exec=$APP -e \"$TERMINAL\"" >> $DESKTOP
echo "Terminal=false" >> $DESKTOP
echo "Type=Application" >> $DESKTOP
chmod +x $DESKTOP

# Patch has already been applied, see changes.patch for details
# patch -p0 -i $BASE/lazarus/changes.diff

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
echo 
echo "Free Pascal 3.0 with Lazarus install complete"
echo 
