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

ModuleExe = %A_ProgramFiles%\Notepad++\notepad++.exe
bContinue := false
TestsTotal := 0
TestsSkipped := 0
TestsFailed := 0
TestsOK := 0
TestsExecuted := 0


RunNotepad(PathToFile)
{
    global ModuleExe
    global TestName
    global bContinue
    global TestsTotal
    
    TestsTotal++

    Sleep, 500
    IfNotExist, %ModuleExe%
        TestsFailed("Can NOT find '" ModuleExe "'.")
    else
    { 
        Process, Close, notepad++.exe ; Teminate process
        FileRemoveDir, %A_AppData%\Notepad++, 1
        FileCreateDir, %A_AppData%\Notepad++
        IfNotExist, %A_WorkingDir%\Media\Notepadpp_config.xml
            TestsFailed("Can NOT find '" A_WorkingDir "\Media\Notepadpp_config.xml'.")
        else
        {
            FileCopy, %A_WorkingDir%\Media\Notepadpp_config.xml, %A_AppData%\Notepad++\config.xml
            if ErrorLevel <> 0
                TestsFailed("Unable to copy '" A_WorkingDir "\Media\Notepadpp_config.xml' to '" A_AppData "\Notepad++\config.xml'.")
            else
            {
                if PathToFile =
                {
                    Run, %ModuleExe%,, Max ; Start maximized
                    Sleep, 1000
                    WinWaitActive, new  1 - Notepad++,,10
                    if ErrorLevel
                        TestsFailed("Window 'new  1 - Notepad++' failed to appear.")
                    else
                    {
                        Sleep, 1000
                        TestsOK("")
                    }
                }
                else
                {
                    Run, %ModuleExe% %PathToFile%,, Max
                    Sleep, 1000
                    WinWaitActive, %PathToFile% - Notepad++,,10
                    if ErrorLevel
                        TestsFailed("Window '" PathToFile " - Notepad++' failed to appear.")
                    else
                    {
                        Sleep, 1000
                        TestsOK("")
                    }
                }
            }
        }
    }
}
