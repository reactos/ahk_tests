/*
 * Designed for WinRAR 3.80
 * Copyright (C) 2013 Edijs Kolesnikovics
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

TestName = 3.add_archive

; Test if can create new archive
TestsTotal++
RunApplication("")
if bContinue
{
    IfWinNotActive, %szStartingFolder% - WinRAR (evaluation copy)
        TestsFailed("Window '" szStartingFolder " - WinRAR (evaluation copy)' is not active.")
    else
    {
        szTestDir = C:\WinRAR_Tests
        IfExist, %szTestDir%
        {
            FileRemoveDir, %szTestDir%, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" szTestDir "'.")
        }

        if bContinue
        {
            FileCreateDir, %szTestDir%
            if ErrorLevel
                TestsFailed("Unable to create '" szTestDir "'.")
            else
            {
                FileCopy, %A_ProgramFiles%\WinRAR\WinRAR.exe, %szTestDir%\
                if ErrorLevel != 0
                    TestsFailed("Unable to copy '" A_ProgramFiles "\WinRAR\WinRAR.exe' to '" szTestDir "'.")
                else
                {
                    ControlClick, Edit1, %szStartingFolder% - WinRAR (evaluation copy) ; ControlSetText still requires to send {ENTER}
                    if ErrorLevel
                        TestsFailed("Unable to click addressbar in order to focus it.")
                    else
                    {
                        SendInput, %szTestDir%{ENTER}
                        SplitPath, szTestDir, szTestFolderName
                        WinWaitActive, %szTestFolderName% - WinRAR (evaluation copy),,3
                        if ErrorLevel
                            TestsFailed("Unable to enter address in addressbar? Because '" szTestFolderName " - WinRAR (evaluation copy)' failed to appear.")
                        else
                            TestsOK("Copied WinRAR.exe and navigated to '" szTestDir "'.")
                    }
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    IfWinNotActive, %szTestFolderName% - WinRAR (evaluation copy)
        TestsFailed("'" szTestFolderName " - WinRAR (evaluation copy)' is not active anymore.")
    else
    {
        ControlFocus, SysListView321, %szTestFolderName% - WinRAR (evaluation copy)
        if ErrorLevel
            TestsFailed("Unable to focus 'SysListView321' control (list of files) in '" szTestFolderName " - WinRAR (evaluation copy)' window.")
        else
        {
            SendInput, ^a ; Ctrl+A
            WinMenuSelectItem, %szTestFolderName% - WinRAR (evaluation copy), , Commands, Add files to archive
            if ErrorLevel
                TestsFailed("Unable to perform 'Commands->Add files to archive' from main menu in '" szTestFolderName " - WinRAR (evaluation copy)' window.")
            else
            {
                WinWaitActive, Archive name and parameters, Archive name, 3
                if ErrorLevel
                    TestsFailed("Window 'Archive name and parameters (Archive name)' failed to appear despite 'Commands->Add files to archive' being clicked.")
                else
                {
                    ControlClick, Button14, Archive name and parameters, Archive name ; 'OK' button
                    if ErrorLevel
                        TestsFailed("Unable to click 'OK' button in 'Archive name and parameters (Archive name)' window.")
                    else
                    {
                        WinWaitClose, Archive name and parameters, Archive name, 3
                        if ErrorLevel
                            TestsFailed("'Archive name and parameters (Archive name)' window failed to close despite 'OK' button being closed.")
                        else
                        {
                            WinWaitActive, %szTestFolderName% - WinRAR (evaluation copy),,3
                            if ErrorLevel
                                TestsFailed("'Archive name and parameters (Archive name)' window closed, but '" szTestFolderName " - WinRAR (evaluation copy)' did not became active.")
                            else
                                TestsOK("Performed 'Commands->Add files to archive' and created new archive.")
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
    IfWinNotActive, %szTestFolderName% - WinRAR (evaluation copy)
        TestsFailed("'" szTestFolderName " - WinRAR (evaluation copy)' is not active anymore.")
    else
    {
        szNewArchive = %szTestDir%\WinRAR.rar
        IfNotExist, %szNewArchive%
            TestsFailed("'" szNewArchive "' does not exist.")
        else
        {
            Sleep, 1500
            FileGetSize, iFileSize, %szNewArchive%
            if ErrorLevel
                TestsFailed("Unable to get file size of '" szNewArchive "'.")
            else
            {
                IfNotInString, iFileSize, %iExpectedSize%
                    TestsFailed("'" szNewArchive "' file size doesn't macth. Is '" iFileSize "', should be '" iExpectedSize "'.")
                else
                    TestsOK("Succeeded creating new *.rar archive using 'Commands->Add files to archive'. File size is the same as expected.")
            }
        }
    }
}


bTerminateProcess(ProcessExe)
