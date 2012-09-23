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

; Test if the app is installed
TestsTotal++
RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++, UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\notepad++.exe
    TestsOK("")
}


; Test if can terminate application
TerminateApplication()


TerminateApplication()
{
    global TestsTotal
    global bContinue
    global ModuleExe

    TestsTotal++
    SplitPath, ModuleExe, ProcessExe
    Process, Close, %ProcessExe%
    Process, WaitClose, %ProcessExe%, 4
    if ErrorLevel
        TestsFailed("Process '" ProcessExe "' failed to close.")
    else
        TestsOK("")
}


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
                    WinWaitActive, new  1 - Notepad++,,5
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
                        TestsOK("")
                }
                else
                {
                    IfNotExist, %PathToFile%
                        TestsFailed("Can NOT find '" PathToFile "'.")
                    else
                    {
                        Run, %ModuleExe% %PathToFile%,, Max
                        WinWaitActive, %PathToFile% - Notepad++,,5
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
                            TestsOK("")
                    }
                }
            }
        }
    }
}
