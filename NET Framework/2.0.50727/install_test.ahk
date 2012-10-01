/*
 * Designed for NET Framework 2.0.50727
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

ModuleExe = %A_WorkingDir%\Apps\NET Framework 2.0.50727 Setup.exe
TestName = 1.install

TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    ; RunWait, msiexec.exe /qn /norestart /X{7131646D-CD3C-40F4-97B9-CD9E4E6262EF} ; Silently uninstall it
    UninstallerPath = %A_WinDir%\System32\msiexec.exe /qn /norestart /X{7131646D-CD3C-40F4-97B9-CD9E4E6262EF}
    WaitUninstallDone(UninstallerPath, 5) ; Yes, there is no child process
    if bContinue
    {
        TestsOK("")
        Run %ModuleExe%
    }
}


; Test if 'Microsoft .NET Framework 2.0 (Extracting)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft .NET Framework 2.0, Extracting, 5
    if ErrorLevel
        TestsFailed("'Microsoft .NET Framework 2.0 (Extracting)' window failed to appear.")
    else
    {
       TestsInfo("'Microsoft .NET Framework 2.0 (Extracting)' window appeared, waiting for it to close.")
        
        iTimeOut := 30
        while iTimeOut > 0
        {
            IfWinActive, Microsoft .NET Framework 2.0, Extracting
            {
                WinWaitClose, Microsoft .NET Framework 2.0, Extracting, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
 
        WinWaitClose, Microsoft .NET Framework 2.0, Extracting, 1
        if ErrorLevel
            TestsFailed("'Microsoft .NET Framework 2.0 (Extracting)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'Microsoft .NET Framework 2.0 (Extracting)' window appeared and closed (iTimeOut=" iTimeOut ").")
    }
}


; Test if 'Microsoft .NET Framework 2.0 Setup (This wizard)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft .NET Framework 2.0 Setup, This wizard, 15
    if ErrorLevel
        TestsFailed("'Microsoft .NET Framework 2.0 Setup (This wizard)' window failed to appear.")
    else
    {
        SendInput, !n ; Hit 'Next' button
        WinWaitClose, Microsoft .NET Framework 2.0 Setup, This wizard, 3
        if ErrorLevel
            TestsFailed("'Microsoft .NET Framework 2.0 Setup (This wizard)' window failed to close despite Alt+N was sent.")
        else
            TestsOK("'Microsoft .NET Framework 2.0 Setup (This wizard)' window appeared and 'Alt+N' was sent.")
    }
}


; Test if 'Microsoft .NET Framework 2.0 Setup (By clicking)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft .NET Framework 2.0 Setup, By clicking, 3
    if ErrorLevel
        TestsFailed("'Microsoft .NET Framework 2.0 Setup (By clicking)' window failed to appear.")
    else
    {
        SendInput, !a ; Hit 'I have read and accept the license terms' checkbox
        SendInput, !i ; Hit 'Install' button
        TestsOK("'Microsoft .NET Framework 2.0 Setup (By clicking)' window appeared, 'Alt+A' and 'Alt+I' was sent.")
    }
}


; Test if 'Setup (Setup is configuring)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup, Setup is configuring, 3
    if ErrorLevel
        TestsFailed("'Setup (Setup is configuring)' window failed to appear.")
    else
    {
        TestsInfo("'Microsoft .NET Framework 2.0 Setup (Installing components)' window appeared, waiting for it to close.")
        
        iTimeOut := 30
        while iTimeOut > 0
        {
            IfWinActive, Setup, Setup is configuring
            {
                WinWaitClose, Setup, Setup is configuring, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
 
        WinWaitClose, Setup, Setup is configuring, 1
        if ErrorLevel
            TestsFailed("'Setup (Setup is configuring)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'Setup (Setup is configuring)' window appeared and closed (iTimeOut=" iTimeOut ").")
    }
}


; Test if all 'Setup' windows went away
TestsTotal++
if bContinue
{
    IfWinExist, Setup
        bActive := true

    iTimeOut := 10
    while (bActive) and (iTimeOut > 0)
    {
        IfWinExist, Setup
        {
            bActive := true
            Sleep, 3000
            iTimeOut--
        }
        else
            bActive := false
    }
    
    if iTimeOut = 0
        TestsFailed("Timed out for 'Setup' window not to exist.")
    else
        TestsOK("'Setup' windows are gone.")
}


; Test if can get thru 'Microsoft .NET Framework 2.0 Setup (Installing components)' window
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft .NET Framework 2.0 Setup, Installing components, 3
    if ErrorLevel
        TestsFailed("'Microsoft .NET Framework 2.0 Setup (Installing components)' window failed to appear.")
    else
    {
        TestsInfo("'Microsoft .NET Framework 2.0 Setup (Installing components)' window appeared, waiting for it to close.")
        
        iTimeOut := 360
        while iTimeOut > 0
        {
            IfWinActive, Microsoft .NET Framework 2.0 Setup, Installing components
            {
                WinWaitClose, Microsoft .NET Framework 2.0 Setup, Installing components, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
        
        WinWaitClose, Microsoft .NET Framework 2.0 Setup, Installing components, 1
        if ErrorLevel
            TestsFailed("'Microsoft .NET Framework 2.0 Setup (Installing components)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'Microsoft .NET Framework 2.0 Setup (Installing components)' window closed (iTimeOut=" iTimeOut ").")
    }
}


; Sleep until Button2 is not visible or until timed out
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft .NET Framework 2.0 Setup, Setup Complete, 3
    if ErrorLevel
        TestsFailed("'Microsoft .NET Framework 2.0 Setup (Setup Complete)' window failed to appear.")
    else
    {
        SendInput, !f ; Hit 'Finish' button
        WinWaitClose, Microsoft .NET Framework 2.0 Setup, Setup Complete, 3
        if ErrorLevel
            TestsFailed("'Microsoft .NET Framework 2.0 Setup (Setup Complete)' window failed to close despite 'Alt+F' was sent.")
        else
            TestsOK("'Microsoft .NET Framework 2.0 Setup (Setup Complete)' window appeared, 'Alt+F' was sent and window closed.")
    }
}
