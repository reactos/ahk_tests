/*
 * Designed for Foxit IrfanView 4.23
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

Process, Close, i_view32.exe
Sleep, 1500

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\IrfanView, UninstallString
if not ErrorLevel
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\i_view32.exe
}
else
{
    ModuleExe = %A_ProgramFiles%\IrfanView\i_view32.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global bContinue

    Sleep, 500
    FileRemoveDir, %A_AppData%\IrfanView, 1
    Sleep, 500
    
    IfExist, %ModuleExe%
    {
        if PathToFile =
        {
            Run, %ModuleExe%,, Max ; Start maximized
            WinWaitActive, IrfanView,,7
            if not ErrorLevel
            {
                bContinue := true
                Sleep, 1000
            }
            else
            {
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'IrfanView' failed to appear. Active window caption: '%title%'`n
            }
        }
        else
        {
            Run, %ModuleExe% "%PathToFile%",, Max
            Sleep, 1000
            SplitPath, PathToFile, NameExt
            WinWaitActive, %NameExt% - IrfanView,,7
            if not ErrorLevel
            {
                bContinue := true
                Sleep, 1000
            }
            else
            {
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window '%NameExt% - IrfanView' failed to appear. Active window caption: '%title%'`n
            }
        }
    }
    else
    {
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
    }
}
