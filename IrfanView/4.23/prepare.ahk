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

TestName = prepare

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\IrfanView, UninstallString
if ErrorLevel
{
    ModuleExe = %A_ProgramFiles%\IrfanView\i_view32.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}
else
{
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\i_view32.exe
}


; Terminate application
TestsTotal++
SplitPath, ModuleExe, ProcessExe
Process, Close, %ProcessExe%
Process, WaitClose, %ProcessExe%, 4
if ErrorLevel
    TestsFailed("Unable to terminate '" ProcessExe "' process.")
else
    TestsOK("")


; Delete settings separately from RunApplication() in case we want to write our own settings
TestsTotal++
IfExist, %A_AppData%\IrfanView
{
    FileRemoveDir, %A_AppData%\IrfanView, 1
    if ErrorLevel
        TestsFailed("Unable to delete '" A_AppData "\IrfanView'.")
    else
        TestsOK("")
}
else
    TestsOK("")


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global TestsTotal
    global ProcessExe

    TestsTotal++
    IfNotExist, %ModuleExe%
        TestsFailed("Can NOT find '" ModuleExe "'.")
    else
    {
        if PathToFile =
        {
            Run, %ModuleExe%,, Max ; Start maximized
            WinWaitActive, IrfanView,,7
            if ErrorLevel
            {
                Process, Exist, %ProcessExe%
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("Window 'IrfanView' failed to appear. No '" ProcessExe "' process detected.")
                else
                    TestsFailed("Window 'IrfanView' failed to appear. '" ProcessExe "' process detected.")
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
                WinWaitActive, %NameExt% - IrfanView,,7
                if ErrorLevel
                {
                    Process, Exist, %ProcessExe%
                    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                    if NewPID = 0
                        TestsFailed("Window '" NameExt " - IrfanView' failed to appear. No '" ProcessExe "' process detected.")
                    else
                        TestsFailed("Window '" NameExt " - IrfanView' failed to appear. '" ProcessExe "' process detected.")
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
