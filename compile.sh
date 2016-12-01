#!/bin/bash
# detect wine and AHK compiler
cd $(dirname "$0") # WHERE ARE THEY ??
if [ x"$WINE"x == "xx" ] ; then WINE=$(which wine) ; fi
if [  ! -x "$WINE" ] ; then echo Wine was not found in path, please install or set WINE variable. ; exit 1; fi
if [ ! -f Compiler/Ahk2Exe.exe ] ; then echo Please add AHK compiler here ; exit 1 ; fi
# get all the tests
TESTSLIST=$( find . -name zz\*.ahk -exec $WINE winepath -w {} \; )
# avoids being bothered by spaces in file names
IFS=$(echo -en "\n\b")
# build all the tests and copy them to Tests/ directory
rm -f ${HOME}/.wine/dosdevices/a:
ln -s ${PWD} ${HOME}/.wine/dosdevices/a:
echo "@echo off"> /tmp/build$$.bat
for TEST in $TESTSLIST ; do
  "$WINE" cmd /c echo Compiler\\Ahk2Exe.exe /in "$TEST" /out "${TEST%.ahk}.exe" \>\> Z:\\tmp\\build$$.bat
  "$WINE" cmd /c echo if errorlevel 1 exit \>\>Z:\\tmp\\build$$.bat
done
  "$WINE" cmd /c Z:\\tmp\\build$$.bat
GetLastError=$?
rm -f /tmp/build$$.bat
if [ $GetLastError -ne 0 ] ; then exit $GetLastError ; fi
find . -wholename ./Tests -prune -o -name zz_*test.exe -exec mv {} Tests/ \;
