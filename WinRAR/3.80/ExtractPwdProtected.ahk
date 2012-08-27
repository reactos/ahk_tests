/*
 * Designed for WinRAR 3.80
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

TestName = 2.ExtractPwdProtected
szDocument =  %A_WorkingDir%\Media\PasswProtected.rar ; Case sensitive!

; Test if can extract password protected RAR archive
TestsTotal++
RunApplication(szDocument)
if not bContinue
    TestsFailed("We failed somewhere in prepare.ahk.")
else
{
    SplitPath, szDocument, NameExt
    WinWaitActive, %NameExt% - WinRAR (evaluation copy),,7
    if not ErrorLevel
    {
        WinMenuSelectItem, %NameExt% - WinRAR (evaluation copy), , Commands, Extract to the specified folder
        if not ErrorLevel
        {
            WinWaitActive, Extraction path and options,,7
            if not ErrorLevel
            {
                IfExist, %A_Desktop%\TestFile.txt
                {
                    FileDelete, %A_Desktop%\TestFile.txt
                    if not ErrorLevel
                    {
                        bContinue := true
                    }
                    else
                        TestsFailed("Unable to delete existing '" A_Desktop "\TestFile.txt'.") 
                }
                else
                {
                    bContinue := true
                }
                
                if bContinue
                {
                    Sleep, 1000
                    ControlSetText, Edit1, %A_Desktop%, Extraction path and options
                    if not ErrorLevel
                    {
                        Sleep, 1000
                        ControlClick, Button16, Extraction path and options ; Hit 'OK' button
                        if not ErrorLevel
                        {
                            WinWaitActive, Enter password, &Enter password, 7
                            if not ErrorLevel
                            {
                                Sleep, 1000
                                ControlSetText, Edit1, reactos, Enter password, Enter password
                                if not ErrorLevel
                                {
                                    Sleep, 1000
                                    ControlClick, Button1, Enter password, Enter password ; Hit 'OK' button
                                    if not ErrorLevel
                                    {
                                        WinWaitActive, %NameExt% - WinRAR (evaluation copy),,7
                                        if not ErrorLevel
                                        {
                                            Sleep, 1000
                                            WinClose, %NameExt% - WinRAR (evaluation copy)
                                            WinWaitClose, %NameExt% - WinRAR (evaluation copy),,7
                                            if not ErrorLevel
                                            {
                                                IfExist, %A_Desktop%\TestFile.txt
                                                {
                                                    FileReadLine, OutputVar, %A_Desktop%\TestFile.txt, 1
                                                    if not ErrorLevel
                                                    {
                                                        TestText = If you can read this, then test works.
                                                        if OutputVar = %TestText%
                                                            TestsOK("'" szDocument "' was extracted and application closed successfully.")
                                                        else
                                                            TestsFailed("Line 1 of '" A_Desktop "\TestFile.txt' is not the same as expected (" OutputVar ").")
                                                    }
                                                    else
                                                        TestsFailed("Can NOT read contents of '" A_Desktop "\TestFile.txt'.")
                                                }
                                                else
                                                    TestsFailed("Can NOT find '" A_Desktop "\TestFile.txt'.")
                                            }
                                            else
                                                TestsFailed("Window '" NameExt " - WinRAR (evaluation copy)' failed to close.")
                                        }
                                        else
                                            TestsFailed("Window '" NameExt " - WinRAR (evaluation copy)' failed to appear after extraction.")
                                    }
                                    else
                                        TestsFailed("Unable to hit 'OK' button in 'Enter password (Enter password)' window.")
                                }
                                else
                                    TestsFailed("Unable to enter password in 'Enter password (Enter password)' window.")
                            }
                            else
                                TestsFailed("Window 'Enter password (Enter password)' failed to appear.")
                        }
                        else
                            TestsFailed("Unable to hit 'OK' button in 'Extraction path and options' window.")
                    }
                    else
                        TestsFailed("Unable to enter 'Destination path' in 'Extraction path and options' window.")
                }
            }
            else
                TestsFailed("Window 'Extraction path and options' failed to appear.")
        }
        else
            TestsFailed("Unable to click 'Commands -> Extract to the specified folder' in '" NameExt " - WinRAR (evaluation copy)' window.")
    }
    else
        TestsFailed("Window '" NameExt " - WinRAR (evaluation copy)' failed to appear.")
}
