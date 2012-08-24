/*
 * Designed for Java 6.25
 * Copyright (C) 2012 Edijs Kolesnikovics
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

ModuleExe = %A_WorkingDir%\Apps\Java 6.25 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, InstalledDir, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{26A24AE4-039D-4CA4-87B4-2F83216025FF}, InstallLocation
    if not ErrorLevel
    {
        StringReplace, InstalledDir, InstalledDir, `",, All ; String contains quotes, replace em
        IfExist, %InstalledDir%
        {
            RunWait, MsiExec.exe /X{26A24AE4-039D-4CA4-87B4-2F83216025FF} /norestart /qb-! ; Silently uninstall it
            Sleep, 2500
            ; Delete everything just in case
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\JavaSoft
            RegDelete, HKEY_CURRENT_USER, SOFTWARE\JavaSoft
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{26A24AE4-039D-4CA4-87B4-2F83216025FF}
            Sleep, 2500
            FileRemoveDir, %A_AppData%\Sun, 1
            FileRemoveDir, %InstalledDir%, 1
            Sleep, 1000
            IfExist, %InstalledDir%
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%InstalledDir%'.`n
                bContinue := false
            }
            else
            {
                bContinue := true
            }
        }
        else
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%InstalledDir%' does not exist.`n
            bContinue := false
        }
    }
    else
    {
        ; There was a problem (such as a nonexistent key or value). 
        ; That probably means we have not installed this app before.
        ; Check in default directory to be extra sure
        IfExist, %A_ProgramFiles%\Java
        {
            RunWait, MsiExec.exe /X{26A24AE4-039D-4CA4-87B4-2F83216025FF} /norestart /qb-! ; Silently uninstall it
            Sleep, 2500
            FileRemoveDir, %A_ProgramFiles%\Java, 1
            FileRemoveDir, %A_AppData%\Sun, 1
            Sleep, 1000
            IfExist, %A_ProgramFiles%\Java
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\Java'.`n
                bContinue := false
            }
            else
            {
                bContinue := true
            }
        }
        else
        {
            ; No previous versions detected.
            bContinue := true
        }
    }
    if bContinue
    {
        Run %ModuleExe%
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%ModuleExe%' not found.`n
    bContinue := false
}


; Test if 'Java Setup - Welcome (Welcome to)' window can appear, if so, check 'Change Destination Folder' and hit 'Install' button
TestsTotal++
if bContinue
{
    WinWaitActive, Java Setup - Welcome, Welcome to, 10
    if not ErrorLevel
    {
        Sleep, 1050
        Control, Check, , Button1, Java Setup - Welcome, Welcome to ; Check 'Change Destination Folder' checkbox
        if not ErrorLevel
        {
            ControlClick, Button3, Java Setup - Welcome, Welcome to ; Hit 'Install' button
            if not ErrorLevel
            {
                TestsOK()
                OutputDebug, OK: %TestName%:%A_LineNumber%: 'Java Setup - Welcome (Welcome to)' window appeared, 'Change Destination Folder' checkbox checked and 'Install' button was clicked.`n
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Install' button in 'Java Setup - Welcome (Welcome to)' window. Active window caption: '%title%'.`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to check 'Change Destination Folder' checkbox in 'Java Setup - Welcome (Welcome to)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Java Setup - Welcome (Welcome to)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'Java Setup - Destination Folder (Install to)' window can appear, if so, hit 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, Java Setup - Destination Folder, Install to, 5
    if not ErrorLevel
    {
        Sleep, 1050
        ControlClick, Button1, Java Setup - Destination Folder, Install to ; Hit 'Next' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Java Setup - Destination Folder (Install to)' window appeared and 'Next' button was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Next' button in 'Java Setup - Destination Folder (Install to)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Java Setup - Destination Folder (Install to)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'Java Setup - Progress (Status)' window can appear, if so, wait for it to close
TestsTotal++
if bContinue
{
    WinWaitActive, Java Setup - Progress, Status, 10
    if not ErrorLevel
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Java Setup - Progress (Status)' window appeared, waiting for it to close.`n
        WinWaitClose, Java Setup - Progress, Status, 25 ; Should be enough time to get it installed
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Java Setup - Progress (Status)' window went away.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Java Setup - Progress (Status)' window failed to close. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Java Setup - Progress (Status)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'Java Setup - Complete (You have)' window can appear, if so, hit 'Close' button
TestsTotal++
if bContinue
{
    WinWaitActive, Java Setup - Complete, You have, 5
    if not ErrorLevel
    {
        Sleep, 1050
        ControlClick, Button2, Java Setup - Complete, You have ; Hit 'Close' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Java Setup - Complete (You have)' window appeared and 'Close' button was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Close' button in 'Java Setup - Complete (You have)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Java Setup - Complete (You have)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, InstalledDir, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{26A24AE4-039D-4CA4-87B4-2F83216025FF}, InstallLocation
    if not ErrorLevel
    {
        StringReplace, InstalledDir, InstalledDir, `",, All ; String contains quotes, replace em
        IfExist, %InstalledDir%
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: The application has been installed, because '%InstalledDir%' was found.`n
        }
        else
        {
            TestsFailed()
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Something went wrong, can't find '%InstalledDir%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Either we can't read from registry or data doesn't exist. Active window caption: '%title%'.`n
    }
}
