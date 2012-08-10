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

bContinue := false
TestsTotal := 0
TestsSkipped := 0
TestsFailed := 0
TestsOK := 0
TestsExecuted := 0
TestName = 2.ExtractArchive
szDocument = %A_WorkingDir%\Media\Filzip_TestFile.zip

; Test if can extract file to the C:\Filzip_Test
TestsTotal++
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
                                    {
                                        TestsOK()
                                        OutputDebug, OK: %TestName%:%A_LineNumber%: Archive was extracted. Text file contents were the same as expected.`n
                                    }
                                    else
                                    {
                                        TestsFailed()
                                        WinGetTitle, title, A
                                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Line 1 of 'C:\Filzip_Test\TestFile.txt' is not the same as expected (is '%OutputVar%', expected '%TestText%'). Active window caption: '%title%'.`n
                                    }
                                }
                                else
                                {
                                    TestsFailed()
                                    WinGetTitle, title, A
                                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT read contents of 'C:\Filzip_Test\TestFile.txt'. Active window caption: '%title%'.`n
                                }
                            }
                            else
                            {
                                TestsFailed()
                                WinGetTitle, title, A
                                OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'C:\Filzip_Test\TestFile.txt' does NOT exist, but it should. Active window caption: '%title%'`n
                            }
                        }
                        else
                        {
                            TestsFailed()
                            WinGetTitle, title, A
                            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Extract files' window failed to close. Active window caption: '%title%'`n
                        }
                    }
                    else
                    {
                        TestsFailed()
                        WinGetTitle, title, A
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Extract' button in 'Extract files' window. Active window caption: '%title%'`n
                    }
                }
                else
                {
                    TestsFailed()
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to set destination path in 'Extract files' window to 'C:\Filzip_Test'. Active window caption: '%title%'`n
                }
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Extract files' failed to appear when using Ctrl+Alt+E shortcut. Active window caption: '%title%'`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'TArcListView1' control in 'Filzip - %NameExt%' window. Active window caption: '%title%'`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Filzip - %NameExt%' failed to appear. Active window caption: '%title%'`n
    }
}
else
{
    TestsFailed()
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%szDocument%'.`n
}

Process, Close, 7zFM.exe