/*
 * Designed for UniversalViewer 5.7.2.0
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
RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Universal Viewer Free_is1, UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; Universal Viewer string contains quotes, replace em
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\Viewer.exe
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
    FileRemoveDir, %A_AppData%\SumatraPDF, 1
    FileRemoveDir, %A_AppData%\Adobe, 1
    IfExist, %A_AppData%\ATViewer
    {
        FileRemoveDir, %A_AppData%\ATViewer, 1
        if ErrorLevel
            TestsFailed("Unable to delete '" A_AppData "\ATViewer'.")
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
        FileCreateDir, %A_AppData%\ATViewer
        if ErrorLevel
            TestsFailed("Can NOT create '" A_AppData "\ATViewer'.")
        else
        {
            FileAppend, [Options]`nSingle=1`n, %A_AppData%\ATViewer\Viewer.ini ; Allow only one instance running
            if ErrorLevel
                TestsFailed("Can NOT create and edit '" A_AppData "\ATViewer\Viewer.ini'.")
            else
            {
                if PathToFile =
                {
                    Run, %ModuleExe%,, Max ; Start maximized
                    WinWaitActive, Universal Viewer, File not loaded, 10
                    if ErrorLevel
                        TestsFailed("Window 'Universal Viewer (File not loaded)' failed to appear.")
                    else
                    {
                        Sleep, 500 ; Sleep is a must
                        TestsOK("")
                    }
                }
                else
                {
                    IfNotExist, %PathToFile%
                        TestsFailed("Can NOT find '" PathToFile "'.")
                    else
                    {
                        Run, %ModuleExe% "%PathToFile%",, Max
                        SplitPath, PathToFile, NameExt
                        SetTitleMatchMode, 1 ; A window's title must start with the specified WinTitle to be a match.
                        WinWaitActive, %NameExt% - Universal Viewer,, 10
                        if ErrorLevel
                            TestsFailed("Window '" NameExt " - Universal Viewer' failed to appear (AHK TitleMachMode=1).")
                        else
                        {
                            Sleep, 500 ; Sleep is a must
                            TestsOK("")
                        }
                    }
                }
                SetTitleMatchMode, 3 ;  A window's title must exactly match WinTitle to be a match.
            }
        }
    }
}