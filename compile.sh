#!/bin/bash
# detect wine and AHK compiler
if [ x"$WINE"x == "xx" ] ; then WINE=$(which wine) ; fi
if [  ! -x "$WINE" ] ; then echo Wine was not found in path, please install or set WINE variable. ; exit 1; fi
if [ ! -f Compiler/Ahk2Exe.exe ] ; then echo Please add AHK compiler here ; exit 1 ; fi
# get all the tests
TESTSLIST=$( find . -name zz\*.ahk -exec $WINE winepath -w {} \; )
# avoids being bothered by spaces in file names
IFS=$(echo -en "\n\b")
# build all the tests and copy them to Tests/ directory
for TEST in $TESTSLIST ; do
  "$WINE" Compiler/Ahk2Exe.exe /in "$TEST" /out "${TEST%.ahk}.exe"
done
find . -wholename ./Tests -prune -o -name zz_*test.exe -exec mv {} Tests/ \;
