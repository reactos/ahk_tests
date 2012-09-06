/*
 * Designed for FAR Manager 1.70.2087
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

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Far manager, UninstallString
if ErrorLevel
{
    ModuleExe = %A_ProgramFiles%\Far\Far.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}
else
{
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\Far.exe
}


; Test if can start application
RunApplication()
{
    global ModuleExe
    global TestName
    global bContinue
    global TestsTotal

    TestsTotal++
    Process, Close, Far.exe
    Process, WaitClose, Far.exe, 4
    if ErrorLevel
        TestsFailed("Process 'Far.exe' failed to close.")
    else
    {
        IfNotExist, %ModuleExe%
            TestsFailed("Can NOT find '" ModuleExe "'.")
        else
        {
            Run, %ModuleExe%
            Sleep, 1000
            WinWaitActive, {%A_ProgramFiles%\Far} - Far,, 10
            if ErrorLevel
            {
                Process, Exist, Far.exe
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("Window '{" A_ProgramFiles "\Far} - Far' failed to appear. No 'Far.exe' process detected.")
                else
                    TestsFailed("Window '{" A_ProgramFiles "\Far} - Far' failed to appear. 'Far.exe' process detected.")
            }
            else
            {
                TestsOK("")
                Sleep, 1000
            }
        }
    }
}