/*
 * Designed for NET Framework 1.1
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

ModuleExe = %A_WorkingDir%\Apps\NET Framework 1.1 Setup.exe
TestName = 1.install

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    UninstallerPath = %A_WinDir%\System32\msiexec.exe /qn /norestart /X{CB2F7EDD-9D1F-43C1-90FC-4F52EAE172A1}
    WaitUninstallDone(UninstallerPath, 5) ; Yes, there is no child process
    if bContinue
    {
        TestsOK("")
        Run %ModuleExe%
    }
}


; Test if can click 'Yes' in 'Microsoft .NET Framework 1.1 Setup (Would you)' window
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft .NET Framework 1.1 Setup, Would you, 5
    if ErrorLevel
        TestsFailed("Window 'Microsoft .NET Framework 1.1 Setup (Would you)' failed to appear.")
    else
    {
        ControlClick, Button1 ; Microsoft .NET Framework 1.1 Setup, Would you ; Hit 'Yes' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Yes' button in 'Microsoft .NET Framework 1.1 Setup (Would you)' window.")
        else
        {
            WinWaitClose, Microsoft .NET Framework 1.1 Setup, Would you, 3
            if ErrorLevel
                TestsFailed("'Microsoft .NET Framework 1.1 Setup (Would you)' window failed to close despite 'Yes' button being clicked.")
            else
                TestsOK("'Microsoft .NET Framework 1.1 Setup (Would you)' window appeared, 'Yes' button clicked and window closed.")
        }
    }
} 


; Skip 'Microsoft .NET Framework 1.1 Setup (Extracting)' window that appears for a split of second


; Test if 'Microsoft .NET Framework 1.1 Setup (License Agreement)' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft .NET Framework 1.1 Setup, License Agreement, 5 ; We skipped one window
    if ErrorLevel
        TestsFailed("Window 'Microsoft .NET Framework 1.1 Setup (License Agreement)' failed to appear.")
    else
    {
        Control, Check,, Button3 ; Check 'I agree' radiobutton
        if ErrorLevel
            TestsFailed("Unable to check 'I agree' radiobutton in 'Microsoft .NET Framework 1.1 Setup (License Agreement)' window.")
        else
        {
            ControlClick, Button4 ; Hit 'Install' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Install' button in 'Microsoft .NET Framework 1.1 Setup (License Agreement)' window.")
            else
                TestsOK("'Microsoft .NET Framework 1.1 Setup (License Agreement)' window appeared, 'I agree' radiobutton checked, 'Install' button clicked.")
        }
    }
}


; Test if can get thru 'Microsoft .NET Framework 1.1 Setup (Installing Components)' window
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft .NET Framework 1.1 Setup, Installing Components, 3
    if ErrorLevel
        TestsFailed("Window 'Microsoft .NET Framework 1.1 Setup (Installing Components)' failed to appear.")
    else
    {
        TestsInfo("'Microsoft .NET Framework 1.1 Setup (Installing Components)' window appeared, waiting for it to close.")
        iTimeOut := 80
        while iTimeOut > 0
        {
            IfWinActive, Microsoft .NET Framework 1.1 Setup, Installing Components
            {
                WinWaitClose, Microsoft .NET Framework 1.1 Setup, Installing Components, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
        
        WinWaitClose, Microsoft .NET Framework 1.1 Setup, Installing Components, 1
        if ErrorLevel
            TestsFailed("'Microsoft .NET Framework 1.1 Setup (Installing Components)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'Microsoft .NET Framework 1.1 Setup (Installing Components)' window closed (iTimeOut=" iTimeOut ").")
    }
}


; Test if can click 'OK' in 'Microsoft .NET Framework 1.1 Setup (complete)' window
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft .NET Framework 1.1 Setup, complete, 3
    if ErrorLevel
        TestsFailed("Window 'Microsoft .NET Framework 1.1 Setup (complete)' failed to appear.")
    else
    {
        ControlClick, Button1 ; Hit 'OK' button
        if ErrorLevel
            TestsFailed("Unable to hit 'OK' button in 'Microsoft .NET Framework 1.1 Setup (complete)' window.")
        else
        {
            WinWaitClose, Microsoft .NET Framework 1.1 Setup, complete, 3
            if ErrorLevel
                TestsFailed("'Microsoft .NET Framework 1.1 Setup (complete)' window failed to close despite 'OK' button being clicked.")
            else
                TestsOK("'Microsoft .NET Framework 1.1 Setup (complete)' window appeared, 'OK' button clicked and window closed.")
        }
    }
}
