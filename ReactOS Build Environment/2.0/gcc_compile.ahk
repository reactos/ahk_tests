/*
 * Designed for RosBE 2.0
 * Copyright (C) 2013 Edijs Kolesnikovics
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

TestName = 2.gcc_compile
szDocument =  C:\C_code.c ; Case insensitive
szAppCode =
(
#include <stdio.h>
#include <string.h>

int main()
{
    char buffer[]="Write this text to file";
    FILE *stream;
    if ((stream = fopen("file.txt", "w+")) == NULL)
    {
        printf("Could not create/open a file\n.");
        return 0;
    }
    fprintf(stream, "`%s\n", buffer);
    fseek(stream, 0L, SEEK_END);
    fprintf(stream, "`%s\n", buffer);
    fclose(stream);
    return(0);
}
)

; Test if can compile and run C application
TestsTotal++
RunApplication()
if bContinue
{
    IfWinNotActive, ReactOS Build Environment 2.0
        TestsFailed("'ReactOS Build Environment 2.0' window is NOT active.")
    else
    {
        IfExist, %szDocument%
        {
            FileDelete, %szDocument%
            if ErrorLevel
                TestsFailed("Unable to delete existing '" szDocument "'.")
        }

        if bContinue
        {
            FileAppend, %szAppCode%, %szDocument%
            if ErrorLevel
                TestsFailed("Unable to create '" szDocument "'.")
            else
                TestsOK("File '" szDocument "' created.")
        }
    }
}


TestsTotal++
if bContinue
{
    IfWinNotActive, ReactOS Build Environment 2.0
        TestsFailed("'ReactOS Build Environment 2.0' window is NOT active.")
    else
    {
        SplitPath, szDocument,, szDirPath
        szExe = %szDirPath%\gcc_compile.exe
        SendInput, gcc %szDocument% -o %szExe%{ENTER}
        Sleep, 1000 ; Wait until compilation is done
        IfNotExist, %szExe%
            TestsFailed("Sent 'gcc " szDocument " -o " szExe " ENTER' to 'ReactOS Build Environment 2.0' window, but '" szExe "' was NOT created.")
        else
            TestsOK("Compiled '" szDocument "', because '" szExe "' exist.")
    }
}


TestsTotal++
if bContinue
{
    IfWinNotActive, ReactOS Build Environment 2.0
        TestsFailed("'ReactOS Build Environment 2.0' window is NOT active.")
    else
    {
        szAppDoc = %szDirPath%\file.txt
        IfExist, %szAppDoc%
        {
            FileDelete, %szAppDoc%
            if ErrorLevel
                TestsFailed("Unable to delete existing '" szAppDoc "'.")
        }

        if bContinue
        {
            RunWait, %szExe%, %szDirPath%\
            iTimeOut := 30
            while (iTimeOut > 0)
            {
                IfNotExist, %szAppDoc%
                {
                    Sleep, 100
                    iTimeOut--
                }
                else
                    break
            }
            IfNotExist, %szAppDoc%
                TestsFailed("Ran '" szExe "', but '" szAppDoc "' does NOT exist.")
            else
            {
                FileReadLine, szLineText, %szAppDoc%, 2
                if ErrorLevel
                    TestsFailed("Unable to read line 2 of existing '" szAppDoc "'.")
                else
                {
                    szExpectedText = Write this text to file
                    IfNotInString, szLineText, %szExpectedText%
                        TestsFailed("Line 2 of '" szAppDoc "' holds wrong data. Is '" szLineText "', should be '" szExpectedText "'.")
                    else
                        TestsOK("Successfuly ran compiled C application.")
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    WinClose, ReactOS Build Environment 2.0
    WinWaitClose, ReactOS Build Environment 2.0,,2
    if ErrorLevel
        TestsFailed("Unable to close 'ReactOS Build Environment 2.0' window.")
    else
        TestsOK("Closed 'ReactOS Build Environment 2.0' window.")
}
