/*
 * Designed for Total Commander 8.0
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
RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Totalcmd, UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    SplitPath, UninstallerPath,, InstalledDir
    if (InstalledDir = "")
        TestsFailed("Either registry contains empty string or we failed to read it.")
    else
    {
        ModuleExe = %InstalledDir%\TOTALCMD.exe
        TestsOK("")
    }
}


; Terminate application
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


; Delete settings separately from RunApplication() in case we want to write our own settings
TestsTotal++
if bContinue
{
    IfExist, %A_AppData%\GHISLER
    {
        FileRemoveDir, %A_AppData%\GHISLER, 1
        if ErrorLevel
            TestsFailed("Unable to delete '" A_AppData "\GHISLER'.")
        else
            TestsOK("")
    }
    else
        TestsOK("")
}


RunApplication()
{
    global ModuleExe
    global TestName
    global bContinue
    global TestsTotal
    
    TestsTotal++
    if bContinue
    {
        IfNotExist, %ModuleExe%
            TestsFailed("RunApplication(): Can NOT find 'ModuleExe'.")
        else
        {
            Run, %ModuleExe%,, Max ; Start maximized
            WinWaitActive, Total Commander, Program &information, 10
            if ErrorLevel
                TestsFailed("RunApplication(): 'Total Commander (Program information)' window failed to appear.")
            else
            {
                ControlGetText, BtnNumber, TPanel2, Total Commander, Program &information
                if ErrorLevel
                    TestsFailed("RunApplication(): Unable to get button number needed to hit in 'Total Commander (Program information)' window.")
                else
                {
                    SendInput, %BtnNumber% ; Click button to start program
                    WinWaitActive, Configuration, Layout, 5
                    if ErrorLevel
                        TestsFailed("RunApplication(): 'Configuration (Layout)' window failed to appear.")
                    else
                    {
                        ControlClick, TButton30, Configuration, Layout ; Hit 'OK' button
                        if ErrorLevel
                            TestsFailed("RunApplication(): Unable to hit 'OK' button in 'Configuration (Layout)' window.")
                        else
                        {
                            WinWaitActive, Total Commander 8.0 - NOT REGISTERED,,5
                            if ErrorLevel
                                TestsFailed("RunApplication(): 'Total Commander 8.0 - NOT REGISTERED' window failed to appear.")
                            else
                                TestsOK("")
                        }
                    }
                }
            }
        }
    }
}
