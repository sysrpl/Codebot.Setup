# Free Pascal and Lazarus Trunk Setup

This guide will assist users in compiling and configuring the latest
versions of the Free Pascal Compiler and Lazarus IDE. The source code
for these projects will be pulled from their official subversion
repositories.

This guide is for all operating systems.

## Setting up your paths

Create a folder to store the compiler, IDE, and other tools. In this 
guide I use the folder $HOME/Development/Base, but you can use whatever 
folder name you prefer.

Open a terminal (cmd.exe on Windows), create your base folder, and 
change to that directory.

Debian/Ubuntu:
```
mkdir $HOME/Development/Base
cd $HOME/Development/Base
```
Windows:
```
mkdir C:\Development\Base
cd C:\Development\Base
```

### Install the prerequisites

Before you begin you need to install the build system and subversion 
tools. If you don't already have them setup, follow these steps.

Debian/Ubuntu:
```
sudo apt-get install build-essentials subversion
```
Windows:

1. Download bintools.zip
2. Extract the files to C:\Development\Base\bintools
3. Add C:\Development\Base\bintools to your path

In terminal and type "svn help". You should see the help for the 
subversion program.


## Setting up a trunk version of Free Pascal

Download and a working 2.6.4 version of the Free Pascal 
Compiler for your platform from:

- [FPC 2.6.4 for Debian/Ubuntu 32-bit](http://sourceforge.net/projects/freepascal/files/Linux/2.6.4/fpc-2.6.4.i386-linux.tar/download)
- [FPC 2.6.4 for Debian/Ubuntu 64-bit](http://sourceforge.net/projects/freepascal/files/Linux/2.6.4/fpc-2.6.4.x86_64-linux.tar/download)
- [FPC 2.6.4 for Windows](http://sourceforge.net/projects/freepascal/files/Win32/2.6.4/)

Open a terminal, extract file from the downloaded archive, then run its
setup script. When the script asks for the install folder, it to your
base folder ($HOME/Development/Base/fpc-2.6.4 or 
C:\Development\Base\fpc-2.6.4)

Add the newly created C:\Development\Base\fpc-2.6.4\bin folder to your
PATH variable.

Debian/Ubuntu:
```
PATH=$PATH:$HOME/Development/Base/fpc-2.6.4/bin
```

Windows:
```
PATH=%PATH%;C:\Development\Base\fpc-2.6.4\bin
```

Type 'fpc' to verify installation.

Get the trunk version of fpc from svn (a revision number is optional).
`svn co [-r rev#] http://svn.freepascal.org/svn/fpc/trunk fpc

Build the fpc trunk compiler.
```
cd fpc
make all
make install PREFIX=<current path>
```
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
