/*
 * Designed for TeamViewer 7.0 (7.0.12979)
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

ModuleExe = %A_WorkingDir%\Apps\7zip_9.20_Setup.exe
TestName = 1.install
MainAppFile = 7zFM.exe ; Mostly this is going to be process we need to look for

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    Process, Close, %MainAppFile% ; Teminate process
    Sleep, 2000
    Process, Exist, %MainAppFile%
    if ErrorLevel <> 0
        TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
    else
    {
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %A_ProgramFiles%\7-Zip
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfExist, %A_ProgramFiles%\7-Zip\Uninstall.exe
                {
                    RunWait, %A_ProgramFiles%\7-Zip\Uninstall.exe /S ; Silently uninstall it
                    Sleep, 7000
                }

                Run, regsvr32 /s /u "%A_ProgramFiles%\7-Zip\7-zip.dll"
                Process, Close, explorer.exe
                Sleep, 270
                IfNotExist, %A_ProgramFiles%\7-Zip ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\7-Zip, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" A_ProgramFiles "\7-Zip' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
                bContinue := true
            else
            {
                IfExist, %UninstallerPath%
                {
                    RunWait, %UninstallerPath% /S ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %InstalledDir%
                    bContinue := true
                else
                {
                    Run, regsvr32 /s /u "%A_ProgramFiles%\7-Zip\7-zip.dll"
                    Process, Close, explorer.exe
                    Sleep, 270
                    FileRemoveDir, %InstalledDir%, 1 ; Delete just in case
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
                    else
                        bContinue := true
                }
            }
        }
    }

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\7-Zip
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\7-Zip
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\7-Zip
        IfExist, %A_AppData%\7-Zip
        {
            FileRemoveDir, %A_AppData%\7-Zip, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\7-Zip'.")
        }

        if bContinue
        {
            if bHardcoded
                TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
            else
                TestsOK("Either there was no previous versions or we succeeded removing it using data from registry.")
            Run %ModuleExe%
        }
    }
}


; Test if '7-Zip 9.20 Setup (Choose Install Location)' window appeared, if so, hit 'Install' button
TestsTotal++
if bContinue
{
    WinWait, 7-Zip 9.20 Setup, Choose Install Location, 15
    if ErrorLevel
        TestsFailed("'7-Zip 9.20 Setup (Choose Install Location)' window does not exist.")
    else
    {
        ; We had to kill explorer, so, make sure 7-Zip window is active
        WinActivate, 7-Zip 9.20 Setup, Choose Install Location
        WinWaitActive, 7-Zip 9.20 Setup, Choose Install Location, 7
        if ErrorLevel
            TestsFailed("Unable to activate existing '7-Zip 9.20 Setup (Choose Install Location)' window.")
        else
        {
            ControlClick, Button2, 7-Zip 9.20 Setup, Choose Install Location ; Hit 'Install' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Install' button in '7-Zip 9.20 Setup (Choose Install Location)' window.")
            else
                TestsOK("'7-Zip 9.20 Setup (Choose Install Location)' window appeared and 'Install' button was clicked.")
        }
    }
}


; Test if can get thru '7-Zip 9.20 Setup (Installing)' window
TestsTotal++
if bContinue
{
    WinWaitActive, 7-Zip 9.20 Setup, Installing, 5
    if ErrorLevel
        TestsFailed("'7-Zip 9.20 Setup (Installing)' window failed to appear.")
    else
    {
        OutputDebug, %TestName%:%A_LineNumber%: '7-Zip 9.20 Setup (Installing)' window appeared, waiting for it to close.`n
        WinWaitClose, 7-Zip 9.20 Setup, Installing, 20
        if ErrorLevel
            TestsFailed("'7-Zip 9.20 Setup (Installing)' window failed to close.")
        else
            TestsOK("'7-Zip 9.20 Setup (Installing)' window appeared and closed.")
    }
}


; Test if '7-Zip 9.20 Setup (Completing)' window appeared, if so
; check 'I want to reboot manually' radio button (if exist) and hit 'Finish' button
TestsTotal++
if bContinue
{
    WinWaitActive, 7-Zip 9.20 Setup, Completing, 5
    if ErrorLevel
        TestsFailed("'7-Zip 9.20 Setup (Completing)' window failed to appear.")
    else
    {
        ControlGet, bVisible, Visible,, 7-Zip 9.20 Setup, Completing
        if bVisible = 1 ; Control is visible
        {
            Control, Check, , Button5, 7-Zip 9.20 Setup, Completing ; Check 'I want to reboot manually' radiobutton
            if ErrorLevel
                TestsFailed("Unable to check 'I want to reboot manually' radiobutton in '7-Zip 9.20 Setup (Completing)' window.")
            else
            {
                Sleep, 700
                ControlClick, Button2, 7-Zip 9.20 Setup, Completing ; Hit 'Finish' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Finish' button in '7-Zip 9.20 Setup (Completing)' window.")
                else
                {
                    WinWaitClose, 7-Zip 9.20 Setup, Completing, 5
                    if ErrorLevel
                        TestsFailed("'7-Zip 9.20 Setup (Completing)' window failed to close after clicking on 'Finish' button.")
                    else
                        TestsOK("'I want to reboot manually' radiobutton was checked and 'Finish' button was clicked in '7-Zip 9.20 Setup (Completing)' window and it closed.")
                }
            }
        }
        else
        {
            ControlClick, Button2, 7-Zip 9.20 Setup, Completing ; Hit 'Finish' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Finish' button in '7-Zip 9.20 Setup (Completing)' window.")
            else
            {
                WinWaitClose, 7-Zip 9.20 Setup, Completing, 5
                if ErrorLevel
                    TestsFailed("'7-Zip 9.20 Setup (Completing)' window failed to close after clicking on 'Finish' button.")
                else
                    TestsOK("'Finish' button was clicked in '7-Zip 9.20 Setup (Completing)' window and it closed.")
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}