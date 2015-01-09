# Free Pascal and Lazarus Trunk Setup Guide

This guide

Create a base directory to hold files.

## Before you begin

Linux:
```
mkdir $HOME/Development/Base
cd $HOME/Development/Base
```
Windows:
```
mkdir C:\Development\Base
cd C:\Development\Base
```
## Setting up a trunk version of Free Pascal


Download and install a working 2.6.4 version of the Free Pascal 
Compiler for your platform from:

http://sourceforge.net/projects/freepascal/files/

Open a terminal, extract the downloaded archive, and run the setup
script. When the script asks for the install folder, refer to your
base folder ($HOME/Development/Base/fpc-2.6.4 or 
C:\Development\Base\fpc-2.6.4)

Add the newly created C:\Development\Base\fpc-2.6.4\bin folder to your
PATH variable.

Linux:
`PATH=$PATH:$HOME/Development/Base/fpc-2.6.4

Windows:
`PATH=%PATH%;C:\Development\Base\fpc-2.6.4\bin

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
