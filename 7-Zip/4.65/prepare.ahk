/*
 * Designed for 7-Zip 4.65
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

; Test if the app is installed
TestsTotal++
RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip, UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; 9.20 haves quoted path
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\7zFM.exe
    TestsOK("")
}


TerminateApplication() ; execute the function


; Delete settings
RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\7-Zip
RegDelete, HKEY_CURRENT_USER, SOFTWARE\7-Zip


; Function to test if can terminate application
TerminateApplication()
{
    global TestsTotal
    global ModuleExe
    global bContinue

    TestsTotal++
    if bContinue
    {
        SplitPath, ModuleExe, ProcessExe
        Process, Close, %ProcessExe%
        Process, WaitClose, %ProcessExe%, 4
        if ErrorLevel
            TestsFailed("Unable to terminate '" ProcessExe "' process.")
        else
            TestsOK("")
    }
}


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global ProcessExe
    global TestName
    global bContinue
    global TestsTotal

    TestsTotal++
    IfNotExist, %ModuleExe%
        TestsFailed("Can NOT find '" ModuleExe "'.")
    else
    {
        if PathToFile =
        {
            Run, %ModuleExe%,, Max ; Start maximized
            WinWaitActive, 7-Zip File Manager,,7
            if ErrorLevel
            {
                Process, Exist, %ProcessExe%
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("Window '7-Zip File Manager' failed to appear. No '" ProcessExe "' process detected.")
                else
                    TestsFailed("Window '7-Zip File Manager' failed to appear. '" ProcessExe "' process detected.")
            }
            else
                TestsOK("")
        }
        else
        {
            Run, %ModuleExe% "%PathToFile%",, Max
            WinWaitActive, %PathToFile%\,,7
            if ErrorLevel
            {
                Process, Exist, %ProcessExe%
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("Window '" PathToFile "\' failed to appear. No '" ProcessExe "' process detected.")
                else
                    TestsFailed("Window '" PathToFile "\' failed to appear. '" ProcessExe "' process detected.")
            }
            else
                TestsOK("")
        }
    }
}
