/*
 * Designed for Paint
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
ModuleExe = %A_WinDir%\System32\mspaint.exe


; Terminate application
TestsTotal++
SplitPath, ModuleExe, ProcessExe
Process, Close, %ProcessExe%
Process, WaitClose, %ProcessExe%, 4
if ErrorLevel
    TestsFailed("Unable to terminate '" ProcessExe "' process.")
else
    TestsOK("")


RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Applets\Paint ; Delete saved settings


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global bContinue
    global TestsTotal

    TestsTotal++
    if bContinue
    {
        IfNotExist, %ModuleExe%
            TestsFailed("RunApplication(): Can NOT find '" ModuleExe "'.")
        else
        {
            if PathToFile =
            {
                Run, %ModuleExe%,, Max ; Start maximized
                WinWaitActive, untitled - Paint,,7
                if ErrorLevel
                    TestsFailed("RunApplication(): Window 'untitled - paint' failed to appear.")
                else
                    TestsOK("")
            }
            else
            {
                IfNotExist, %PathToFile%
                    TestsFailed("RunApplication(): Can NOT find '" PathToFile "'.")
                else
                {
                    Run, %ModuleExe% "%PathToFile%",, Max
                    SplitPath, PathToFile, NameExt
                    WinWaitActive, %NameExt% - Paint,,7
                    if ErrorLevel
                        TestsFailed("RunApplication(): Window '" NameExt " - Paint' failed to appear.")
                    else
                        TestsOK("")
                }
            }
        }
    }
}
