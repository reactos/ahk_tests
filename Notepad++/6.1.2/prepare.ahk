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

TestName = prepare

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++, UninstallString
if ErrorLevel
{
    ModuleExe = %A_ProgramFiles%\Notepad++\notepad++.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}
else
{
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\notepad++.exe
}


; Terminate application
TestsTotal++
SplitPath, ModuleExe, ProcessExe
Process, Close, %ProcessExe%
Process, WaitClose, %ProcessExe%, 4
if ErrorLevel
    TestsFailed("Process '" ProcessExe "' failed to close.")
else
    TestsOK("")


RunNotepad(PathToFile)
{
    global ModuleExe
    global TestName
    global bContinue
    global TestsTotal
    global ProcessExe
    
    TestsTotal++
    IfNotExist, %ModuleExe%
        TestsFailed("Can NOT find '" ModuleExe "'.")
    else
    {
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
                    {
                        Process, Exist, %ProcessExe%
                        NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                        if NewPID = 0
                            TestsFailed("Window 'new  1 - Notepad++' failed to appear. No '" ProcessExe "' process detected.")
                        else
                            TestsFailed("Window 'new  1 - Notepad++' failed to appear. '" ProcessExe "' process detected.")
                    }
                    else
                    {
                        Sleep, 1000
                        TestsOK("")
                    }
                }
                else
                {
                    IfNotExist, %PathToFile%
                        TestsFailed("Can NOT find '" PathToFile "'.")
                    else
                    {
                        Run, %ModuleExe% %PathToFile%,, Max
                        Sleep, 1000
                        WinWaitActive, %PathToFile% - Notepad++,,10
                        if ErrorLevel
                        {
                            Process, Exist, %ProcessExe%
                            NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                            if NewPID = 0
                                TestsFailed("Window '" PathToFile " - Notepad++' failed to appear. No '" ProcessExe "' process detected.")
                            else
                                TestsFailed("Window '" PathToFile " - Notepad++' failed to appear. '" ProcessExe "' process detected.")
                        }
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
}
