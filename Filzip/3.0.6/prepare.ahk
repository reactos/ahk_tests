/*
 * Designed for Filzip 3.0.6
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

Process, Close, Filzip.exe
Sleep, 1500

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Filzip 3.0.6.93_is1, UninstallString
if not ErrorLevel
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\Filzip.exe
}
else
{
    ModuleExe = %A_ProgramFiles%\Filzip\Filzip.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName

    Sleep, 500
    RegDelete, HKEY_CURRENT_USER, SOFTWARE\Filzip
    Sleep, 500
    ; Disable auto update. We do not wan't any unexpected popups coming out.
    RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Filzip\Config\AutoUpd, AutoUpd, 0
    RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Filzip\Config\Settings, RegDialog, 0 ; Disable registration dialog
    
    IfExist, %ModuleExe%
    {
        if PathToFile =
        {
            Run, %ModuleExe%,, Max ; Start maximized
            AssociateWithFilzip()
            WinWaitActive, Filzip,,7
            if not ErrorLevel
            {
                Sleep, 1000
                ; TestsOK()
            }
            else
            {
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Filzip' failed to appear. Active window caption: '%title%'`n
            }
        }
        else
        {
            Run, %ModuleExe% "%PathToFile%",, Max
            Sleep, 1000
            AssociateWithFilzip()
            SplitPath, PathToFile, NameExt
            WinWaitActive, Filzip - %NameExt%,,7
            if not ErrorLevel
            {
                ; TestsOK()
            }
            else
            {
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Filzip - %NameExt%' failed to appear. Active window caption: '%title%'`n
            }
        }
    }
    else
    {
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
    }
}

AssociateWithFilzip()
{
    WinWaitActive, Associate with Filzip, Never ask again,7
    if not ErrorLevel
    {
        ControlClick, TButton2, Associate with Filzip ; Hit 'Associate' button
        if not ErrorLevel
        {
            OutputDebug, OK: %TestName%:%A_LineNumber%: Archive files were associated with Filzip.`n
        }
        else
        {
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Associate' button in 'Associate with Filzip (Never ask again)' window. Active window caption: '%title%'`n
        }
    }
    else
    {
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Associate with Filzip (Never ask again)' failed to appear. Active window caption: '%title%'`n
    }
}
