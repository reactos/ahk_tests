/*
 * Designed for Miranda IM 0.10.0
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
RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Miranda IM, UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\miranda32.exe
    TestsOK("")
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
    IfExist, %A_AppData%\Miranda
    {
        FileRemoveDir, %A_AppData%\Miranda, 1
        if ErrorLevel
            TestsFailed("Unable to delete '" A_AppData "\Miranda'.")
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

    TestsTotal++
    if bContinue
    {
        IfNotExist, %ModuleExe%
            TestsFailed("Can NOT find '" ModuleExe "'.")
        else
        {
            Run, %ModuleExe%
            WinWaitActive, Miranda IM Profile Manager, Please complete, 7
            if ErrorLevel
            {
                Process, Exist, %ProcessExe%
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("Window 'Miranda IM Profile Manager (Please complete)' failed to appear. No '" ProcessExe "' process detected.")
                else
                    TestsFailed("Window 'Miranda IM Profile Manager (Please complete)' failed to appear. '" ProcessExe "' process detected.")
            }
            else
            {
                SendInput, TestProfile ; 'Profile' field is focused by default
                ControlGetText, ProfileName, Edit1, Miranda IM Profile Manager, Please complete
                if ErrorLevel
                    TestsFailed("Unable to get profile name in 'Miranda IM Profile Manager (Please complete)' window.")
                else
                {
                    if (ProfileName != "TestProfile")
                        TestsFailed("Profile name is not the same as expected (is '" ProfileName "', should be 'TestProfile').")
                    else
                    {
                        SendInput, !c ; Alt+C aka hit 'Create' button
                        WinWaitClose,,,3
                        if ErrorLevel
                            TestsFailed("'Miranda IM Profile Manager (Please complete)' window failed to close despite Alt+C was sent.")
                        else
                        {
                            WinWaitActive, Accounts, Configure, 3
                            if ErrorLevel
                                TestsFailed("'Accounts (Configure)' window failed to appear.")
                            else
                            {
                                SendInput, !a ; Alt+A aka hit '+' (Add) button
                                WinWaitActive, Create new account, Enter, 3
                                if ErrorLevel
                                    TestsFailed("'Create new account (Enter)' window failed to appear despite Alt+A was sent.")
                                else
                                {
                                    TestsOK("'Create new account (Enter)' window is an active window.")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
