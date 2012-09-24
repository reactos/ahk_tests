/*
 * Designed for 7-Zip 4.65
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

TestName = 2.ExtractArchive
szDocument = %A_WorkingDir%\Media\7Zip_TestFile.7z


; Test if can extract file to the folder in desktop
TestsTotal++
IfNotExist, %szDocument%
    TestsFailed("Can NOT find '" szDocument "'.")
else
{
    FileRemoveDir, %A_Desktop%\7-Zip, 1
    FileCreateDir, %A_Desktop%\7-Zip
    if ErrorLevel
        TestsFailed("Failed to create '" A_Desktop "\7-Zip'.")
    else
    {
        RunApplication(szDocument)
        if not bContinue
            TestsFailed("We failed somwehere in 'prepare.ahk'.")
        else
        {
            WinWaitActive, %szDocument%\,,7
            if ErrorLevel
                TestsFailed("Window '" PathToFile "\' failed to appear.")
            else
            {
                SendInput, {F5} ; Shortcut to 'Extract'
                WinWaitActive, Copy, Copy to, 7
                if ErrorLevel
                    TestsFailed("Window 'Copy (Copy to)' failed to appear. Shortcuts (F5) not working?")
                else
                {
                    ControlSetText, Edit1, %A_Desktop%\7-Zip, Copy, Copy to ; Path
                    if ErrorLevel
                        TestsFailed("Unable to change 'Edit1' control text to '" A_Desktop "\7-Zip'.")
                    else
                    {
                        ControlClick, Button2, Copy, Copy to ; Hit 'OK' button
                        if ErrorLevel
                            TestsFailed("Unable to hit 'OK' button in 'Copy (Copy to)' window.")
                        else
                        {
                            Sleep, 3000 ; Give it some time to extract (there is some window, but AHK might not detect it, so hardcode sleep)
                            IfNotExist, %A_Desktop%\7-Zip\TestFile.txt
                                TestsFailed("Can NOT find '" A_Desktop "\7-Zip\TestFile.txt'.")
                            else
                            {
                                FileReadLine, OutputVar, %A_Desktop%\7-Zip\TestFile.txt, 1
                                if ErrorLevel
                                    TestsFailed("Can NOT read contents of existing file '" A_Desktop "\7-Zip\TestFile.txt'.")
                                else
                                {
                                    TestText = If you can read this, then test works.
                                    if OutputVar <> %TestText%
                                        TestsFailed("Line 1 of '" A_Desktop "\7-Zip\TestFile.txt' is not the same as expected (expected '" TestText "', got '" OutputVar "').")
                                    else
                                    {
                                        Process, Exist, 7zFM.exe
                                        if ErrorLevel = 0
                                            TestsFailed("Process '7zFM.exe' does not exist.")
                                        else
                                        {
                                            Process, Close, 7zFM.exe
                                            Process, WaitClose, 7zFM.exe, 4
                                            if ErrorLevel
                                                TestsFailed("Unable to terminate '7zFM.exe' process.")
                                            else
                                                TestsOK("Extracted text file from an archive, its contents were as expected, '7zFM.exe' process terminated. ")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}