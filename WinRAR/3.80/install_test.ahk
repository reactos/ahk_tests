/*
 * Designed for WinRAR 3.80
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

ModuleExe = %A_WorkingDir%\Apps\WinRAR 3.80 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\WinRAR archiver, UninstallString
    if not ErrorLevel
    {   
        IfExist, %UninstallerPath%
        {
            Process, Close, WinRAR.exe ; Teminate process
            Sleep, 1500
            RunWait, %UninstallerPath% /S ; Silently uninstall it
            Sleep, 2500
            ; Delete everything just in case
            RegDelete, HKEY_CURRENT_USER, SOFTWARE\WinRAR
            RegDelete, HKEY_CURRENT_USER, SOFTWARE\WinRAR SFX
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\WinRAR archiver
            SplitPath, UninstallerPath,, InstalledDir
            Run, regsvr32 /s /u "%UninstallerPath%\RarExt.dll"
            Process, Close, explorer.exe ; Explorer restart is required
            Sleep, 2500
            FileRemoveDir, %InstalledDir%, 1
            FileRemoveDir, %A_AppData%\WinRAR, 1
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
    }
    else
    {
        ; There was a problem (such as a nonexistent key or value). 
        ; That probably means we have not installed this app before.
        ; Check in default directory to be extra sure
        IfExist, %A_ProgramFiles%\WinRAR\Uninstall.exe
        {
            Process, Close, WinRAR.exe ; Teminate process
            Sleep, 1500
            RunWait, %A_ProgramFiles%\WinRAR\Uninstall.exe /S ; Silently uninstall it
            Sleep, 2500
            Run, regsvr32 /s /u "%A_ProgramFiles%\WinRAR\RarExt.dll"
            Process, Close, explorer.exe
            Sleep, 2500
            FileRemoveDir, %A_ProgramFiles%\WinRAR, 1
            FileRemoveDir, %A_AppData%\WinRAR, 1
            Sleep, 1000
            IfExist, %A_ProgramFiles%\WinRAR
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\WinRAR'.`n
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


; Test if window with 'Install' button appeared
TestsTotal++
if bContinue
{
    WinWaitActive, WinRAR 3.80, Install, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, WinRAR 3.80, Install
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'WinRAR 3.80' window appeared and 'Install' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Install'. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'WinRAR 3.80' window with 'Install' button failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Shell integration' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, WinRAR Setup, Shell integration, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button27, WinRAR Setup, Shell integration
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Shell integration' window appeared and 'OK' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'OK' in 'Shell integration' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'WinRAR Setup' window with 'Shell integration' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'WinRAR has been successfully' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, WinRAR Setup, WinRAR has been successfully, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, WinRAR Setup, WinRAR has been successfully
        if not ErrorLevel
        {
            ; Close explorer window
            WinWaitActive, ahk_class CabinetWClass,, 15
            {
                WinClose
            }
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'WinRAR has been successfully' window appeared and 'Done' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Done' in 'WinRAR has been successfully' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'WinRAR Setup' window with 'WinRAR has been successfully' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\WinRAR archiver, UninstallString
    if not ErrorLevel
    {
        IfExist, %UninstallerPath%
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: The application has been installed, because '%UninstallerPath%' was found.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Something went wrong, can't find '%UninstallerPath%'.`n
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
