/*
 * Designed for Tile World 1.3.0
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

ModuleExe = %A_WorkingDir%\Apps\Tile World 1.3.0 Setup.exe
TestName = 1.install
MainAppFile = tworld.exe

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("Can NOT find '" ModuleExe "'")
else
{
    Process, Close, %MainAppFile%
    Process, WaitClose, %MainAppFile%, 4
    if ErrorLevel
        TestsFailed("Process '" MainAppFile "' failed to close.")
    else
    {
        InstallLocation = %A_ProgramFiles%\Tile World
        IfNotExist, %InstallLocation%
            bContinue := true ; No previous versions detected.
        else
        {
            FileRemoveDir, %InstallLocation%, 1
            if ErrorLevel
                TestsFailed("Previous version detected and failed to delete '" InstallLocation "'. '" MainAppFile "' process not detected.")
            else
                bContinue := true
        }
        
        if bContinue
        {
            FileCreateDir, %InstallLocation%
            if ErrorLevel
                TestsFailed("Unable to create '" InstallLocation "'.")
            else
            {
                FileCopy, %ModuleExe%, %InstallLocation%\Tile World 1.3.0 Setup.exe
                if ErrorLevel
                    TestsFailed("Can NOT copy '" ModuleExe "' to '" InstallLocation "'.")
                else
                {
                    Run %InstallLocation%\Tile World 1.3.0 Setup.exe
                    TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
                }
            }
        }
    }
}


; Test if '\Tile World 1.3.0 Setup.exe (Contents)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, \Tile World 1.3.0 Setup.exe, Contents, 5
    if ErrorLevel
        TestsFailed("'\Tile World 1.3.0 Setup.exe (Contents)' window failed to appear.")
    else
    {
        ControlClick, Button1, \Tile World 1.3.0 Setup.exe, Contents ; Hit 'Extract' button
        if ErrorLevel
            TestsFailed("Unable to click 'Extract' in '\Tile World 1.3.0 Setup.exe (Contents)' window.")
        else
            TestsOK("'\Tile World 1.3.0 Setup.exe (Contents)' window appeared and 'Extract' button was clicked.")
    }
}


; Test if '\Tile World 1.3.0 Setup.exe (All files extracted OK)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, \Tile World 1.3.0 Setup.exe, All files extracted OK, 5
    if ErrorLevel
        TestsFailed("'\Tile World 1.3.0 Setup.exe (All files extracted OK)' window failed to appear.")
    else
    {
        ControlClick, Button1, \Tile World 1.3.0 Setup.exe, All files extracted OK ; Hit 'OK' button
        if ErrorLevel
            TestsFailed("Unable to click 'OK' in '\Tile World 1.3.0 Setup.exe (All files extracted OK)' window.")
        else
        {
            WinWaitClose, \Tile World 1.3.0 Setup.exe, All files extracted OK, 3
            if ErrorLevel
                TestsFailed("'\Tile World 1.3.0 Setup.exe (All files extracted OK)' window failed to close despite 'OK' button being clicked.")
            else
                TestsOK("'\Tile World 1.3.0 Setup.exe (All files extracted OK)' window appeared, 'OK' button clicked and window closed.")
        }
    }
}


; Test if '\Tile World 1.3.0 Setup.exe (Contents)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, \Tile World 1.3.0 Setup.exe, Contents, 3
    if ErrorLevel
        TestsFailed("'\Tile World 1.3.0 Setup.exe (Contents)' window failed to appear.")
    else
    {
        ControlClick, Button2, \Tile World 1.3.0 Setup.exe, Contents ; Hit 'Done' button
        if ErrorLevel
            TestsFailed("Unable to click 'Done' in '\Tile World 1.3.0 Setup.exe (Contents)' window.")
        else
        {
            WinWaitClose, \Tile World 1.3.0 Setup.exe, Contents, 3
            if ErrorLevel
                TestsFailed("'\Tile World 1.3.0 Setup.exe (Contents)' window failed to close despite 'Done' button being clicked.")
            else
                TestsOK("'\Tile World 1.3.0 Setup.exe (Contents)' window appeared, 'Done' button clicked and window closed.")
        }
    }
}


; Check if program exist
TestsTotal++
if bContinue
{
    IfExist, %InstallLocation%\%MainAppFile%
        TestsOK("The application has been installed, because '" InstallLocation "\" MainAppFile "' was found.")
    else
        TestsFailed("Something went wrong, can't find '" InstallLocation "\" MainAppFile "'.")
}
