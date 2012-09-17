/*
 * Designed for Visual C++ 2008 SP1 Redistributable 8.0
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

ModuleExe = %A_WorkingDir%\Apps\Visual C++ 2008 SP1 Redistributable 8.0 Setup.exe
TestName = 1.install
MainAppFile = %A_WinDir%\WinSxS\x86_Microsoft.VC90.OpenMP_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_ecc42bd1\vcomp90.dll

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    IfExist, %MainAppFile%
    {
        RunWait, MsiExec.exe /qn /norestart /X{9A25302D-30C0-39D9-BD6F-21E6EC160475} ; Silently uninstall it
        Sleep, 7000
    }

    IfNotExist, %MainAppFile% ; Uninstaller might fail
        bContinue := true
    else
        TestsFailed("Uninstaller failed to get rid of '" MainAppFile "'.")

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{9A25302D-30C0-39D9-BD6F-21E6EC160475}
        TestsOK("")
        Run %ModuleExe%
    }
}


; Test if 'Microsoft Visual C++ 2008 Redistributable Setup (This wizard)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft Visual C++ 2008 Redistributable Setup, This wizard, 15
    if ErrorLevel
        TestsFailed("'Microsoft Visual C++ 2008 Redistributable Setup (This wizard)' window failed to appear.")
    else
    {
        Sleep, 700
        ; Alt+N here is as good as ControlClick (no way to know for 100% if it failed or not until 'Setup (Setup is configuring)' window appears).
        SendInput, !n ; Hit 'Next' button
        ; WinWaitClose does not work for this install (win2k3 sp2)
        TestsOK("'Microsoft Visual C++ 2008 Redistributable Setup (This wizard)' window appeared and 'Alt+N' was sent.")
    }
}


; Test if 'Microsoft Visual C++ 2008 Redistributable Setup (License Terms)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft Visual C++ 2008 Redistributable Setup, License Terms, 7
    if ErrorLevel
        TestsFailed("'Microsoft Visual C++ 2008 Redistributable Setup (License Terms)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, !a ; Hit 'I have read and accept the license terms' checkbox
        Sleep, 1200
        SendInput, !i ; Hit 'Install' button
        TestsOK("'Microsoft Visual C++ 2008 Redistributable Setup (License Terms)' window appeared, 'Alt+A' and 'Alt+I' was sent.")
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
        WinWaitClose, Setup,Setup is configuring, 20
        if ErrorLevel
            TestsFailed("'Setup (Setup is configuring)' window failed to close.")
        else
            TestsOK("'Setup (Setup is configuring)' window appeared and closed.")
    }
}


; Test if 'Microsoft Visual C++ 2008 Redistributable Setup (Setup Complete)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft Visual C++ 2008 Redistributable Setup, Setup Complete, 25 ; We skipped some windows
    if ErrorLevel
        TestsFailed("'Microsoft Visual C++ 2008 Redistributable Setup (Setup Complete)' window failed to appear.")
    else
    {
        Sleep, 1500
        SearchImg = %A_WorkingDir%\Media\Finish_Button.jpg
        IfNotExist, %SearchImg%
            TestsFailed("Can NOT find '" SearchImg "'.")
        else
        {
            ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *35 %SearchImg%
            if ErrorLevel = 2
                TestsFailed("Could not conduct the ImageSearch ('" SearchImg "' exist).")
            else if ErrorLevel = 1
                TestsFailed("Can NOT find '" SearchImg "' on the screen. 'Finish' button is not visible.")
            else
            {
                SendInput, !f ; Hit 'Finish' button
                WinWaitClose, Microsoft Visual C++ 2008 Redistributable Setup, Setup Complete, 7
                if ErrorLevel
                    TestsFailed("'Microsoft Visual C++ 2008 Redistributable Setup (Setup Complete)' window failed to close despite 'Alt+F' was sent.")
                else
                    TestsOK("'Microsoft Visual C++ 2008 Redistributable Setup (Setup Complete)' window appeared, 'Alt+F' was sent and window closed.")
            }
        }
    }
}


; Check if installed file(s) exist
TestsTotal++
if bContinue
{
    Sleep, 7000
    IfNotExist, %MainAppFile%
        TestsFailed("Something went wrong, can't find '" MainAppFile "'.")
    else
        TestsOK("The application has been installed, because '" MainAppFile "' was found.")
}
