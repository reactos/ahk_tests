/*
 * Designed for Visual C++ 2005 SP1 Redistributable 7.1
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

ModuleExe = %A_WorkingDir%\Apps\Visual C++ 2005 SP1 Redistributable 7.1 Setup.exe
TestName = 1.install
MainAppFile = %A_WinDir%\WinSxS\x86_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.762_x-ww_6b128700\msvcr80.dll

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    UninstallerPath = %A_WinDir%\System32\MsiExec.exe /qn /norestart /X{7299052b-02a4-4627-81f2-1818da5d550d} 
    WaitUninstallDone(UninstallerPath, 3)
    if bContinue
    {
        IfNotExist, %MainAppFile% ; Uninstaller might fail
            bContinue := true
        else
            TestsFailed("Uninstaller failed to get rid of '" MainAppFile "'.")
    }

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{7299052b-02a4-4627-81f2-1818da5d550d}
        TestsOK("")
        Run %ModuleExe%
    }
}


; Test if can click 'Yes' in 'Microsoft Visual C++ 2005 SP1 Redistributable Package (x86) (Please read)' window
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft Visual C++ 2005 SP1 Redistributable Package (x86), Please read, 10
    if ErrorLevel
        TestsFailed("Window 'Microsoft Visual C++ 2005 SP1 Redistributable Package (x86) (Please read)' failed to appear.")
    else
    {
        ControlClick, Button1, Microsoft Visual C++ 2005 SP1 Redistributable Package (x86), Please read ; Hit 'Yes' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Yes' button in 'Microsoft Visual C++ 2005 SP1 Redistributable Package (x86) (Please read)' window.")
        else
        {
            WinWaitClose, Microsoft Visual C++ 2005 SP1 Redistributable Package (x86), Please read, 3
            if ErrorLevel
                TestsFailed("'Microsoft Visual C++ 2005 SP1 Redistributable Package (x86) (Please read)' window failed to close despite 'Yes' button being clicked.")
            else
                TestsOK("'Microsoft Visual C++ 2005 SP1 Redistributable Package (x86) (Please read)' window appeared, 'Yes' button clicked and window closed.")
        }
    }
} 

; Test if 'Microsoft Visual C++ 2005 Redistributable' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft Visual C++ 2005 Redistributable,, 10
    if ErrorLevel
        TestsFailed("'Microsoft Visual C++ 2005 Redistributable' window failed to appear.")
    else
    {
        WinWaitClose, Microsoft Visual C++ 2005 Redistributable,,15
        if ErrorLevel
            TestsFailed("'Microsoft Visual C++ 2005 Redistributable' failed to close.")
        else
            TestsOK("'Microsoft Visual C++ 2005 Redistributable' window appeared and closed.")
    }
}


; Check if installed file(s) exist
TestsTotal++
if bContinue
{
    iTimeOut := 7
    while iTimeOut > 0
    {
        IfExist, %MainAppFile%
            break
        else
        {
            iTimeOut--
            Sleep, 1000
        }
    }

    IfNotExist, %MainAppFile%
        TestsFailed("Something went wrong, can't find '" MainAppFile "'.")
    else
        TestsOK("The application has been installed, because '" MainAppFile "' was found.")
}
