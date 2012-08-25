/*
 * Designed for Filzip 3.0.6
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
szDocument = %A_WorkingDir%\Media\Filzip_TestFile.zip

; Test if can extract file to the C:\Filzip_Test
TestsTotal++
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfExist, %szDocument%
    {
        FileRemoveDir, C:\Filzip_Test, 1
        RunApplication(szDocument)
        SplitPath, szDocument, NameExt
        WinWaitActive, Filzip - %NameExt%,,7
        if not ErrorLevel
        {
            ControlClick, TArcListView1, Filzip - %NameExt%
            if not ErrorLevel
            {
                SendInput, {CTRLDOWN}a{CTRLUP} ; Select all files in archive
                SendInput, {CTRLDOWN}{ALTDOWN}e{ALTUP}{CTRLUP} ; Open 'Exctract files' dialog
                WinWaitActive, Extract files,,7
                if not ErrorLevel
                {
                    ControlSetText, Edit1, C:\Filzip_Test, Extract files
                    if not ErrorLevel
                    {
                        Sleep, 500
                        ControlClick, TButton3, Extract files
                        if not ErrorLevel
                        {
                            WinWaitClose, Extract files,,7
                            if not ErrorLevel
                            {
                                Sleep, 500
                                IfExist, C:\Filzip_Test\TestFile.txt
                                {
                                    FileReadLine, OutputVar, C:\Filzip_Test\TestFile.txt, 1
                                    if not ErrorLevel
                                    {
                                        TestText = Test was successfull.
                                        if OutputVar = %TestText%
                                            TestsOK("Archive was extracted. Text file contents were the same as expected.")
                                        else
                                            TestsFailed("Line 1 of 'C:\Filzip_Test\TestFile.txt' is not the same as expected (is '" OutputVar "', expected '" TestText "').")
                                    }
                                    else
                                        TestsFailed("Can NOT read contents of 'C:\Filzip_Test\TestFile.txt'.")
                                }
                                else
                                    TestsFailed("'C:\Filzip_Test\TestFile.txt' does NOT exist, but it should.")
                            }
                            else
                                TestsFailed("'Extract files' window failed to close.")
                        }
                        else
                            TestsFailed("Unable to hit 'Extract' button in 'Extract files' window.")
                    }
                    else
                        TestsFailed("Unable to set destination path in 'Extract files' window to 'C:\Filzip_Test'.")
                }
                else
                    TestsFailed("Window 'Extract files' failed to appear when using Ctrl+Alt+E shortcut.")
            }
            else
                TestsFailed("Unable to click 'TArcListView1' control in 'Filzip - %NameExt%' window.")
        }
        else
            TestsFailed("Window 'Filzip - %NameExt%' failed to appear.")
    }
    else
        TestsFailed("Can NOT find '" szDocument "'.")
}

Process, Close, 7zFM.exe