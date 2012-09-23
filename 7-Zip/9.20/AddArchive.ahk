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
if ErrorLevel
    TestsFailed("Unable to create '" A_ProgramFiles "\7-Zip\AHK_Test'.")
else
{
    FileDelete, %A_ProgramFiles%\7-Zip\AHK_Test\SampleFile.7z
    FileAppend, One line.`nLine two`nLine 3, %A_ProgramFiles%\7-Zip\AHK_Test\SampleFile.txt
    if ErrorLevel
        TestsFailed("Unable to create and edit '" A_ProgramFiles "\7-Zip\AHK_Test\SampleFile.txt'.")
    else
    {
        RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\7-Zip\FM, PanelPath0, %A_ProgramFiles%\7-Zip\AHK_Test
        if ErrorLevel
            TestsFailed("Unable to write to the registry.")
        else
        {
            IfNotExist, %ModuleExe%
                TestsFailed("Can NOT find '" ModuleExe "'.")
            else
            {
                Run, %ModuleExe%,, Max ; Start maximized (we dont want 'RunApplication("")' here, as we write settings ourself)
                WinWaitActive, %A_ProgramFiles%\7-Zip\AHK_Test,, 7
                if ErrorLevel
                    TestsFailed("'" A_ProgramFiles "\7-Zip\' window failed to appear.")
                else
                {
                    SendInput {Down} ; We have only one file there, so hit down arrow to select that file
                    SendInput !F ; Alt+F (File)
                    SendInput {Right} ; 7-Zip -> Add to archive
                    SendInput {Enter}
                    WinWaitActive, Add to Archive,, 7
                    if ErrorLevel
                        TestsFailed("'Add to Archive' window failed to appear.")
                    else
                    {
                        ControlClick, Button8, Add to Archive
                        if ErrorLevel
                            TestsFailed("Unable to click 'OK' button in 'Add to Archive' window.")
                        else
                        {
                            IfNotExist, %A_ProgramFiles%\7-Zip\AHK_Test\SampleFile.7z
                                TestsFailed("'" A_ProgramFiles "\7-Zip\AHK_Test\SampleFile.7z' doesn't exist.")
                            else
                            {
                                TestsOK("Created archive '" A_ProgramFiles "\7-Zip\AHK_Test\SampleFile.7z' successfully.") 
                                TerminateApplication() ; We don't care now if application can close correctly, so, terminate
                            }
                        }
                    }
                }
            }
        }
    }
}
