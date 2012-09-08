/*
 * Designed for Foxit Reader 2.1.2023
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

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Foxit Reader, UninstallString
if ErrorLevel
{
    ModuleExe = %A_ProgramFiles%\Foxit Software\Foxit Reader.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}
else
{
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\Foxit Reader.exe
}


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global TestsTotal

    TestsTotal++
    SplitPath, ModuleExe, ProcessExe
    Process, Close, %ProcessExe%
    Process, WaitClose, %ProcessExe%, 4
    if ErrorLevel
        TestsFailed("Process '" ProcessExe "' failed to close.")
    else
    {
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\Foxit Sofrware\Foxit Reader
        Sleep, 500
        ; Disable 'Set Foxit Readed to be default PDF reader' dialog
        RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Foxit Software\Foxit Reader\MainFrame, CheckRegister, 0
        
        IfNotExist, %ModuleExe%
            TestsFailed("Can NOT find '" ModuleExe "'.")
        else
        {
            if PathToFile =
            {
                Run, %ModuleExe%,, Max ; Start maximized
                WinWaitActive, Foxit Reader 2.1,,7
                if ErrorLevel
                {
                    Process, Exist, %ProcessExe%
                    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                    if NewPID = 0
                        TestsFailed("Window 'Foxit Reader 2.1' failed to appear. No '" ProcessExe "' process detected.")
                    else
                        TestsFailed("Window 'Foxit Reader 2.1' failed to appear. '" ProcessExe "' process detected.")
                }
                else
                {
                    TestsOK("")
                    Sleep, 1000
                }
            }
            else
            {
                IfNotExist, %PathToFile%
                    TestsFailed("Can NOT find '" PathToFile "'.")
                else
                {
                    Run, %ModuleExe% "%PathToFile%",, Max
                    Sleep, 1000
                    SplitPath, PathToFile, NameExt
                    WinWaitActive, %NameExt% - Foxit Reader 2.1 - [%NameExt%],,7
                    if ErrorLevel
                    {
                        Process, Exist, %ProcessExe%
                        NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                        if NewPID = 0
                            TestsFailed("Window '" NameExt " - Foxit Reader 2.1 - [" NameExt "]' failed to appear. No '" ProcessExe "' process detected.")
                        else
                            TestsFailed("Window '" NameExt " - Foxit Reader 2.1 - [" NameExt "]' failed to appear. '" ProcessExe "' process detected.")
                    }
                    else
                    {
                        TestsOK("")
                        Sleep, 1000
                    }
               } 
            }
        }
    }
}
