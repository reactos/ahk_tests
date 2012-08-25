/*
 * Designed for Adobe Reader 7.1.0
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

Process, Close, AcroRd32.exe

RegRead, InstalledPathReg, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{AC76BA86-7AD7-1033-7B44-A71000000002}, InstallLocation
if not ErrorLevel
{
    StringReplace, InstalledPathReg, InstalledPathReg, `",, All ; String contains quotes, replace em
    SplitPath, InstalledPathReg,, InstalledDir
    ModuleExe = %InstalledDir%\AcroRd32.exe
}
else
{
    ModuleExe = %A_ProgramFiles%\Adobe\Acrobat 7.0\Reader\AcroRd32.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global bContinue

    Sleep, 500
    ; Get rid of application settings
    FileRemoveDir, %A_AppData%\Adobe\Acrobat, 1
    RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Adobe\Acrobat Reader
    RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Adobe\Repair\Acrobat Reader
    RegDelete, HKEY_CURRENT_USER, SOFTWARE\Adobe\Acrobat Reader

    RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE, SOFTWARE\Adobe\Acrobat Reader\7.0\AdobeViewer, EULA, 1 ; Accept EULA
    IfExist, %ModuleExe%
    {
        if PathToFile =
        {
            Run, %ModuleExe%,, Max ; Start maximized
            Sleep, 1000
            WinWaitActive, Adobe Reader,,15
            if not ErrorLevel
            {
                bContinue := true
            }
            else
            {
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Adobe Reader' failed to appear. Active window caption: '%title%'`n
            }
        }
        else
        {
            Run, %ModuleExe% "%PathToFile%",, Max
            Sleep, 1000
            SplitPath, PathToFile, NameExt
            WinWaitActive, Adobe Reader - [%NameExt%],,15
            if not ErrorLevel
            {
                bContinue := true
            }
            else
            {
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Adobe Reader - [%NameExt%]' failed to appear. Active window caption: '%title%'`n
            }
        }
    }
    else
    {
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
    }
}
