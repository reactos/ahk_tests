/*
 * Designed for RosBE 2.0
 * Copyright (C) 2013 Edijs Kolesnikovics
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
RegRead, UninstallerPath, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ReactOS Build Environment for Windows, UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    SplitPath, UninstallerPath,, InstalledDir
    if (InstalledDir = "")
        TestsFailed("Either registry contains empty string or we failed to read it.")
    else
    {
        ModuleExe = %InstalledDir%\RosBE.cmd
        TestsOK("")
    }
}


; Terminate application
TestsTotal++
if bContinue
{
    WinClose, ReactOS Build Environment 2.0
    WinWaitClose, ReactOS Build Environment 2.0,,3
    if ErrorLevel
        TestsFailed("Unable to close 'ReactOS Build Environment 2.0' window.")
    else
        TestsOK("")
}


; Delete settings separately from RunApplication() in case we want to write our own settings
TestsTotal++
if bContinue
{
    IfExist, %A_AppData%\RosBE
    {
        FileRemoveDir, %A_AppData%\RosBE, 1
        if ErrorLevel
            TestsFailed("Unable to delete '" A_AppData "\RosBE'.")
        else
            TestsOK("")
    }
    else
        TestsOK("")
}


; Test if can start application
RunApplication()
{
    global ModuleExe
    global TestName
    global TestsTotal
    global bContinue
    global ProcessExe
    global RosBE_PID

    TestsTotal++
    if bContinue
    {
        IfNotExist, %ModuleExe%
            TestsFailed("RunApplication(): Can NOT find '" ModuleExe "'.")
        else
        {
            Run, cmd.exe /t:0A /k "%ModuleExe%",,, RosBE_PID
            WinWaitActive, ReactOS Build Environment 2.0,,3
            if ErrorLevel
            {
                Process, Exist, %RosBE_PID%
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("RunApplication(): Window 'ReactOS Build Environment 2.0' failed to appear. No 'cmd.exe PID " RosBE_PID "' process detected.")
                else
                    TestsFailed("RunApplication(): Window 'ReactOS Build Environment 2.0' failed to appear. 'cmd.exe PID " RosBE_PID "' process detected.")
            }
            else
                TestsOK("")
        }
    }
    else
        TestsInfo("not bcontinue")
}
