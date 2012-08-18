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

bContinue := false
TestsTotal := 0
TestsSkipped := 0
TestsFailed := 0
TestsOK := 0
TestsExecuted := 0
TestName = prepare

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Universal Viewer Free_is1, UninstallString
if not ErrorLevel
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\Viewer.exe
}
else
{
    ModuleExe = %A_ProgramFiles%\Universal Viewer\Viewer.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}

; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global bContinue

    Sleep, 500
    ; Delete saved settings
    FileRemoveDir, %A_AppData%\SumatraPDF, 1
    FileRemoveDir, %A_AppData%\ATViewer, 1
    FileRemoveDir, %A_AppData%\Adobe, 1

    IfExist, %ModuleExe%
    {
        FileCreateDir, %A_AppData%\ATViewer
        if not ErrorLevel
        {
            FileAppend, [Options]`nSingle=1`n, %A_AppData%\ATViewer\Viewer.ini ; Allow only one instance running
            if not ErrorLevel
            {
                if PathToFile =
                {
                    Run, %ModuleExe%,, Max ; Start maximized
                    Sleep, 1000
                    WinWaitActive, Universal Viewer, File not loaded,15
                    if not ErrorLevel
                    {
                        bContinue := true
                        Sleep, 1000
                    }
                    else
                    {
                        WinGetTitle, title, A
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Universal Viewer (File not loaded)' failed to appear. Active window caption: '%title%'`n
                    }
                }
                else
                {
                    IfExist, %PathToFile%
                    {
                        Run, %ModuleExe% "%PathToFile%",, Max
                        Sleep, 1000
                        SplitPath, PathToFile, NameExt
                        SetTitleMatchMode, 1 ; A window's title must start with the specified WinTitle to be a match.
                        WinWaitActive, %NameExt% - Universal Viewer,,15
                        if not ErrorLevel
                        {
                            bContinue := true
                            Sleep, 1000
                        }
                        else
                        {
                            WinGetTitle, title, A
                            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window '%NameExt% - Universal Viewer' failed to appear (AHK TitleMachMode=1). Active window caption: '%title%'`n
                        }
                    }
                    else
                    {
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%PathToFile%'.`n
                    }
                }
                SetTitleMatchMode, 3 ;  A window's title must exactly match WinTitle to be a match.
            }
            else
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT create and edit '%A_AppData%\ATViewer\Viewer.ini'.`n
            }
        }
        else
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT create '%A_AppData%\ATViewer'.`n
        }
    }
    else
    {
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
    }
}