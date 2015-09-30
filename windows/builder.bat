@echo off

set OLDPATH=%PATH%
set BASE=C:\Development\build
set PATH=%BASE%\fpc.2.6.4\bin\i386-win32;%PATH%

set STEP=Updating svn sources
echo -- Step: %STEP% --

cd %BASE%\fpc_svn
svn update
cd %BASE%\lazarus_svn
svn revert -R .
svn update
del revision.txt
svn info > revision.txt
patch -p0 -i changes.diff

set STEP=Copying FPC sources
echo -- Step: %STEP% --

cd %BASE%
rmdir fpc /s /q
mkdir fpc
xcopy fpc_svn\* fpc /e /h /EXCLUDE:exfpc.txt

set STEP=Trimming FPC
echo -- Step: %STEP% --

cd %BASE%\fpc
rmdir tests /s /q

set STEP=Compressing FPC
echo -- Step: %STEP% --

cd %BASE%
7z a fpc.7z fpc || goto :error

set STEP=FPC make all
echo -- Step: %STEP% --

cd %BASE%\fpc
make all || goto :error

set STEP=FPC make install
echo -- Step: %STEP% --

make install INSTALL_PREFIX=%BASE%\fpc || goto :error
make crossinstall CPU_TARGET=x86_64 OS_TARGET=win64 INSTALL_PREFIX=%BASE%\fpc || goto :error
make crossinstall CPU_TARGET=x86_64 OS_TARGET=linux INSTALL_PREFIX=%BASE%\fpc
make crossinstall CPU_TARGET=i386 OS_TARGET=linux INSTALL_PREFIX=%BASE%\fpc

set STEP=Setting up new compiler environment
echo -- Step: %STEP% --

set COMPILER=%BASE%\fpc\bin\i386-win32
cd %COMPILER%
fpcmkcfg -d basepath=%BASE%\fpc -o .\fpc.cfg
set PATH=%COMPILER%;%OLDPATH%
cd %BASE%\fpc
mkdir lib
xcopy ..\changes\fpc\lib\* lib /e /h
xcopy ..\changes\fpc\bin\i386-win32\* bin\i386-win32
del /f /s /q fpmake.pp
del /f /s /q fpmake.inc
del /f /s /q Makefil*
del /f /s /q *.fpm
rmdir utils /s /q
rmdir installer /s /q
rmdir ide /s /q
rmdir fpmkinst /s /q
rmdir docs /s /q
del base*
del build*
del fpm*
mkdir rtl.bak
mv rtl\win rtl.bak\win
mv rtl\win32 rtl.bak\win32
mv rtl\win64 rtl.bak\win64
mv rtl\x86_64 rtl.bak\x86_64
mv rtl\unix rtl.bak\unix
mv rtl\objpas rtl.bak\objpas
mv rtl\macos rtl.bak\macos
mv rtl\arm rtl.bak\arm
mv rtl\android rtl.bak\android
mv rtl\darwin rtl.bak\darwin
mv rtl\i386 rtl.bak\i386
mv rtl\inc rtl.bak\inc
mv rtl\common rtl.bak\common
mv rtl\nativent rtl.bak\nativent
mv rtl\linux rtl.bak\linux
rmdir rtl /s /q
mv rtl.bak rtl

set STEP=Copying Lazarus sources
echo -- Step: %STEP% --

cd %BASE%
rmdir lazarus /s /q
mkdir lazarus
xcopy lazarus_svn\* lazarus /e /h /EXCLUDE:exlaz.txt

set STEP=Patching Lazarus
echo -- Step: %STEP% --

cd %BASE%\lazarus
mv .\images\splash_logo.png .\images\splash_logo_old.png
copy ..\changes\lazarus\images\splash_logo.png .\images\splash_logo.png
del .\images\splash_logo.res
copy ..\changes\lazarus\images\splash_logo.res .\images\splash_logo.res

set STEP=Creating Lazarus Linux config files
echo -- Step: %STEP% --

cd %BASE%\lazarus
rmdir .\config /s /q
del config
mkdir config
copy ..\changes\lazarus\linux\config .\config
copy ..\changes\lazarus\linux\lazarus.desktop .\lazarus.desktop
copy ..\changes\lazarus\linux\lazarus.sh .\lazarus.sh

set STEP=Compressing Lazarus
echo -- Step: %STEP% --

cd %BASE%
7z a lazarus.7z lazarus || goto :error

set STEP=Creating Lazarus Windows config files
echo -- Step: %STEP% --

cd %BASE%\lazarus
rmdir .\config /s /q
del config
mkdir config
copy ..\changes\lazarus\config .\config
del .\lazarus.desktop
del .\lazarus.sh

set STEP=Lazarus make all
echo -- Step: %STEP% --

cd %BASE%\lazarus
make all || goto :error
.\lazbuild .\components\anchordocking\design\anchordockingdsgn.lpk || goto :error
make useride || goto :error

set STEP=Stripping Lazarus files
echo -- Step: %STEP% --

cd %BASE%\lazarus
strip -S lazarus.exe
strip -S lazbuild.exe
strip -S startlazarus.exe
strip -S tools\lazres.exe
strip -S tools\lrstolfm.exe
strip -S tools\svn2revisioninc.exe
strip -S tools\updatepofiles.exe
rmdir lazarus.app /q /s
rmdir startlazarus.app /q /s
rmdir debian /q /s
rmdir lcl\units\i386-win32 /q /s
rmdir units\i386-win32 /q /s
del lazarus.old.exe

set STEP=Creating setup program
echo -- Step: %STEP% --

cd %BASE%
del %BASE%\setup\setup.exe
"C:\Program Files (x86)\Inno Setup 5\ISCC.exe" %BASE%\setup\setup.iss || goto :error

set STEP=Uploading setup.exe to S3
echo -- Step: %STEP% --

aws s3 cp %BASE%\setup\setup.exe s3://cache.getlazarus.org/download/windows/setup.exe --acl public-read || goto :error

set STEP=Uploading FPC sources to S3
echo -- Step: %STEP% --

aws s3 cp %BASE%\fpc.7z s3://cache.getlazarus.org/archives/fpc.7z --acl public-read || goto :error

set STEP=Uploading Lazarus sources to S3
echo -- Step: %STEP% --

cd %BASE%
aws s3 cp %BASE%\lazarus.7z s3://cache.getlazarus.org/archives/lazarus.7z --acl public-read || goto :error

:error
echo -- Failed '%STEP%' with error #%ERRORLEVEL% --

:done
cd %BASE%
del fpc.7z
del lazarus.7z
set PATH=%OLDPATH%
cd %BASE%
echo -- Done --
