/*
 * Designed for 7-Zip 4.65
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

ModuleExe = %A_WorkingDir%\Apps\7-Zip 4.65 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip, UninstallString
    if not ErrorLevel
    {
        StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
        IfExist, %UninstallerPath%
        {
            Process, Close, 7zFM.exe ; Teminate process
            Sleep, 1500
            RunWait, %UninstallerPath% /S ; Silently uninstall it
            Sleep, 2500
            ; Delete everything just in case
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\7-Zip
            RegDelete, HKEY_CURRENT_USER, SOFTWARE\7-Zip
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\7-Zip
            SplitPath, UninstallerPath,, InstalledDir
            Run, regsvr32 /s /u "%A_ProgramFiles%\7-Zip\7-zip.dll"
            Process, Close, explorer.exe ; Explorer restart is required
            Sleep, 2500
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
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%InstalledDir%'.`n
            bContinue := false
        }
    }
    else
    {
        ; There was a problem (such as a nonexistent key or value). 
        ; That probably means we have not installed this app before.
        ; Check in default directory to be extra sure
        IfExist, %A_ProgramFiles%\7-Zip\Uninstall.exe
        {
            Process, Close, 7zFM.exe ; Teminate process
            Sleep, 1500
            RunWait, %A_ProgramFiles%\7-Zip\Uninstall.exe /S ; Silently uninstall it
            Sleep, 2500
            Run, regsvr32 /s /u "%A_ProgramFiles%\7-Zip\7-zip.dll"
            Process, Close, explorer.exe
            Sleep, 2500
            FileRemoveDir, %A_ProgramFiles%\7-Zip, 1
            Sleep, 1000
            IfExist, %A_ProgramFiles%\-Zip
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\7-Zip'.`n
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


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, 7-Zip 4.65 Setup, Choose Install Location, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, 7-Zip 4.65 Setup, Choose Install Location ; Hit 'Install' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: '7-Zip 4.65 Setup' window with 'Choose Install Location' appeared and 'Next' was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Install' in 'Choose Install Location' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: '7-Zip 4.65 Setup' window with 'Choose Install Location' failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if '7-Zip 4.65 has been installed' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, 7-Zip 4.65 Setup, 7-Zip 4.65 has been installed, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, 7-Zip 4.65 Setup, 7-Zip 4.65 has been installed ; Hit 'Finish'
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: '7-Zip 4.65 Setup' window with '7-Zip 4.65 has been installed' appeared and 'Finish' was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Finish' in '7-Zip 4.65 has been installed' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: '7-Zip 4.65 Setup' window with '7-Zip 4.65 has been installed' failed to appear. Active window caption: '%title%'.`n
    }
}


;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip, UninstallString
    if not ErrorLevel
    {
        StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
        IfExist, %UninstallerPath%
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: The application has been installed, because '%UninstallerPath%' was found.`n
        }
        else
        {
            TestsFailed()
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Something went wrong, can't find '%UninstallerPath%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Either we can't read from registry or data doesn't exist. Active window caption: '%title%'.`n
    }
}
