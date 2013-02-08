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

TestName = prepare

; Test if the app is installed
TestsTotal++
RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Filzip 3.0.6.93_is1, UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; The Filzip uninstaller path is quoted, remove quotes
    SplitPath, UninstallerPath,, InstalledDir
    if (InstalledDir = "")
        TestsFailed("Either registry contains empty string or we failed to read it.")
    else
    {
        ModuleExe = %InstalledDir%\Filzip.exe
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


RegDelete, HKEY_CURRENT_USER, SOFTWARE\Filzip


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global bContinue
    global TestsTotal
    global ProcessExe

    TestsTotal++
    if bContinue
    {
        ; Disable auto update. We do not wan't any unexpected popups coming out.
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Filzip\Config\AutoUpd, AutoUpd, 0
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Filzip\Config\Settings, RegDialog, 0 ; Disable registration dialog
        IfNotExist, %ModuleExe%
            TestsFailed("RunApplication(): Can NOT find '" ModuleExe "'.")
        else
        {
            if PathToFile =
            {
                Run, %ModuleExe%,, Max ; Start maximized
                AssociateWithFilzip()
                WinWaitActive, Filzip,,7
                if ErrorLevel
                {
                    Process, Exist, %ProcessExe%
                    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                    if NewPID = 0
                        TestsFailed("RunApplication(): Window 'Filzip' failed to appear. No '" ProcessExe "' process detected.")
                    else
                        TestsFailed("RunApplication(): Window 'Filzip' failed to appear. '" ProcessExe "' process detected.")
                }
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
                    AssociateWithFilzip()
                    SplitPath, PathToFile, NameExt
                    WinWaitActive, Filzip - %NameExt%,,7
                    if ErrorLevel
                    {
                        Process, Exist, %ProcessExe%
                        NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                        if NewPID = 0
                            TestsFailed("RunApplication(): Window 'Filzip - " NameExt "' failed to appear. No '" ProcessExe "' process detected.")
                        else
                            TestsFailed("RunApplication(): Window 'Filzip - " NameExt "' failed to appear. '" ProcessExe "' process detected.")
                    }
                    else
                        TestsOK("")
                }
            }
        }
    }
}

AssociateWithFilzip()
{
    global TestName
    global TestsTotal
    
    TestsTotal++
    WinWaitActive, Associate with Filzip, Never ask again,7
    if ErrorLevel
        TestsFailed("AssociateWithFilzip(): Window 'Associate with Filzip (Never ask again)' failed to appear.")
    else
    {
        ControlClick, TButton2, Associate with Filzip ; Hit 'Associate' button
        if ErrorLevel
            TestsFailed("AssociateWithFilzip(): Unable to hit 'Associate' button in 'Associate with Filzip (Never ask again)' window.")
        else
        {
            WinWaitClose, Associate with Filzip, Never ask again, 5
            if ErrorLevel
                TestsFailed("AssociateWithFilzip(): 'Associate with Filzip (Never ask again)' window failed to close despite 'Associate' button being clicked.")
            else
                TestsOK("")
        }
    }
}
