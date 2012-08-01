/*
 * Designed for Adobe Reader 7.1.0
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

ModuleExe = %A_WorkingDir%\Apps\Adobe Reader 7.1.0 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{AC76BA86-7AD7-1033-7B44-A71000000002}, InstallLocation
    if not ErrorLevel
    {   
        IfExist, %InstallLocation%
        {
            Process, Close, AcroRd32.exe ; Teminate process
            Sleep, 1500
            FileRemoveDir, %A_AppData%\Adobe\Acrobat, 1 ; Delete this before uninstalling
            ; Silently uninstall it
            ; http://www.itninja.com/question/adobe-readers-uninstall-commands-including-guids
            RunWait, MsiExec.exe /qn /norestart /x {AC76BA86-7AD7-1033-7B44-A71000000002}
            Sleep, 2500
            ; Delete everything just in case
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Adobe\Acrobat Reader
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Adobe\Repair\Acrobat Reader
            RegDelete, HKEY_CURRENT_USER, SOFTWARE\Adobe\Acrobat Reader
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{AC76BA86-7AD7-1033-7B44-A71000000002}
            FileRemoveDir, %InstallLocation%, 1
            Sleep, 1000
            IfExist, %InstallLocation%
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%InstallLocation%'.`n
                bContinue := false
            }
            else
            {
                bContinue := true
            }
        }
    }
    else
    {
        ; There was a problem (such as a nonexistent key or value). 
        ; That probably means we have not installed this app before.
        ; Check in default directory to be extra sure
        IfExist, %A_ProgramFiles%\Adobe\Acrobat 7.0
        {
            Process, Close, AcroRd32.exe ; Teminate process
            Sleep, 1500
            FileRemoveDir, %A_AppData%\Adobe\Acrobat, 1
            Process, Close, explorer.exe
            RunWait, MsiExec.exe /qn /norestart /x {AC76BA86-7AD7-1033-7B44-A71000000002} ; Silently uninstall it
            Sleep, 2500
            FileRemoveDir, %A_ProgramFiles%\Adobe\Acrobat 7.0, 1
            Sleep, 1000
            IfExist, %A_ProgramFiles%\Adobe\Acrobat 7.0
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\Adobe\Acrobat 7.0'.`n
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


; Test if 'Please wait' and Setup windows appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe Reader 7.1.0, Resume, 15
    if not ErrorLevel
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Adobe Reader 7.1.0' window with 'Resume' button appeared.`n
        WinWaitActive, Adobe Reader 7.1.0 - Setup, Next, 45
        if not ErrorLevel
        {
            Sleep, 250
            ControlClick, Button1, Adobe Reader 7.1.0 - Setup, Next
            if not ErrorLevel
            {
                TestsOK++
                OutputDebug, OK: %TestName%:%A_LineNumber%: 'Adobe Reader 7.1.0 - Setup' window appeared and first 'Next' button was clicked.`n
                bContinue := true
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click first 'Next' in 'Adobe Reader 7.1.0 - Setup' window. Active window caption: '%title%'.`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: First 'Adobe Reader 7.1.0 - Setup' window failed to appear. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Adobe Reader 7.1.0' window with 'Please wait' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Welcome to Setup' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe Reader 7.1.0 - Setup, Welcome to Setup, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, Adobe Reader 7.1.0 - Setup, Welcome to Setup
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Adobe Reader 7.1.0 - Setup' window with 'Welcome to Setup' appeared and 'Next' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Welcome to Setup' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Adobe Reader 7.1.0 - Setup' window with 'Welcome to Setup' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Destination Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe Reader 7.1.0 - Setup, Destination Folder, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, Adobe Reader 7.1.0 - Setup, Destination Folder
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Adobe Reader 7.1.0 - Setup' window with 'Destination Folder' appeared and 'Next' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Destination Folder' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Adobe Reader 7.1.0 - Setup' window with 'Destination Folder' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe Reader 7.1.0 - Setup, Ready to Install, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, Adobe Reader 7.1.0 - Setup, Ready to Install ; Hit 'Install' button
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Adobe Reader 7.1.0 - Setup' window with 'Ready to Install' appeared and 'Install' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Install' in 'Ready to Install' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Adobe Reader 7.1.0 - Setup' window with 'Ready to Install' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe Reader 7.1.0 - Setup, Installing Adobe, 7
    if not ErrorLevel
    {
        Sleep, 250
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installing Adobe' window appeared, waiting for it to close.`n
        WinWaitClose, Adobe Reader 7.1.0 - Setup, Installing Adobe, 50
        if not ErrorLevel
        {
            WinWaitActive, Adobe Reader 7.1.0 - Setup, Setup Completed, 7
            if not ErrorLevel
            {
                ControlClick, Button1, Adobe Reader 7.1.0 - Setup, Setup Completed ; Hit 'Finish' button
                if not ErrorLevel
                {
                    TestsOK++
                    OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installing Adobe' went away, 'Setup Completed' appeared, and 'Next' was clicked.`n
                    bContinue := true
                }
                else
                {
                    TestsFailed++
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Finish' button in 'Setup Completed' window. Active window caption: '%title%'.`n
                    bContinue := false
                }
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Adobe Reader 7.1.0 - Setup' window with 'Setup Completed' failed to appear. Active window caption: '%title%'.`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Adobe Reader 7.1.0 - Setup' window with 'Installing Adobe' failed to dissapear. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Adobe Reader 7.1.0 - Setup' window with 'Installing' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{AC76BA86-7AD7-1033-7B44-A71000000002}, InstallLocation
    if not ErrorLevel
    {
        IfExist, %InstallLocation%
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: The application has been installed, because '%InstallLocation%' was found.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Something went wrong, can't find '%InstallLocation%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Either we can't read from registry or data doesn't exist. Active window caption: '%title%'.`n
        bContinue := false
    }
}
