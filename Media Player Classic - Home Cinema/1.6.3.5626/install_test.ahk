/*
 * Designed for Media Player Classic - Home Cinema 1.6.3.5626
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

ModuleExe = %A_WorkingDir%\Apps\MPC-HC.1.6.3.5626.x86_Setup.exe
TestName = 1.install
MainAppFile = mpc-hc.exe ; Mostly this is going to be process we need to look for

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    Process, Close, %MainAppFile% ; Teminate process
    Process, WaitClose, %MainAppFile%, 4
    if ErrorLevel ; The PID still exists.
        TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
    else
    {
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{2624B969-7135-4EB1-B0F6-2D8C397B45F7}_is1, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %A_ProgramFiles%\MPC-HC
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfExist, %A_ProgramFiles%\MPC-HC\mpc-hc.exe
                    RunWait, %A_ProgramFiles%\MPC-HC\mpc-hc.exe /unregall ; Unregister all file associations

                FileRemoveDir, %A_ProgramFiles%\MPC-HC, 1 ; Silent switch '/SILENT' is broken, so, delete the folder
                if ErrorLevel
                    TestsFailed("Unable to delete existing '" A_ProgramFiles "\MPC-HC' ('" MainAppFile "' process is reported as terminated).'")
                else
                    bContinue := true
            }
        }
        else
        {
            StringReplace, UninstallerPath, UninstallerPath, `",, All ; The MPC-HC uninstaller path is quoted, remove quotes
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
                bContinue := true
            else
            {
                IfExist, %InstalledDir%\MPC-HC\mpc-hc.exe
                    RunWait, %InstalledDir%\MPC-HC\mpc-hc.exe /unregall ; Unregister all file associations
                
                FileRemoveDir, %InstalledDir%, 1 ; Delete just in case
                if ErrorLevel
                    TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
                else
                    bContinue := true
            }
        }
    }

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{2624B969-7135-4EB1-B0F6-2D8C397B45F7}_is1
        IfExist, %A_AppData%\MPC-HC
        {
            FileRemoveDir, %A_AppData%\MPC-HC, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\MPC-HC'.")
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


; Test if 'Select Setup Language' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Select Setup Language, Select the language, 5
    if ErrorLevel
        TestsFailed("'Select Setup Language (Select the language)' window failed to appear.")
    else
    {
        SendInput, {ENTER} ; Hit 'OK' button
        WinWaitClose, Select Setup Language, Select the language, 3
        if ErrorLevel
            TestsFailed("'Select Setup Language (Select the language)' window failed to close despite 'ENTER' was sent.")
        else
            TestsOK("'Select Setup Language (Select the language)' window appeared, 'ENTER' sent and window closed.")
    }
}


; Test if 'Setup - MPC-HC' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, This will install, 5
    if ErrorLevel
        TestsFailed("'Setup - MPC-HC (This will install)' window failed to appear.")
    else
    {
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - MPC-HC (This will install)' window appeared, Alt+N was sent.")
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, License Agreement, 3
    if ErrorLevel
        TestsFailed("'Setup - MPC-HC (License Agreement)' window failed to appear.")
    else
    {
        SendInput, !a ; Check 'I accept' radiobutton
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - MPC-HC (License Agreement)' window appeared, Alt+A and Alt+N was sent.")
    }
}


; Test if 'Select Destination Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Select Destination Location, 3
    if ErrorLevel
        TestsFailed("'Setup - MPC-HC (Select Destination Location)' window failed to appear.")
    else
    {
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - MPC-HC (Select Destination Location)' window appeared, Alt+N was sent.")
    }
}


; Test if 'Select Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Select Components, 3
    if ErrorLevel
        TestsFailed("'Setup - MPC-HC (Select Components)' window failed to appear.")
    else
    {
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - MPC-HC (Select Components)' window appeared, Alt+N was sent.")
    }
}


; Test if 'Select Start Menu Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Select Start Menu Folder, 3
    if ErrorLevel
        TestsFailed("'Setup - MPC-HC (Select Start Menu Folder)' window failed to appear.")
    else
    {
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - MPC-HC (Select Start Menu Folder)' window appeared, Alt+N was sent.")
    }
}


; Test if 'Select Additional Tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Select Additional Tasks, 3
    if ErrorLevel
        TestsFailed("'Setup - MPC-HC (Select Additional Tasks)' window failed to appear.")
    else
    {
        SendInput, !q ; Check 'Create a Quick Launch icon' checkbox //We want to test more things
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - MPC-HC (Select Additional Tasks)' window appeared, Alt+Q and Alt+N was sent.")
    }
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Ready to Install, 3
    if ErrorLevel
        TestsFailed("'Setup - MPC-HC (Ready to Install)' window failed to appear.")
    else
    {
        SendInput, !i ; Hit 'Install' button
        TestsOK("'Setup - MPC-HC (Ready to Install)' window appeared and Alt+I was sent.")
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Installing, 3
    if ErrorLevel
        TestsFailed("'Setup - MPC-HC (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'Installing' window appeared, waiting for it to close.")
        
        iTimeOut := 15
        while iTimeOut > 0
        {
            IfWinActive, Setup - MPC-HC, Installing
            {
                WinWaitClose, Setup - MPC-HC, Installing, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
        
        WinWaitClose, Setup - MPC-HC, Installing, 1
        if ErrorLevel
            TestsFailed("'Setup - MPC-HC (Installing)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'Setup - MPC-HC (Installing)' window closed (iTimeOut=" iTimeOut ").")
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Completing, 3
    if ErrorLevel
        TestsFailed("'Setup - MPC-HC (Completing)' window failed to appear.")
    else
    {
        SendInput, !f ; Hit 'Finish' button
        WinWaitClose, Setup - MPC-HC, Completing, 3
        if ErrorLevel
            TestsFailed("'Setup - MPC-HC (Completing)' window failed to close despite Alt+F was sent.")
        else
            TestsOK("'Setup - MPC-HC (Completing)' window appeared, Alt+F was sent.")
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{2624B969-7135-4EB1-B0F6-2D8C397B45F7}_is1, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        StringReplace, UninstallerPath, UninstallerPath, `",, All ; The MPC-HC uninstaller path is quoted, remove quotes
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
