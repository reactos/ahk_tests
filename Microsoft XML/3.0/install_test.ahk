/*
 * Designed for Microsoft XML 3.0
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

ModuleExe = %A_WorkingDir%\Apps\Microsoft XML 3.0 Setup.msi
TestName = 1.install
MainAppFile = %A_WinDir%\System32\msxml3r.dll

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    ; The best way to make sure it is installed is to check for file existence, but Windows comes with it
    ; You can't simply delete it and there is no uninstall information in registry.
    ; Unregistering the dll will not help.
    
    ; Disable unti way to remove the dll is found
    ;IfExist, %MainAppFile%
    ;    TestsFailed("Can NOT continue, because '" MainAppFile "' was found.")
    ;else
    ;{
        TestsOK("No previous versions detected. FIXME: some lines are commented.")
        Run %ModuleExe%
    ;}
}



; Test if 'Microsoft XML Parser Setup (Welcome)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft XML Parser Setup, Welcome, 30
    if ErrorLevel
        TestsFailed("'Microsoft XML Parser Setup (Welcome)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button1, Microsoft XML Parser Setup, Welcome ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Microsoft XML Parser Setup (Welcome)' window.")
        else
        {
            WinWaitClose, Microsoft XML Parser Setup, Welcome, 5
            if ErrorLevel
                TestsFailed("'Microsoft XML Parser Setup (Welcome)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'Microsoft XML Parser Setup (Welcome)' window appeared, 'Next' button clicked and window closed.")
        }
    }
}


; Test if 'Microsoft XML Parser License Agreement (Please read)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft XML Parser License Agreement, Please read, 7
    if ErrorLevel
        TestsFailed("'Microsoft XML Parser License Agreement (Please read)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button2, Microsoft XML Parser License Agreement, Please read ; Check 'I accept' radiobutton
        if ErrorLevel
            TestsFailed("Unable to check 'I accept' radiobutton in 'Microsoft XML Parser License Agreement (Please read)' window.")
        else
        {
            TimeOut := 0
            while (not %bNextEnabled%) and (TimeOut < 6) ; Sleep while 'Next' button is disabled
            {
                ControlGet, bNextEnabled, Enabled,, Button5, Microsoft XML Parser License Agreement, Please read
                Sleep, 300
                TimeOut++
            }
                
            if not %bNextEnabled%
                TestsFailed("'Next' button is disabled despite 'I accept' radiobutton is checked in 'Microsoft XML Parser License Agreement (Please read)' window.")
            else
            {
                ControlClick, Button5, Microsoft XML Parser License Agreement, Please read ; Hit 'Next' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Next' button in 'Microsoft XML Parser License Agreement (Please read)' window.")
                else
                    TestsOK("'Microsoft XML Parser License Agreement (Please read)' window appeared, 'I accept' radiobutton checked and 'Next' button clicked.")
            }
        }
    }
}


; Test if 'Microsoft XML Parser Setup (Customer Information)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft XML Parser Setup, Customer Information, 7
    if ErrorLevel
        TestsFailed("'Microsoft XML Parser Setup (Customer Information)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button2, Microsoft XML Parser Setup, Customer Information ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Microsoft XML Parser Setup (Customer Information)' window.")
        else
            TestsOK("'Microsoft XML Parser Setup (Customer Information)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Microsoft XML Parser Setup (Ready to Install)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft XML Parser Setup, Ready to Install, 7
    if ErrorLevel
        TestsFailed("'Microsoft XML Parser Setup (Ready to Install)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button1, Microsoft XML Parser Setup, Ready to Install ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Microsoft XML Parser Setup (Ready to Install)' window.")
        else
            TestsOK("'Microsoft XML Parser Setup (Ready to Install)' window appeared and 'Install' button was clicked.")
    }
}


; Test if can get thru 'Microsoft XML Parser Setup (Installing)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft XML Parser Setup, Installing, 7
    if ErrorLevel
        TestsFailed("'Microsoft XML Parser Setup (Installing)' window failed to appear.")
    else
    {
        WinWaitClose, Microsoft XML Parser Setup, Installing, 60
        if ErrorLevel
            TestsFailed("'Microsoft XML Parser Setup (Installing)' window failed to close.")
        else
            TestsOK("'Microsoft XML Parser Setup (Installing)' window appeared and closed.")
    }
}


; Test if 'Microsoft XML Parser Setup (Completing)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft XML Parser Setup, Completing, 7
    if ErrorLevel
        TestsFailed("'Microsoft XML Parser Setup (Completing)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button1, Microsoft XML Parser Setup, Completing ; Hit 'Finish' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Finish' button in 'Microsoft XML Parser Setup (Completing)' window.")
        else
        {
            WinWaitClose, Microsoft XML Parser Setup, Completing, 7
            if ErrorLevel
                TestsFailed("'Microsoft XML Parser Setup (Completing)' window failed to close despite 'Finish' button being clicked.")
            else
                TestsOK("'Microsoft XML Parser Setup (Completing)' window appeared, 'Finish' button clicked and window closed.")
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