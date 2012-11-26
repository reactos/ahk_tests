/*
 * Designed for Microsoft Visual Basic 6.0 Runtime
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

ModuleExe = %A_WorkingDir%\Apps\VB6.0 Runtime-KB290887-X86 Setup.exe
TestName = 1.install
MainAppFile = MSVBVM60.DLL
szEctractPath = C:\

; Test if Setup file exists, if so run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    szAppFile = %A_WinDir%\System32\%MainAppFile% ; Clean Win2k3 SP2 already comes with the file
    IfExist, %szAppFile%
        bExist := true
    else
        bExist := false

    TestsOK("")
    Run %ModuleExe%
}


; Test if 'Visual Basic 6.0 Runtime Redistribution (Do you accept)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Visual Basic 6.0 Runtime Redistribution, Do you accept, 5
    if ErrorLevel
        TestsFailed("'Visual Basic 6.0 Runtime Redistribution (Do you accept)' window failed to appear.")
    else
    {
        ControlClick, Button1, Visual Basic 6.0 Runtime Redistribution, Do you accept ; Hit 'Yes' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Yes' button in 'Visual Basic 6.0 Runtime Redistribution (Do you accept)' window.")
        else
        {
            WinWaitClose, Visual Basic 6.0 Runtime Redistribution, Do you accept, 3
            if ErrorLevel
                TestsFailed("'Visual Basic 6.0 Runtime Redistribution (Do you accept)' window failed to close despite 'Yes' button being clicked.")
            else
                TestsOK("'Visual Basic 6.0 Runtime Redistribution (Do you accept)' window appeared, 'Yes' button clicked and window closed.")
        }
    }
}


; Test if 'Visual Basic 6.0 Runtime Redistribution (Please type)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Visual Basic 6.0 Runtime Redistribution, Please type, 3
    if ErrorLevel
        TestsFailed("'Visual Basic 6.0 Runtime Redistribution (Please type)' window failed to appear.")
    else
    {
        ControlSetText, Edit1, %szEctractPath%, Visual Basic 6.0 Runtime Redistribution, Please type ; Enter path
        if ErrorLevel
            TestsFailed("Unable to enter path in 'Visual Basic 6.0 Runtime Redistribution (Please type)' window.")
        else
        {
            szExtracted = %szEctractPath%\vbrun60sp6.exe
            FileDelete, %szExtracted%
            ControlClick, Button2, Visual Basic 6.0 Runtime Redistribution, Please type ; Hit 'OK' button
            if ErrorLevel
                TestsFailed("Unable to hit 'OK' button in 'Visual Basic 6.0 Runtime Redistribution (Please type)' window.")
            else
            {
                WinWaitClose, Visual Basic 6.0 Runtime Redistribution, Please type, 3
                if ErrorLevel
                    TestsFailed("'Visual Basic 6.0 Runtime Redistribution (Please type)' window failed to close despite 'OK' button being clicked.")
                else
                    TestsOK("'Visual Basic 6.0 Runtime Redistribution (Please type)' window appeared, 'OK' button clicked and window closed.")
            }
        }
    }
}


; Test if extracted the file successfully, run actual setup and check if installation succeeded
TestsTotal++
if bContinue
{
    IfNotExist, %szExtracted%
        TestsFailed("Can NOT find '" szExtracted "'.")
    else
    {
        Run, %szExtracted% ; Start actual setup
        iTimeOut := 500
        while iTimeOut > 0
        {
            IfNotExist, %szAppFile%
            {
                Sleep, 10
                iTimeOut--
            }
            else
                break ; File exists
        }

        If bExist
        {
            IfNotExist, %szAppFile%
                TestsFailed("Something went wrong, can't find '" szAppFile "', but it was there before (iTimeOut='" iTimeOut "').")
            else
                TestsOK("The application has been installed, because '" szAppFile "' was found (it was there before too, iTimeOut='" iTimeOut "').")
        }
        else
        {
            IfNotExist, %szAppFile%
                TestsFailed("Something went wrong, can't find '" szAppFile "' and it was NOT there before (iTimeOut='" iTimeOut "').")
            else
                TestsOK("The application has been installed, because '" szAppFile "' was found (it was NOT there before, iTimeOut='" iTimeOut "').")
        }
    }
}
