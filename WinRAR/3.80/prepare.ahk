/*
 * Designed for WinRAR 3.80
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

Process, Close, WinRAR.exe
Sleep, 1500

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\WinRAR archiver, UninstallString
if not ErrorLevel
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\WinRAR.exe
}
else
{
    ModuleExe = %A_ProgramFiles%\WinRAR\WinRAR.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName

    Sleep, 500
    RegDelete, HKEY_CURRENT_USER, SOFTWARE\WinRAR
    Sleep, 500
    
    IfExist, %ModuleExe%
    {
        if PathToFile =
        {
            Run, %ModuleExe%,, Max ; Start maximized
            WinRARIntegration()
            WinWaitActive, WinRAR - WinRAR (evaluation copy),,7
            if not ErrorLevel
            {
                Sleep, 1000
            }
            else
            {
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'WinRAR - WinRAR (evaluation copy)' failed to appear. Active window caption: '%title%'`n
            }
        }
        else
        {
            IfExist, %PathToFile%
            {
                Run, %ModuleExe% "%PathToFile%",, Max
                WinRARIntegration()
                SplitPath, PathToFile, NameExt
                WinWaitActive, %NameExt% - WinRAR (evaluation copy),,7
                if not ErrorLevel
                {
                    Sleep, 1000
                }
                else
                {
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window '%NameExt% - WinRAR (evaluation copy)' failed to appear. Active window caption: '%title%'`n
                }
            }
            else
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%PathToFile%'.`n
            }
        }
    }
    else
    {
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
    }
}

WinRARIntegration()
{
    global TestName

    WinWaitActive, Settings, Integration,7
    if not ErrorLevel
    {
        Sleep, 1000
        ControlClick, Button27, Settings, Integration ; Hit 'OK' button
        if not ErrorLevel
        {
        }
        else
        {
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'OK' button in 'Settings (Integration)' window. Active window caption: '%title%'`n
        }
    }
    else
    {
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Settings (Integration)' failed to appear. Active window caption: '%title%'`n
    }
}
