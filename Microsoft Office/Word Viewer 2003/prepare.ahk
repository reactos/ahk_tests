/*
 * Designed for Word Viewer 2003
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
ModuleExe = %A_ProgramFiles%\Microsoft Office\OFFICE11\WORDVIEW.exe ; registry contains empty string anyway
bContinue := true


; Terminate application
if bContinue
{
    SplitPath, ModuleExe, ProcessExe
    bTerminateProcess(ProcessExe)
}


; Delete settings separately from RunApplication() in case we want to write our own settings
TestsTotal++
if bContinue
{
    RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Office
    IfExist, %A_AppData%\Microsoft\Office
    {
        FileRemoveDir, %A_AppData%\Microsoft\Office, 1
        if ErrorLevel
            TestsFailed("Unable to delete '" A_AppData "\Microsoft\Office'.")
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
                WinWait, Microsoft Word Viewer,,3
                if ErrorLevel
                    TestsFailed("'Microsoft Word Viewer' window does NOT exist.")
                else
                {
                    WinWaitActive, Open,,3
                    if ErrorLevel
                    {
                        Process, Exist, %ProcessExe%
                        NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                        if NewPID = 0
                            TestsFailed("RunApplication(): Window 'Open' failed to appear. No '" ProcessExe "' process detected.")
                        else
                            TestsFailed("RunApplication(): Window 'Open' failed to appear. '" ProcessExe "' process detected.")
                    }
                    else
                        TestsOK("There is 'Microsoft Word Viewer' window in a background and 'Open' is active one.")
                }
            }
            else
            {
                IfNotExist, %PathToFile%
                    TestsFailed("RunApplication(): Can NOT find '" PathToFile "'.")
                else
                {
                    Run, %ModuleExe% "%PathToFile%",, Max
                    RegRead, bHideExt, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt
                    if ErrorLevel
                        TestsFailed("Unable to read 'HideFileExt' in 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'.")
                    else
                    {
                        if bHideExt
                            SplitPath, PathToFile,,,, name_no_ext
                        else
                            SplitPath, PathToFile, NameExt
                        szWndCaption = %name_no_ext%%NameExt% - Microsoft Word Viewer
                        WinWaitActive, %szWndCaption%,,3
                        if ErrorLevel
                        {
                            Process, Exist, %ProcessExe%
                            NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                            if NewPID = 0
                                TestsFailed("RunApplication(): Window '" szWndCaption "' failed to appear. No '" ProcessExe "' process detected.")
                            else
                                TestsFailed("RunApplication(): Window '" szWndCaption "' failed to appear. '" ProcessExe "' process detected.")
                        }
                        else
                            TestsOK("Seems like succeeded opening '" PathToFile "', because active window caption is '" szWndCaption "'.")
                    }
                }
            }
        }
    }
}
