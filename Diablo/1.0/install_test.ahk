/*
 * Designed for Diablo 1.0
 * Copyright (C) 2014 Radek Liska
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

ModuleExe = %A_WorkingDir%\Apps\Diablo Demo 1.0.exe
TestName = 1.install
MainAppFile = diablo_s.exe ; Mostly this is going to be process we need to look for

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
        RegRead, InstalledDir, HKEY_LOCAL_MACHINE, SOFTWARE\Blizzard Entertainment\Archives, DiabloSpawn
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value).
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            IfNotExist, C:\Diablo\Spawn
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                FileRemoveDir, C:\Diablo, 1
                if ErrorLevel
                    TestsFailed("Unable to delete hardcoded path C:\Diablo' ('" MainAppFile "' process is reported as terminated).'")
                else
                    bContinue := true
            }
        }
        else
        {
            IfNotExist, %InstalledDir%
                bContinue := true
            else
            {
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Blizzard Entertainment

        if bContinue
        {
            if bHardcoded
                TestsOK("Either there were no previous versions or we succeeded removing it using hardcoded path.")
            else
                TestsOK("Either there were no previous versions or we succeeded removing it using data from registry.")
            Run %ModuleExe%
        }
    }
}


; Test if 'Diablo - choose install directory' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Diablo - choose install directory,, 10
    if ErrorLevel
        TestsFailed("'Diablo - choose install directory' window failed to appear.")
    else
    {
        ControlClick, OK, Diablo - choose install directory ; Confirm the path and start installation
        ;SendInput, {ENTER} ; Confirm the path and start installation
        TestsOK("'Diablo - choose install directory' appeared and 'OK' button was clicked.")
    }
}


; Test if 'Diablo' messagebox with 'Diablo shareware installation complete!' message appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Diablo, Diablo shareware installation complete, 15
    if ErrorLevel
        TestsFailed("'Diablo' messagebox with 'Diablo shareware installation complete!' message failed to appear.")
    else
    {
        ControlClick, OK, Diablo, Diablo shareware installation complete ; Close the messagebox
        ;SendInput, {ENTER} ; Close the messagebox
        TestsOK("'Diablo' messagebox with 'Diablo shareware installation complete!' message appeared and 'OK' button was clicked.")
    }
}


; Diablo opens explorer window with its Start menu folder, close it
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
    WinWait, Diablo ahk_class CabinetWClass,, 5
    if ErrorLevel
        TestsFailed("Explorer window 'Diablo' (SetTitleMatchMode=" A_TitleMatchMode ") failed to appear.")
    else
    {
        WinClose, Diablo ahk_class CabinetWClass
        WinWaitClose, Diablo ahk_class CabinetWClass,, 5
        if ErrorLevel
            TestsFailed("Unable to close explorer window 'Diablo' (SetTitleMatchMode=" A_TitleMatchMode ").")
        else
            TestsOK("'Diablo' window appeared, window closed.")
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, InstalledDir, HKEY_LOCAL_MACHINE, SOFTWARE\Blizzard Entertainment\Archives, DiabloSpawn
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        IfNotExist, %InstalledDir%%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "" MainAppFile "' was found.")
    }
}
