/*
 * Designed for Microsoft Tahoma Font 1.0
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

ModuleExe = %A_WorkingDir%\Apps\Microsoft Tahoma Font 1.0 Setup.exe
TestName = 1.install
MainAppFile = Tahomabd.TTF

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    IfNotExist, %A_WinDir%\Fonts\%MainAppFile%
        bExist := false
    else
        bExist := true

    ; Deleting %A_WinDir%\Fonts\%MainAppFile% succeeds using Windows Explorer.
    ; Deleting the file using Windows cmd fails ('access denied') for Admin user
    ; Deleting the file using AHK 'FileDelete' fails too

    TestsOK("")
    Run %ModuleExe%
}


; Test if 'Tahoma Font Family (Please read)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Tahoma Font Family, Please read, 5
    if ErrorLevel
        TestsFailed("'Tahoma Font Family (Please read)' window failed to appear.")
    else
    {
        ControlClick, Button1, Tahoma Font Family, Please read ; Hit 'Yes' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Yes' button in 'Tahoma Font Family (Please read)' window.")
        else
        {
            WinWaitClose, Tahoma Font Family, Please read, 3
            if ErrorLevel
                TestsFailed("'Tahoma Font Family (Please read)' window failed to close despite 'Yes' button being clicked.")
            else
                TestsOK("'Tahoma Font Family (Please read)' window appeared, 'Yes' button clicked and window closed.")
        }
    }
}


; Test if 'Tahome Font Family (Tahoma Regular and Bold)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Tahoma Font Family, Tahoma Regular and Bold, 5
    if ErrorLevel
        TestsFailed("'Tahoma Font Family (Tahoma Regular and Bold)' window failed to appear.")
    else
    {
        ControlClick, Button1, Tahoma Font Family, Tahoma Regular and Bold ; Hit 'OK' button
        if ErrorLevel
            TestsFailed("Unable to hit 'OK' button in 'Tahoma Font Family (Tahoma Regular and Bold)' window.")
        else
        {
            WinWaitClose, Tahoma Font Family, Tahoma Regular and Bold, 3
            if ErrorLevel
                TestsFailed("'Tahoma Font Family (Tahoma Regular and Bold)' window failed to close despite 'OK' button being clicked.")
            else
                TestsOK("'Tahoma Font Family (Tahoma Regular and Bold)' window appeared, 'OK' button clicked and window closed.")
        }
    }
}


; Check if file exists
TestsTotal++
if bContinue
{
    szFont = %A_WinDir%\Fonts\%MainAppFile%
    if bExist
    {
        IfNotExist, %szFont%
            TestsFailed("Something went wrong, can't find '" szFont "', but it was there before.")
        else
            TestsOK("The application has been installed, because '" szFont "' was found (it was there before too).")
    }
    else
    {
        IfNotExist, %szFont%
            TestsFailed("Something went wrong, can't find '" szFont "' and it was NOT there before.")
        else
            TestsOK("The application has been installed, because '" szFont "' was found (it was NOT there before).")
    }
}
