/*
 * Designed for Visual C++ 6 Redistributable
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

ModuleExe = %A_WorkingDir%\Apps\VC6RedistSetup_enu.exe
TestName = 1.install
InstallDir = %A_WinDir%\System32

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("Can NOT find '" ModuleExe "'.")
else
{
    IfExist, %InstallDir%\mfc42.dll
    {
        FileDelete, %InstallDir%\mfc42.dll
        if ErrorLevel
            TestsFailed("Unable to delete '" InstallDir "\mfc42.dll'.")
        else
        {
            IfExist, %InstallDir%\vcredist.exe ; remove this file too or installer will complain
            {
                FileDelete, %InstallDir%\vcredist.exe
                if ErrorLevel
                    TestsFailed("Unable to delete '" InstallDir "\vcredist.exe'.")
                else
                    TestsOK("")
            }
            else
                TestsOK("")
        }
    }
    else
    {
        IfExist, %InstallDir%\vcredist.exe
        {
            FileDelete, %InstallDir%\vcredist.exe
            if ErrorLevel
                TestsFailed("Unable to delete '" InstallDir "\vcredist.exe' (at least there is not '" InstallDir "\System32\mfc42.dll').")
            else
                TestsOK("")
        }
        else
            TestsOK("")
    }

    if bContinue
        Run %ModuleExe%
}


; Test if can click 'Yes' in 'VCRedist Installation (Please read)' window
TestsTotal++
if bContinue
{
    WinWaitActive, VCRedist Installation, Please read, 10
    if ErrorLevel
        TestsFailed("Window 'VCRedist Installation (Please read)' failed to appear.")
    else
    {
        Sleep, 1000
        ControlClick, Button1, VCRedist Installation, Please read ; Hit 'Yes' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Yes' button in 'VCRedist Installation (Please read)' window.")
        else
        {
            WinWaitClose, VCRedist Installation, Please read, 4
            if ErrorLevel
                TestsFailed("'VCRedist Installation (Please read)' window failed to close despite 'Yes' button being clicked.")
            else
                TestsOK("'VCRedist Installation (Please read)' window appeared, 'Yes' button clicked and window closed.")
        }
    }
}


; Test if can click 'OK' in 'VCRedist Installation (Please type)' window
TestsTotal++
if bContinue
{
    WinWaitActive, VCRedist Installation, Please type, 10
    if ErrorLevel
        TestsFailed("Window 'VCRedist Installation (Please type)' failed to appear.")
    else
    {
        ControlSetText, Edit1, %InstallDir%, VCRedist Installation, Please type
        if ErrorLevel
            TestsFailed("Unable to set path to '" InstallDir "' in 'VCRedist Installation (Please type)' window.")
        else
        {
            Sleep, 1000
            ControlClick, Button2, VCRedist Installation, Please type ; Hit 'OK' button
            if ErrorLevel
                TestsFailed("Unable to hit 'OK' button in 'VCRedist Installation (Please type)' window.")
            else
                TestsOK("'VCRedist Installation (Please type)' window appeared and 'OK' button was clicked.")
        }
    }
}


; Test if 'VCRedist Installation' window went away
TestsTotal++
if bContinue
{
    WinWaitClose, VCRedist Installation,,10
    if ErrorLevel
        TestsFailed("Window 'VCRedist Installation' failed to close.")
    else
        TestsOK("'VCRedist Installation (Please type)' window went away.")
}


; Check if installed file(s) exist
TestsTotal++
if bContinue
{
    Sleep, 7000 ; longer sleep is required
    ProgramFile = %InstallDir%\mfc42.dll
    IfNotExist, %ProgramFile%
        TestsFailed("Something went wrong, can't find '" ProgramFile "'.")
    else
        TestsOK("The application has been installed, because '" ProgramFile "' was found.")
}
