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
IfExist, %szDocument%
{
    FileRemoveDir, %A_Desktop%\7-Zip, 1
    FileCreateDir, %A_Desktop%\7-Zip
    if not ErrorLevel
    {
        RunApplication(szDocument)
        if bContinue
        {
            WinWaitActive, %szDocument%\,,7
            if not ErrorLevel
            {
                SendInput, {F5} ; Shortcut to 'Extract'
                WinWaitActive, Copy, Copy to, 7
                if not ErrorLevel
                {
                    ControlSetText, Edit1, %A_Desktop%\7-Zip, Copy, Copy to ; Path
                    if not ErrorLevel
                    {
                        ControlClick, Button2, Copy, Copy to ; Hit 'OK' button
                        if not ErrorLevel
                        {
                            Sleep, 4000 ; Give it some time to extract
                            IfExist, %A_Desktop%\7-Zip\TestFile.txt
                            {
                                FileReadLine, OutputVar, %A_Desktop%\7-Zip\TestFile.txt, 1
                                if not ErrorLevel
                                {
                                    TestText = If you can read this, then test works.
                                    if OutputVar = %TestText%
                                        TestsOK("")
                                    else
                                        TestsFailed("Line 1 of '" A_Desktop "\7-Zip\TestFile.txt' is not the same as expected (" OutputVar ").")
                                }
                                else
                                    TestsFailed("Can NOT read contents of '" A_Desktop "\7-Zip\TestFile.txt'.")
                            }
                            else
                                TestsFailed("Can NOT find '" A_Desktop "\7-Zip\TestFile.txt'.")
                        }
                        else
                            TestsFailed("Unable to hit 'OK' button in 'Copy (Copy to)' window.")
                    }
                    else
                        TestsFailed("Unable to change 'Edit1' control text to '" A_Desktop "\7-Zip'.")
                }
                else
                    TestsFailed("Window 'Copy (Copy to)' failed to appear. Shortcuts (F5) not working?")
            }
            else
                TestsFailed("Window '" PathToFile "\' failed to appear.")
        }
        else
            TestsFailed("We failed somwehere in 'prepare.ahk'.")
    }
    else
        TestsFailed("Failed to create '" A_Desktop "\7-Zip'.")
}
else
    TestsFailed("Can NOT find '" szDocument "'.")

Process, Close, 7zFM.exe