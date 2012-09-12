/*
 * Designed for VLC Media Player 2.0.3
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

TestsName = prepare

; Test if the app is installed
TestsTotal++
RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\VLC media player, UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\vlc.exe
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
    IfExist, %A_AppData%\vlc
    {
        FileRemoveDir, %A_AppData%\vlc, 1
        if ErrorLevel
            TestsFailed("Unable to delete '" A_AppData "\vlc'.")
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
    global bContinue
    global TestsTotal
    
    TestsTotal++
    IfNotExist, %ModuleExe%
        TestsFailed("Can NOT find '" ModuleExe "'.")
    else
    {
        FileCreateDir, %A_AppData%\vlc
        if ErrorLevel
            TestsFailed("Failed to create '%A_AppData%\vlc'.")
        else
        {
            FileAppend, [General]`nIsFirstRun=0`n, %A_AppData%\vlc\vlc-qt-interface.ini ; Overcome 'Privacy and Network Access Policy' dialog
            if ErrorLevel
                TestsFailed("Failed to create and edit '%A_AppData%\vlc\vlc-qt-interface.ini'.")
            else
            {
                if PathToFile =
                {
                    Run, %ModuleExe% ; Don't run it maximized
                    Sleep, 1000
                    WinWaitActive, VLC media player,,7
                    if ErrorLevel
                    {
                        Process, Exist, %ProcessExe%
                        NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                        if NewPID = 0
                            TestsFailed("Window 'VLC media player' failed to appear. No '" ProcessExe "' process detected.")
                        else
                            TestsFailed("Window 'VLC media player' failed to appear. '" ProcessExe "' process detected.")
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
                        Run, %ModuleExe% "%PathToFile%" ; Don't run it maximized
                        Sleep, 1000
                        SplitPath, PathToFile, NameExt
                        WinWaitActive, %NameExt% - VLC media player,,7
                        if ErrorLevel
                        {
                            Process, Exist, %ProcessExe%
                            NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                            if NewPID = 0
                                TestsFailed("Window '" NameExt " - VLC media player' failed to appear when opening '" PathToFile "'. No '" ProcessExe "' process detected.")
                            else
                                TestsFailed("Window '" NameExt " - VLC media player' failed to appear when opening '" PathToFile "'. '" ProcessExe "' process detected.")
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
    }
}
