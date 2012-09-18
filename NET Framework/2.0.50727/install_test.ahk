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
    RunWait, msiexec.exe /qn /norestart /X{7131646D-CD3C-40F4-97B9-CD9E4E6262EF} ; Silently uninstall it
    Sleep, 14000
    TestsOK("")
    Run %ModuleExe%
}


; Test if 'Microsoft .NET Framework 2.0 Setup (This wizard)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft .NET Framework 2.0 Setup, This wizard, 35
    if ErrorLevel
        TestsFailed("'Microsoft .NET Framework 2.0 Setup (This wizard)' window failed to appear.")
    else
    {
        Sleep, 700
        ; Alt+N here is as good as ControlClick (no way to know for 100% if it failed or not until 'Setup (Setup is configuring)' window appears).
        SendInput, !n ; Hit 'Next' button
        ; WinWaitClose does not work for this install (win2k3 sp2)
        TestsOK("'Microsoft .NET Framework 2.0 Setup (This wizard)' window appeared and 'Alt+N' was sent.")
    }
}


; Test if 'Microsoft .NET Framework 2.0 Setup (By clicking)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft .NET Framework 2.0 Setup, By clicking, 7
    if ErrorLevel
        TestsFailed("'Microsoft .NET Framework 2.0 Setup (By clicking)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, !a ; Hit 'I have read and accept the license terms' checkbox
        Sleep, 1200
        SendInput, !i ; Hit 'Install' button
        TestsOK("'Microsoft .NET Framework 2.0 Setup (By clicking)' window appeared, 'Alt+A' and 'Alt+I' was sent.")
    }
}


; Test if 'Setup (Setup is configuring)' window appeared
TestsTotal++
if bContinue
{
    ; Until this window shows up, we have no idea if we really succeeded
    WinWaitActive, Setup, Setup is configuring, 10
    if ErrorLevel
        TestsFailed("'Setup (Setup is configuring)' window failed to appear.")
    else
    {
        WinWaitClose, Setup,Setup is configuring, 30
        if ErrorLevel
            TestsFailed("'Setup (Setup is configuring)' window failed to close.")
        else
            TestsOK("'Setup (Setup is configuring)' window appeared and closed.")
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


; Skip 'Microsoft .NET Framework 2.0 Setup (Installing components)' window, because WinWaitClose will report it unclosed even if it did


; Sleep until Button2 is not visible or until timed out
TestsTotal++
if bContinue
{
    iTimeOut := 240
    ControlGet, bVisible, Visible,, Button2, Microsoft .NET Framework 2.0 Setup
    while (bVisible <> 1) and (iTimeOut > 0)
    {
        IfWinNotActive, Microsoft .NET Framework 2.0 Setup
        {
            break
            TestsFailed("'Microsoft .NET Framework 2.0 Setup' window is not an active window.")
        }
        else
        {
            ControlGet, bVisible, Visible,, Button2, Microsoft .NET Framework 2.0 Setup
            Sleep, 1000
            iTimeOut--
            if bVisible = 1
                break
        }
    }

    if iTimeOut = 0
        TestsFailed("Timed out for 'Finish' button to appear.")
    else
    {
        SendInput, !f ; Hit 'Finish' button
        WinWaitClose, Microsoft .NET Framework 2.0 Setup, Setup Complete, 7
        if ErrorLevel
            TestsFailed("'Microsoft .NET Framework 2.0 Setup (Setup Complete)' window failed to close despite 'Alt+F' was sent.")
        else
            TestsOK("'Microsoft .NET Framework 2.0 Setup (Setup Complete)' window appeared, 'Alt+F' was sent and window closed.")
    }
}
