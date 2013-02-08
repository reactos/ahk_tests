/*
 * Designed for Media Player Classic - Home Cinema 1.6.3.5626
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
RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{2624B969-7135-4EB1-B0F6-2D8C397B45F7}_is1, UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    UninstallerPath := ExeFilePathNoParam(UninstallerPath) ; remove quotes and params
    SplitPath, UninstallerPath,, InstalledDir
    if (InstalledDir = "")
        TestsFailed("Either registry contains empty string or we failed to read it.")
    else
    {
        ModuleExe = %InstalledDir%\mpc-hc.exe
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
    RegDelete, HKEY_CURRENT_USER, SOFTWARE\Gabest
    IfExist, %A_AppData%\Media Player Classic
    {
        FileRemoveDir, %A_AppData%\Media Player Classic, 1
        if ErrorLevel
            TestsFailed("Unable to delete '" A_AppData "\Media Player Classic'.")
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
            if PathToFile =
            {
                Run, %ModuleExe%,, Max ; Start maximized
                CloseUpdateWnd()
                if bContinue
                {
                    WinWaitActive, Media Player Classic Home Cinema,,3
                    if ErrorLevel
                        TestsFailed("RunApplication(): Window 'Media Player Classic Home Cinema' failed to appear.")
                    else
                        TestsOK("")
                }
            }
            else
            {
                IfNotExist, %PathToFile%
                    TestsFailed("RunApplication(): Can NOT find '" PathToFile "'.")
                else
                {
                    Run, %ModuleExe% "%PathToFile%",, Max
                    CloseUpdateWnd()
                    if bContinue
                    {
                        SplitPath, PathToFile, NameExt
                        WinWaitActive, %NameExt%,,3
                        if ErrorLevel
                        {
                            Process, Exist, %ProcessExe%
                            NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                            if NewPID = 0
                                TestsFailed("RunApplication(): Window '" NameExt "' failed to appear. No '" ProcessExe "' process detected.")
                            else
                                TestsFailed("RunApplication(): Window '" NameExt "' failed to appear. '" ProcessExe "' process detected.")
                        }
                        else
                            TestsOK("")
                    }
                }
            }
        }
    }
}


CloseUpdateWnd() ; Waits for update window to appear, then hits 'No' button
{
    global ModuleExe
    global TestName
    global TestsTotal
    global bContinue
    global ProcessExe

    TestsTotal++
    WinWaitActive, Media Player Classic, Do you want to check periodically, 5
    if ErrorLevel
    {
        Process, Exist, %ProcessExe%
        NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
        if NewPID = 0
            TestsFailed("CloseUpdateWnd(): Window 'Media Player Classic (Do you want to check periodically)' failed to appear. No '" ProcessExe "' process detected.")
        else
            TestsFailed("CloseUpdateWnd(): Window 'Media Player Classic (Do you want to check periodically)' failed to appear. '" ProcessExe "' process detected. Unable to delete HKCU\Software\Gabest?.")
    }
    else
    {
        ControlClick, Button2 ; Hit 'No' button
        if ErrorLevel
            TestsFailed("CloseUpdateWnd(): Unable to hit 'No' button in 'Media Player Classic (Do you want to check periodically)' window.")
        else
        {
            WinWaitClose,,,3
            if ErrorLevel
                TestsFailed("CloseUpdateWnd(): 'Media Player Classic (Do you want to check periodically)' window failed to close despite 'No' button being reported as clicked.")
            else
                TestsOK("CloseUpdateWnd(): Said NO to updates.")
        }
    }
}
