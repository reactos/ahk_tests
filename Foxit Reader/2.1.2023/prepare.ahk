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

bContinue := false
TestsTotal := 0
TestsSkipped := 0
TestsFailed := 0
TestsOK := 0
TestsExecuted := 0
TestName = prepare

Process, Close, Foxit Reader.exe
Sleep, 1500

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Foxit Reader, UninstallString
if not ErrorLevel
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\Foxit Reader.exe
}
else
{
    ModuleExe = %A_ProgramFiles%\Foxit Software\Foxit Reader.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName

    Sleep, 500
    RegDelete, HKEY_CURRENT_USER, SOFTWARE\Foxit Sofrware\Foxit Reader
    Sleep, 500
    ; Disable 'Set Foxit Readed to be default PDF reader' dialog
    RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Foxit Sofrware\Foxit Reader\MainFrame, CheckRegister, 0
    
    IfExist, %ModuleExe%
    {
        if PathToFile =
        {
            Run, %ModuleExe%,, Max ; Start maximized
            WinWaitActive, Foxit Reader 2.1,,7
            if not ErrorLevel
            {
                Sleep, 1000
                ; TestsOK()
            }
            else
            {
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Foxit Reader 2.1' failed to appear. Active window caption: '%title%'`n
            }
        }
        else
        {
            Run, %ModuleExe% "%PathToFile%",, Max
            Sleep, 1000
            SplitPath, PathToFile, NameExt
            WinWaitActive, %NameExt% - Foxit Reader 2.1 - [%NameExt%],,7
            if not ErrorLevel
            {
                ; TestsOK()
            }
            else
            {
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window '%NameExt% - Foxit Reader 2.1 - [%NameExt%]' failed to appear. Active window caption: '%title%'`n
            }
        }
    }
    else
    {
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
    }
}
