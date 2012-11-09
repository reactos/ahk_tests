/*
 * Designed for Net Framework 2.0 SP2
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

ModuleExe = %A_WorkingDir%\Apps\Net Framework 2.0 SP2 Setup.exe
TestName = 1.install

TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    UninstallerPath = %A_WinDir%\System32\msiexec.exe /qn /norestart /X{C09FB3CD-3D0C-3F2D-899A-6A1D67F2073F}
    WaitUninstallDone(UninstallerPath, 5) ; Yes, there is no child process
    if bContinue
    {
        TestsOK("")
        Run %ModuleExe%
    }
}


; Test if 'Extracting Files (To Directory)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Extracting Files, To Directory, 3
    if ErrorLevel
        TestsFailed("'Extracting Files (To Directory)' window failed to appear.")
    else
    {
        WinWaitClose, Extracting Files, To Directory, 5
        if ErrorLevel
            TestsFailed("'Extracting Files (To Directory)' window failed to close.")
        else
            TestsOK("'Extracting Files (To Directory)' window appeared and closed.")
    }
}


; Test if 'Setup (Setup is loading)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup, Setup is loading, 3
    if ErrorLevel
        TestsFailed("'Setup (Setup is loading)' window failed to appear.")
    else
    {
        WinWaitClose, Setup, Setup is loading, 5
        if ErrorLevel
            TestsFailed("'Setup (Setup is loading)' window failed to close.")
        else
            TestsOK("'Setup (Setup is loading)' window appeared and closed.")
    }
}


; Test if 'Microsoft .NET Framework 2.0 SP2 Setup (Welcome to Setup)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft .NET Framework 2.0 SP2 Setup, Welcome to Setup, 3
    if ErrorLevel
        TestsFailed("'Microsoft .NET Framework 2.0 SP2 Setup (Welcome to Setup)' window failed to appear.")
    else
    {
        Control, Check,, Button22 ; Check 'I have read and ACCEPT...' radiobutton
        if ErrorLevel
            TestsFailed("Unable to check 'I accept' radiobutton in 'Microsoft .NET Framework 2.0 SP2 Setup (Welcome to Setup)' window.")
        else
        {
            TimeOut := 10
            while (not %bInstallEnabled%) and (TimeOut > 0) ; Sleep while 'Install' button is disabled
            {
                ControlGet, bInstallEnabled, Enabled,, Button19, Microsoft .NET Framework 2.0 SP2 Setup, Welcome to Setup
                Sleep, 100
                TimeOut++
            }
            
            if not %bInstallEnabled%
                TestsFailed("'Install' button did not get enabled in 'Microsoft .NET Framework 2.0 SP2 Setup (Welcome to Setup)' window after checking 'I accept' radiobutton.")
            else
            {
                ControlClick, Button19 ; Hit 'Install' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Install' button in 'Microsoft .NET Framework 2.0 SP2 Setup (Welcome to Setup)' window despite it is enabled.")
                else
                {
                    WinWaitClose, Microsoft .NET Framework 2.0 SP2 Setup, Welcome to Setup, 3
                    if ErrorLevel
                        TestsFailed("'Microsoft .NET Framework 2.0 SP2 Setup (Welcome to Setup)' window failed to close despite 'Install' button being closed.")
                    else
                        TestsOK("'Microsoft .NET Framework 2.0 SP2 Setup (Welcome to Setup)' window appeared, radiobutton 'I accept' checked, 'Install' button clicked, window closed.")
                }
            }
        }
    }
}


; Test if can get thru 'Microsoft .NET Framework 2.0 SP2 Setup (Installation Progress)' window
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft .NET Framework 2.0 SP2 Setup, Installation Progress, 3
    if ErrorLevel
        TestsFailed("'Microsoft .NET Framework 2.0 SP2 Setup (Installation Progress)' window failed to appear.")
    else
    {
        TestsInfo("'Microsoft .NET Framework 2.0 SP2 Setup (Installation Progress)' window appeared, waiting for it to close.")
        iTimeOut := 80
        while iTimeOut > 0
        {
            IfWinActive, Microsoft .NET Framework 2.0 SP2 Setup, Installation Progress
            {
                WinWaitClose, Microsoft .NET Framework 2.0 SP2 Setup, Installation Progress, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
        
        WinWaitClose, Microsoft .NET Framework 2.0 SP2 Setup, Installation Progress, 1
        if ErrorLevel
            TestsFailed("'Microsoft .NET Framework 2.0 SP2 Setup (Installation Progress)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'Microsoft .NET Framework 2.0 SP2 Setup (Installation Progress)' window closed (iTimeOut=" iTimeOut ").")
    }
}


; Test if 'Microsoft .NET Framework 2.0 SP2 Setup (Setup Complete)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft .NET Framework 2.0 SP2 Setup, Setup Complete, 3
    if ErrorLevel
        TestsFailed("'Microsoft .NET Framework 2.0 SP2 Setup (Setup Complete)' window failed to appear.")
    else
    {
        ControlClick, Button1 ; Hit 'Exit' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Exit' button in 'Microsoft .NET Framework 2.0 SP2 Setup (Setup Complete)' window.")
        else
        {
            WinWaitClose, Microsoft .NET Framework 2.0 SP2 Setup, Setup Complete, 3
            if ErrorLevel
                TestsFailed("'Microsoft .NET Framework 2.0 SP2 Setup (Setup Complete)' window failed to close despite 'Exit' button being closed.")
            else
                TestsOK("'Microsoft .NET Framework 2.0 SP2 Setup (Setup Complete)' window appeared, 'Exit' button clicked and window closed.")
        }
    }
}
