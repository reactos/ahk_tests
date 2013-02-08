/*
 * Designed for Abyss Web Server X1 2.7
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
RegRead, UninstallerPath, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AbyssWebServer, UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    UninstallerPath := ExeFilePathNoParam(UninstallerPath)
    SplitPath, UninstallerPath,, InstalledDir
    if (InstalledDir = "")
        TestsFailed("Either registry contains empty string or we failed to read it.")
    else
    {
        ModuleExe = %InstalledDir%\abyssws.exe
        TestsOK("")
    }
}


TerminateAbyss() ; Call the function


TerminateAbyss() ; Terminate application function
{
    global ModuleExe
    global TestName
    global TestsTotal
    global bContinue
    global ProcessExe

    TestsTotal++
    if bContinue
    {
        SplitPath, ModuleExe, ProcessExe
        ; There is 2 processes running
        Process, Close, %ProcessExe%
        Sleep, 250 ; A small delay is required before trying to terminate second process
        Process, Close, %ProcessExe%
        Process, WaitClose, %ProcessExe%, 4
        if ErrorLevel
            TestsFailed("TerminateAbyss(): Unable to terminate '" ProcessExe "' process.")
        else
            TestsOK("")
    }
}


; Delete settings separately from RunApplication() in case we want to write our own settings
TestsTotal++
if bContinue
{
    IfExist, %InstalledDir%\abyss.conf
    {
        FileDelete, %InstalledDir%\abyss.conf
        if ErrorLevel
            TestsFailed("Unable to delete '" InstalledDir "\abyss.conf'.")
        else
            TestsOK("")
    }
    else
        TestsOK("")
}


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global TestsTotal
    global bContinue
    global ProcessExe

    TestsTotal++
    if bContinue
    {
        IfNotExist, %ModuleExe%
            TestsFailed("RunApplication(): Can NOT find '" ModuleExe "'.")
        else
        {
            Run, %ModuleExe%
            WinWaitActive, Abyss Web Server, A configuration file was created, 5
            if ErrorLevel
            {
                Process, Exist, %ProcessExe%
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("RunApplication(): Window 'Abyss Web Server (A configuration file was created)' failed to appear. No '" ProcessExe "' process detected.")
                else
                    TestsFailed("RunApplication(): Window 'Abyss Web Server (A configuration file was created)' failed to appear. '" ProcessExe "' process detected.")
            }
            else
                TestsOK("")
        } 
    }
}
