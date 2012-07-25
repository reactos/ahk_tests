/*
 * Designed for Notepad++ 6.1.2
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

; Test if can create archive

TestsTotal++
TestName = 2.AddArchive

FileCreateDir, %A_ProgramFiles%\7-Zip\AHK_Test
FileDelete, %A_ProgramFiles%\7-Zip\AHK_Test\SampleFile.7z
FileAppend, One line.`nLine two`nLine 3, %A_ProgramFiles%\7-Zip\AHK_Test\SampleFile.txt
RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\7-Zip\FM, PanelPath0, %A_ProgramFiles%\7-Zip\AHK_Test
if not ErrorLevel
{
    Run, %A_ProgramFiles%\7-Zip\7zFM.exe,, Max
    WinWaitActive, %A_ProgramFiles%\7-Zip\AHK_Test,, 7
    if not ErrorLevel
    {
        SendInput {Down} ; We have only one file there, so hit down arrow to select that file
        SendInput !F ; Alt+F (File)
        SendInput {Right} ; 7-Zip -> Add to archive
        SendInput {Enter}
        WinWaitActive, Add to Archive,, 7
        if not ErrorLevel
        {
            if LeftClickControl("Button8")
            {
                Sleep, 2500 ; Give it some time to archive
                IfExist, %A_ProgramFiles%\7-Zip\AHK_Test\SampleFile.7z
                {
                    TestsOK++
                    OutputDebug, %TestName%:%A_LineNumber%:OK: '%A_ProgramFiles%\7-Zip\AHK_Test\SampleFile.7z' exist. Active window caption: '%title%'`n
                    bContinue := true
                }
                else
                {
                    TestsFailed++
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%A_ProgramFiles%\7-Zip\AHK_Test\SampleFile.7z' doesn't exist. Active window caption: '%title%'`n
                    bContinue := false
                }
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'OK' button was not clicked in 'Add to Archive' window. Active window caption: '%title%'`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Add to Archive' window failed to appear. Active window caption: '%title%'`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%A_ProgramFiles%\7-Zip\' window failed to appear. Active window caption: '%title%'`n
        bContinue := false
    }
}


Process, close, 7zFM.exe ; We don't care now if application can close correctly, so, terminate