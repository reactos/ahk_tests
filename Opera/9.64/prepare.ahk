/*
 * Designed for Opera v9.64
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

RegRead, InstalledPathReg, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{E1BBBAC5-2857-4155-82A6-54492CE88620}, InstallLocation
if ErrorLevel
{
    ModuleExe = %A_ProgramFiles%\Opera\Opera.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}
else
    ModuleExe = %InstalledPathReg%Opera.exe ; InstalledPathReg already contains backslash


; Terminate application
TestsTotal++
SplitPath, ModuleExe, ProcessExe
Process, Close, %ProcessExe%
Process, WaitClose, %ProcessExe%, 4
if ErrorLevel
    TestsFailed("Process '" ProcessExe "' failed to close.")
else
    TestsOK("")


; Delete settings separately
TestsTotal++
if bContinue
{
    IfExist, %A_AppData%\Opera
    {
        FileRemoveDir, %A_AppData%\Opera, 1
        if ErrorLevel
            TestsFailed("Unable to delete '" A_AppData "\Opera'.")
        else
            TestsOK("")
    }
    else
        TestsOK("")
}


TestsTotal++
if bContinue
{
    IfNotExist, %ModuleExe%
        TestsFailed("Can NOT find '" ModuleExe "'.")
    else
    {
        Run, %ModuleExe% ; Setup/install registers Opera as default browser
        WinWaitActive, Welcome to Opera - Opera,, 20 ; Window caption might change?
        if ErrorLevel
            TestsFailed("Window 'Welcome to Opera - Opera' was NOT found.")
        else
        {
            Sleep, 1000
            TestsOK("") 
        }
    }
}
