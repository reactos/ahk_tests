/*
 * Designed for VLC 0.8.6i
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

Process, Close, vlc.exe

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\VLC media player, UninstallString
if not ErrorLevel
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\vlc.exe
}
else
{
    ModuleExe = %A_ProgramFiles%\VideoLAN\VLC\vlc.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}

; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global bContinue

    Sleep, 500
    FileRemoveDir, %A_AppData%\vlc, 1 ; Delete saved settings
    IfExist, %ModuleExe%
    {
        if PathToFile =
        {
            Run, %ModuleExe% ; Don't run it maximized
            Sleep, 1000
            WinWaitActive, VLC media player,,7
            if not ErrorLevel
            {
                bContinue := true
                Sleep, 1000
            }
            else
            {
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'VLC media player' failed to appear. Active window caption: '%title%'`n
            }
        }
        else
        {
            IfExist, %PathToFile%
            {
                Run, %ModuleExe% "%PathToFile%" ; Don't run it maximized
                Sleep, 1000
                WinWaitActive, VLC media player,,7 ; FIXME: is there a way to show filename in titlebar?
                if not ErrorLevel
                {
                    bContinue := true
                    Sleep, 1000
                }
                else
                {
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'VLC media player' failed to appear when opening '%PathToFile%'. Active window caption: '%title%'`n
                }
            }
            else
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%PathToFile%'.`n
        }
    }
    else
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
}
