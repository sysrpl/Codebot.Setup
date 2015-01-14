# Free Pascal 3.0 and Lazarus 1.4 Test

This guide will assist users in compiling and configuring test versions 
of Free Pascal 3.0 and Lazarus 1.4. It currently has sections for 
icrosoft Windows and Linux, but an OSX section will be added soon.

## Automated Installation

The quickest and least error prone way to setup Free Pascal 3.0 and 
Lazarus 1.4 is to use the automated installers. These install methods
will not interfere with other development envrionments you might already 
have on you computer.

If you are using Microsoft Windows download and run the setup program:

[Free Pascal 3.0 and Lazarus 1.4 Test Setup](http://cache.codebot.org/lazarus/setup.exe)

If you are using Linux, open a terminal and type:

```
wget http://cache.codebot.org/lazarus/install.fpc-3.0.sh
sh install.fpc-3.0.sh
```

** Linux Installer Notes **

> - In Linux it will install to `$HOME/Development/FreePascal`
> - You can change this folder by editing install.fpc-3.0.sh

## Manual Installation

This section describes how to install Free Pascal 3.0 and Lazarus 1.4 
manually.

### Windows

- Create the folder C:\Development\FreePasscal\bintools
- Download [bintools.zip](http://cache.codebot.org/bintools.zip)
- Extract the files to C:\Development\FreePasscal\bintools
- Add C:\Development\FreePascal\bintools to your path
- Download a working copy of [FPC 2.6.4 for Windows](http://sourceforge.net/projects/freepascal/files/Win32/2.6.4/)
- Extract the files and run the setup batch
- Instruct the batch file to place files in C:\Development\FreePascal\fpc-2.6.4
- Run cmd.exe and type the following:
```
set OLD_PATH=$PATH
set PATH=%PATH%;%BASE%\fpc-2.6.4\bin\i386-win32
fpc -iV
```
- You should see version number `2.6.4`


### Linux

Create a folder to store the compiler, IDE, and other tools. In this 
guide I use the variable `BASE` to refer to the `$HOME/Development/Base`
folder, but you can use whatever folder name or location you prefer.

Open a terminal and create your base folder.

Debian/Ubuntu:
```
BASE=$HOME/Development/Base
mkdir $BASE
```
Windows:
```
set BASE=C:\Development\Base
mkdir %BASE%
```

### Install the prerequisites

Before you begin you need to install the build system and subversion 
tools. If you don't already have them setup, follow these steps.

Debian/Ubuntu:
```
sudo apt-get install build-essentials subversion
```
Windows:


Type `svn help` into the terminal. You should see a help listing for the
subversion program.

## Setting up a trunk version of Free Pascal

Download and a working binary version of the Free Pascal 
Compiler 2.6.4 for your platform:

- [FPC 2.6.4 for Debian/Ubuntu 32-bit](http://sourceforge.net/projects/freepascal/files/Linux/2.6.4/fpc-2.6.4.i386-linux.tar/download)
- [FPC 2.6.4 for Debian/Ubuntu 64-bit](http://sourceforge.net/projects/freepascal/files/Linux/2.6.4/fpc-2.6.4.x86_64-linux.tar/download)

Extract the files from the downloaded archive. On Linux you may want to
backup your already existing FPC configuration file.

Debian/Ubuntu:
```
mv $HOME/.fpc.cfg $HOME/.fpc.bak
```
Then run the setup script for FPC 2.6.4. It will ask for install folder.
Provide the value it to `$BASE/fpc-2.6.4` on Linux or 
`C:\Development\Base\fpc-2.6.4` on Windows.

On Linux we then move the new FPC configuration file and restore the old
one. We also add to our path on all platforms.

Debian/Ubuntu:
```
mv $HOME/.fpc.cfg $BASE/fpc-2.6.4/bin/fpc.cfg
mv $HOME/.fpc.bak $HOME/.fpc.cfg
export PPC_CONFIG_PATH=$BASE/fpc-2.6.4/bin
$BASE/fpc/bin/fpcmkcfg -d basepath=$BASE/fpc/lib/fpc/\$FPCVERSION -o $BASE/fpc/bin/fpc.cfg

OLD_PATH=$PATH
PATH=$PATH:$BASE/fpc-2.6.4/bin
```

Windows:
```
set OLD_PATH=$PATH
set PATH=%PATH%;%BASE%\fpc-2.6.4\bin\i386-win32
```
Type `fpc -iV` into your terminal. You should see version number `2.6.4`.

Get the fpc 2.0 from svn.
```
http://svn.freepascal.org/svn/fpc/branches/fixes_3_0 fpc
```

Build the fpc 3.0 compiler.
```
cd fpc
make all
```

Debian/Ubuntu:
```
make install INSTALL_PREFIX=$BASE
```

Windows:
```
```

PPC_CONFIG_PATH

Close the terminal then open a new one.

Add the newly created fpc bin folder to your PATH variable.

To get a

`svn co [-r rev#] http://svn.freepascal.org/svn/lazarus/trunk lazarus

To compile

`make all

## Setting up Free Pascal for cross compiling to other platforms

Some cross installation examples

```
cd fpc
make crossinstall PREFIX=<current path> OS_TARGET=linux CPU_TARGET=i386
make crossinstall PREFIX=<current path> OS_TARGET=linux CPU_TARGET=x86_64
make crossinstall PREFIX=<current path> OS_TARGET=win32 CPU_TARGET=i386
make crossinstall PREFIX=<current path> OS_TARGET=win64 CPU_TARGET=x86_64
make crossinstall PREFIX=<current path> OS_TARGET=android CPU_TARGET=arm 
```
