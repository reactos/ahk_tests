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

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Filzip 3.0.6.93_is1, UninstallString
if ErrorLevel
{
    ModuleExe = %A_ProgramFiles%\Filzip\Filzip.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}
else
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; The Filzip uninstaller path is quoted, remove quotes
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\Filzip.exe
}


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global bContinue
    global TestsTotal
    global ProcessExe

    TestsTotal++
    SplitPath, ModuleExe, ProcessExe
    Process, Close, %ProcessExe%
    Process, WaitClose, %ProcessExe%, 4
    if ErrorLevel
        TestsFailed("Process '" ProcessExe "' failed to close.")
    else
    {
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\Filzip
        Sleep, 500
        ; Disable auto update. We do not wan't any unexpected popups coming out.
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Filzip\Config\AutoUpd, AutoUpd, 0
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Filzip\Config\Settings, RegDialog, 0 ; Disable registration dialog
        
        IfNotExist, %ModuleExe%
            TestsFailed("Can NOT find '" ModuleExe "'.")
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
                        TestsFailed("Window 'Filzip' failed to appear. No '" ProcessExe "' process detected.")
                    else
                        TestsFailed("Window 'Filzip' failed to appear. '" ProcessExe "' process detected.")
                }
                else
                    TestsOK("")
            }
            else
            {
                IfNotExist, %PathToFile%
                    TestsFailed("Can NOT find '" PathToFile "'.")
                else
                {
                    Run, %ModuleExe% "%PathToFile%",, Max
                    Sleep, 1000
                    AssociateWithFilzip()
                    SplitPath, PathToFile, NameExt
                    WinWaitActive, Filzip - %NameExt%,,7
                    if ErrorLevel
                    {
                        Process, Exist, %ProcessExe%
                        NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                        if NewPID = 0
                            TestsFailed("Window 'Filzip - " NameExt "' failed to appear. No '" ProcessExe "' process detected.")
                        else
                            TestsFailed("Window 'Filzip - " NameExt "' failed to appear. '" ProcessExe "' process detected.")
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
        TestsFailed("Window 'Associate with Filzip (Never ask again)' failed to appear.")
    else
    {
        ControlClick, TButton2, Associate with Filzip ; Hit 'Associate' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Associate' button in 'Associate with Filzip (Never ask again)' window.")
        else
        {
            WinWaitClose, Associate with Filzip, Never ask again, 5
            if ErrorLevel
                TestsFailed("'Associate with Filzip (Never ask again)' window failed to close despite 'Associate' button being clicked.")
            else
                TestsOK("")
        }
    }
}
