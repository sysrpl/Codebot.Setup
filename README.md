# Free Pascal 3.0 and Lazarus 1.4 Test

This guide will assist users in obtaining test versions of Free Pascal 3.0 and Lazarus 1.4. It currently has sections for Microsoft Windows and Linux, and Macintosh.

## Installation

The quickest and most straight forward way to setup Free Pascal 3.0 and Lazarus 1.4 is to use an automated installer. These automated installers will not interfere with other development envrionments you might already have on your computer.

#### Windows

**__To install:__** Download and run the [Free Pascal 3.0 and Lazarus 1.4](http://www.getlazarus.org/download/?platform=windows) installer.

This installer is built using [Inno Setup](http://www.jrsoftware.org/isinfo.php). If you would like to build your own Windows installer, the inno setup script project is [available on github here](https://github.com/sysrpl/Codebot.Setup/blob/master/windows/setup.iss).

> **Windows Installer Notes**
> - The setup program is currently not signed by an authority
> - It will therefore say publisher unknown, which is normal

#### Linux

**__To install:__** Open a terminal and type:

```
curl http://www.getlazarus.org/download/?platform=linux
sh setup.sh
```

The Linux installer is a shell script which builds Free Pascal and Lazarus from sources. If you would like to view or suggest changes to the script, it's [available on github here](https://github.com/sysrpl/Codebot.Setup/blob/master/linux/install.fpc-3.0.linux.sh).

> **Linux Installer Notes**
> - The install folder defaults to $HOME/Development/FreePascal
> - You can easily change this by editing the install script

#### Macintosh

**__To install:__** Open a terminal and type:

```
curl http://www.getlazarus.org/download/?platform=macintosh
sh setup.sh
```

The Macintosh installer is a shell script which step you through setting up Free Pascal and Lazarus on  Macintosh. It will automatically setup tools, such as xcode, which are needed when developing for Macintosh. If you would like to view or suggest changes to the script, it's [available on github here](https://github.com/sysrpl/Codebot.Setup/blob/master/macintosh/install.fpc-3.0.darwin.sh).

> **Macintosh Installer Notes**
> - The install folder defaults to $HOME/Development/FreePascal
> - You can easily change this by editing the install script
> - After install, you'll need to [code sign the debugger](http://www.getlazarus.org/setup/macintosh/)

## Manual Installation

This section describes how to install Free Pascal 3.0 and Lazarus 1.4 manually.

### Microsoft Windows

*coming soon*

### Linux

*coming soon*

### Macintosh

*coming soon*
