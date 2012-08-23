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

bContinue := false
TestsTotal := 0
TestsSkipped := 0
TestsFailed := 0
TestsOK := 0
TestsExecuted := 0
TestName = prepare

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Far manager, UninstallString
if not ErrorLevel
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\Far.exe
}
else
{
    ModuleExe = %A_ProgramFiles%\Far\Far.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}

Process, Close, Far.exe
Sleep, 1000

; Test if can start application
RunApplication()
{
    global ModuleExe
    global TestName
    global bContinue

    IfExist, %ModuleExe%
    {
        Run, %ModuleExe%
        Sleep, 1000
        WinWaitActive, {%A_ProgramFiles%\Far} - Far,, 10
        if not ErrorLevel
        {
            bContinue := true
            Sleep, 1000
        }
        else
        {
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window '{%A_ProgramFiles%\Far} - Far' failed to appear. Active window caption: '%title%'`n
        }
    }
    else
    {
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
    }
}