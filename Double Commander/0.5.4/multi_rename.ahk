/*
 * Designed for Double Commander 0.5.4
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

TestName = 2.multi_rename

; Test if can rename two files using 'Files->Multi Rename Tool' and close application
TestsTotal++
WriteSettings()
if bContinue
{
    szFile1 = %szPathLeft%\File1.txt
    szFile2 = %szPathLeft%\File2.txt
    FileAppend, Text file 1, %szFile1%
    if ErrorLevel
        TestsFailed("Unable to create '" szFile1 "'.")
    else
    {
        FileAppend, Text file 2, %szFile2%
        if ErrorLevel
            TestsFailed("Unable to create '" szFile2 "'.")
        else
        {
            RunApplication()
            if bContinue
            {
                IfWinNotActive, Double Commander
                    TestsFailed("'Double Commander' is not an active window.")
                else
                {
                    ControlClick, Window25, Double Commander ; Hit left side of application window that we have files in
                    if ErrorLevel
                        TestsFailed("Unable to hit the window that contains '" szPathLeft "' path in it.")
                    else
                    {
                        SendInput, ^a ; Cltr+A aka select all files
                        SendInput, ^m ; Cltr+M aka Files->Multi Rename Tool. WinMenuSelectItem doesn't work here
                        WinWaitActive, MultiRename,,3
                        if ErrorLevel
                            TestsFailed("'MultiRename' window failed to appear.")
                        else
                            TestsOK("'MultiRename' window appeared.")
                    }
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    ControlSetText, Edit6, Fil, MultiRename ; Enter 'Fil' in 'Find' field
    if ErrorLevel
        TestsFailed("Unable to enter 'Fil' to 'Find' field in 'MultiRename' window.")
    else
    {
        ControlSetText, Edit5, Nam, MultiRename ; Enter 'Nam' in 'Replace' field
        if ErrorLevel
            TestsFailed("Unable to enter 'Nam' to 'Replace' field in 'MultiRename' window.")
        else
        {
            ControlClick, Button9 ; Hit 'Rename' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Rename' button in 'MultiRename' window.")
            else
            {
                IfWinNotActive, MultiRename
                    TestsFailed("For some reason 'MultiRename' window is not active anymore.")
                else
                {
                    SendInput, !c ; Alt+C aka hit 'Close' button
                    WinWaitClose, MultiRename,,3
                    if ErrorLevel
                        TestsFailed("'MultiRename' window failed to close despite Alt+C was sent.")
                    else
                    {
                        WinWaitActive, Double Commander,,3
                        if ErrorLevel
                            TestsFailed("'Double Commander' did not became active after closing 'MultiRename' window.")
                        else
                        {
                            IfNotExist, %szPathLeft%\Name2.txt
                                TestsFailed("Renamed file, but for some reason '" szPathLeft "\Name2.txt' does not exist.")
                            else
                                TestsOK("'" szPathLeft "\Name2.txt' exist, so, multi rename works.")
                        }
                    }
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    WinClose, Double Commander
    WinWaitClose,,,3
    if ErrorLevel
        TestsFailed("Unable to close 'Double Commander' window.")
    else
    {
        Process, WaitClose, %ProcessExe%, 4
        if ErrorLevel
            TestsFailed("'" ProcessExe "' process failed to close despite 'Double Commander' window was closed.")
        else
            TestsOK("Closed application successfully.")
    }
}
