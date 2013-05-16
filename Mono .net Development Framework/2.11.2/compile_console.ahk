/*
 * Designed for Mono .net Development Framework 2.11.2
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

TestName = 4.compile_console ; http://www.mono-project.com/Using_Mono_on_Windows#Using_Mono_on_Windows

; Test if can compile and run console application
TestsTotal++
if bContinue
{
    szSourceCode = 
    (
        class X
        {
            static void Main ()
            {
                System.Console.Write("%TestName%");
            }
        } 
    )

    szSourceFile = C:\hello_console.cs
    IfExist, %szSourceFile%
    {
        FileDelete, %szSourceFile%
        if ErrorLevel
            TestsFailed("Unable to delete existing '" szSourceFile "'.")
    }

    if bContinue
    {
        FileAppend, %szSourceCode%, %szSourceFile%
        if ErrorLevel
            TestsFailed("Unable to create '" szSourceFile "'.")
        else
        {
            IfNotExist, %InstalledDir%\bin\setmonopath.bat
                TestsFailed("'" InstalledDir "\bin\setmonopath.bat' does NOT exist.")
            else
            {
                FileCopy, %InstalledDir%\bin\setmonopath.bat, C:\setmonopath.bat, 1 ; Copy and overwrite existing files
                if ErrorLevel <> 0
                    TestsFailed("Can NOT copy '" InstalledDir "\bin\setmonopath.bat' to 'C:\setmonopath.bat'.")
                else
                {
                    FileAppend, cd c:\`nmcs %szSourceFile%, C:\setmonopath.bat
                    if ErrorLevel
                        TestsFailed("Unable to write to 'C:\setmonopath.bat'.")
                    else
                    {
                        szCompiledApp = C:\Hello_Console.exe
                        IfExist, %szCompiledApp%
                        {
                            FileDelete, %szCompiledApp%
                            if ErrorLevel
                                TestsFailed("Unable to delete '" szCompiledApp "'.")
                        }

                        if bContinue
                        {
                            Run, cmd.exe /c C:\setmonopath.bat, C:\,, PID
                            Process, WaitClose, %PID%, 3
                            if ErrorLevel <> 0
                                TestsFailed("Process 'cmd.exe (PID: " PID ")' failed to close.")
                            else
                            {
                                IfNotExist, %szCompiledApp%
                                    TestsFailed("Compilation failed, because file '" szCompiledApp "' does NOT exist.")
                                else
                                    TestsOK("Compilation successfull, because file '" szCompiledApp "' exist.")
                            }
                        }
                    }
                }
            }
        }
    }
}


; Run compiled application
TestsTotal++
if bContinue
{
    Run, cmd.exe, C:\,, cmdPID
    szCmdWndCaption = %A_WinDir%\system32\cmd.exe
    WinWaitActive, %szCmdWndCaption%,,3
    if ErrorLevel
        TestsFailed("Window '" szCmdWndCaption "' failed to appear.")
    else
    {
        SendInput, "%ModuleExe%" "%szCompiledApp%"{ENTER}
        IfWinNotActive, %szCmdWndCaption%
            TestsFailed("Sent '" ModuleExe " "szCompiledApp "' and ENTER to '" szCmdWndCaption "' window and it became inactive.")
        else
        {
            clipboard = ; Clean the clipboard
            Sleep, 1500 ; Let mono app to load
            SendInput, !{SPACE}es{ENTER} ; Alt+Space to open System Menu -> Edit -> Select All.
            ClipWait, 2
            if ErrorLevel
                TestsFailed("Unable to copy console text to clipboard using 'Alt+Space, e, s, ENTER'.")
            else
            {
                IfNotInString, clipboard, %TestName%
                    TestsFailed("Clipboard text does NOT contain '" TestName "'. Clipboard: '" clipboard "'.")
                else
                    TestsOK("Mono console application works.")
            }
        }
    }
}


; Close console window. We con't care if test succeeded or not
TestsTotal++
Process, Close, %cmdPID%
Process, WaitClose, %cmdPID%, 3
if ErrorLevel <> 0
    TestsFailed("Unable to close 'cmd.exe (PID: " cmdPID ")' process.")
else
    TestsOK("")
