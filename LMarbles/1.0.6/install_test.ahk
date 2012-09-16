/*
 * Designed for LMarbles 1.0.6
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

ModuleExe = %A_WorkingDir%\Apps\LMarbles 1.0.6 Setup.exe
TestName = 1.install
MainAppFile = lmarbles.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\LMarbles_is1, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            IfNotExist, %A_ProgramFiles%\lmarbles
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                IfExist, %A_ProgramFiles%\lmarbles\unins000.exe
                {
                    RunWait, %A_ProgramFiles%\lmarbles\unins000.exe /silent ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\lmarbles ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\lmarbles, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete hardcoded path '" A_ProgramFiles "\lmarbles' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            StringReplace, UninstallerPath, UninstallerPath, `",, All
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
                bContinue := true
            else
            {
                IfExist, %UninstallerPath%
                {
                    RunWait, %UninstallerPath% /silent ; Silently uninstall it
                    Sleep, 7000
                }

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
    }

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\LMarbles_is1

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


; Test if 'Setup (This will)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup, This will, 15
    if ErrorLevel
        TestsFailed("'Setup (This will)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button1, Setup, This will ; Hit 'Yes' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Yes' button in 'Setup (This will)' window.")
        else
        {
            WinWaitClose, Setup, This will, 5
            if ErrorLevel
                TestsFailed("'Setup (This will)' window failed to close despite 'Yes' button being clicked.")
            else
                TestsOK("'Setup (This will)' window appeared, 'Yes' button clicked and window closed.")
        }
    }
}


; Test if 'Setup - LMarbles (Welcome)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LMarbles, Welcome, 15
    if ErrorLevel
        TestsFailed("'Setup - LMarbles (Welcome)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TButton2, Setup - LMarbles, Welcome ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - LMarbles (Welcome)' window.")
        else
            TestsOK("'Setup - LMarbles (Welcome)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - LMarbles (SelectDir)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LMarbles, SelectDir, 7
    if ErrorLevel
        TestsFailed("'Setup - LMarbles (SelectDir)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TButton2, Setup - LMarbles, SelectDir ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - LMarbles (SelectDir)' window.")
        else
            TestsOK("'Setup - LMarbles (SelectDir)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - LMarbles (SelectProgramGroup)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LMarbles, SelectProgramGroup, 7
    if ErrorLevel
        TestsFailed("'Setup - LMarbles (SelectProgramGroup)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TButton2, Setup - LMarbles, SelectProgramGroup ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - LMarbles (SelectProgramGroup)' window.")
        else
            TestsOK("'Setup - LMarbles (SelectProgramGroup)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - LMarbles (SelectTasks)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LMarbles, SelectTasks, 7
    if ErrorLevel
        TestsFailed("'Setup - LMarbles (SelectTasks)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TButton2, Setup - LMarbles, SelectTasks ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - LMarbles (SelectTasks)' window.")
        else
            TestsOK("'Setup - LMarbles (SelectTasks)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - LMarbles (Ready)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LMarbles, Ready, 7
    if ErrorLevel
        TestsFailed("'Setup - LMarbles (Ready)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TButton2, Setup - LMarbles, Ready ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Setup - LMarbles (Ready)' window.")
        else
            TestsOK("'Setup - LMarbles (Ready)' window appeared and 'Install' button was clicked.")
    }
}


; Skip 'Setup - LMarbles (Installing)' window


; Test if 'Setup - LMarbles (Finished)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LMarbles, Finished, 30 ; Wait longer, because we skipped one window
    if ErrorLevel
        TestsFailed("'Setup - LMarbles (Finished)' window failed to appear.")
    else
    {
        Sleep, 700
        Control, Uncheck, , TCheckBox1, Setup - LMarbles, Finished ; uncheck 'Launch LBreakout2' checkbox
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Launch LBreakout2' checkbox in 'Setup - LMarbles (Finished)' window.")
        else
        {
            Sleep, 700
            ControlClick, TButton2, Setup - LMarbles, Finished ; Hit 'Finish' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Finish' button in 'Setup - LMarbles (Finished)' window.")
            else
            {
                WinWaitClose, Setup - LMarbles, Finished, 7
                if ErrorLevel
                    TestsFailed("'Setup - LMarbles (Finished)' window failed to close despite 'Finish' button being clicked.")
                else
                {
                    Process, Wait, %MainAppFile%, 4
                    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                    if NewPID <> 0
                        TestsFailed("'" MainAppFile "' process appeared despite 'Launch LBreakout2' checkbox being unchecked in 'Setup - LMarbles (Finished)' window.")
                    else
                        TestsOK("'Setup - LMarbles (Finished)' window appeared, 'Launch LBreakout2' checkbox unchecked, 'Finish' button clicked and window closed.")
                }
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\LMarbles_is1, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        StringReplace, UninstallerPath, UninstallerPath, `",, All
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
