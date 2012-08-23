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

bContinue := false
TestsTotal := 0
TestsSkipped := 0
TestsFailed := 0
TestsOK := 0
TestsExecuted := 0
TestName = prepare

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Totalcmd, UninstallString
if not ErrorLevel
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\TOTALCMD.EXE
}
else
{
    ModuleExe = C:\totalcmd\TOTALCMD.EXE
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}

RunApplication()
{
    global ModuleExe
    global TestName
    global bContinue

    IfExist, %ModuleExe%
    {
        Process, Close, TOTALCMD.EXE ; Teminate process
        Sleep, 2500 ; To make sure folders are not locked
        FileRemoveDir, %A_AppData%\GHISLER, 1 ; Delete all saved settings
        Sleep, 1500
        IfNotExist, %A_AppData%\GHISLER
        {
            Run, %ModuleExe%,, Max ; Start maximized
            WinWaitActive, Total Commander, Program &information, 10
            if not ErrorLevel
            {
                ControlGetText, BtnNumber, TPanel2, Total Commander, Program &information
                if not ErrorLevel
                {
                    Sleep, 1000
                    SendInput, %BtnNumber% ; Click button to start program
                    WinWaitActive, Configuration, Layout, 5
                    if not ErrorLevel
                    {
                        Sleep, 1000
                        ControlClick, TButton30, Configuration, Layout ; Hit 'OK' button
                        if not ErrorLevel
                        {
                            WinWaitActive, Total Commander 8.0 - NOT REGISTERED,,5
                            if not ErrorLevel
                            {
                                bContinue := true
                                Sleep, 1000
                            }
                            else
                            {
                                WinGetTitle, title, A
                                OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Total Commander 8.0 - NOT REGISTERED' window failed to appear. Active window caption: '%title%'.`n
                            }
                        }
                        else
                        {
                            WinGetTitle, title, A
                            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'OK' button in 'Configuration (Layout)' window. Active window caption: '%title%'.`n
                        }
                    }
                    else
                    {
                        WinGetTitle, title, A
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Configuration (Layout)' window failed to appear. Active window caption: '%title%'.`n
                    }
                }
                else
                {
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to get button number needed to hit in 'Total Commander (Program information)' window. Active window caption: '%title%'.`n
                }
            }
            else
            {
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Total Commander (Program information)' window failed to appear. Active window caption: '%title%'.`n
            }
        }
        else
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Seems like we failed to delete '%A_AppData%\GHISLER'.`n
        }
    }
    else
    {
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
    }
}
