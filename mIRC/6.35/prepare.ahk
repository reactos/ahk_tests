/*
 * Designed for mIRC 6.35
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

; Disable some windows, configure, start mirc, connect to irc.freenode.net, #ReactOS_Test channel

Process, Close, mirc.exe
Sleep, 1500

RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\mIRC, InstallLocation
if not ErrorLevel
{
    StringReplace, InstallLocation, InstallLocation, `",, All ; String contains quotes, replace em
    ModuleExe = %InstallLocation%\mirc.exe
}
else
{
    ModuleExe = %A_ProgramFiles%\mIRC\mirc.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}

IfExist, %ModuleExe%
{
    FileRemoveDir, %A_AppData%\mIRC, 1 ; Delete saved settings
    FileCreateDir, %A_AppData%\mIRC
    szNoUpdate := "[Update]`nCheck=0`n" ; Disable update check
    szUserInfo := "[mirc]`nuser=Edijs Kole`nemail=fake_email@yahoo.com`nnick=mIRC_Test`nanick=ROS_mIRC`n" ; Enter user information
    szServerAndChan := "host=FreenodeSERVER:irc.freenode.net:6667`n[chanfolder]`nn0=#ReactOS-testers`,`,`,`,1`n"
    szNoConError := "[wizard]`nwarning=2`n" ; Disable connection error window
    szNoFavourites1 := "[options]`nn1=5`,100`,1`,1`,0`,2`,6`,2`,0`,1`,0`,1`,1`,1`,1`,1`,1`,1`,0`,0`,1`,1`,1`,0`,5`,0`,1`,0`,0`,0`,1`,0`,0`,0`,1`,10`n"
    szNoFavourites2 := "n4=1`,1`,1`,0`,0`,3`,9999`,0`,0`,1`,1`,0`,1024`,1`,1`,99`,60`,0`,0`,0`,1`,1`,1`,0`,0`,5000`,1`,5`,0`,0`,3`,0`,1`,1`,0`,0`,1`n"
    FileAppend, %szNoUpdate%%szUserInfo%%szServerAndChan%%szNoConError%%szNoFavourites1%%szNoFavourites2%, %A_AppData%\mIRC\mirc.ini
    if not ErrorLevel
    {
        Run, %ModuleExe%,, Max
        WinWaitActive, About mIRC,,10
        if not ErrorLevel
        {
            Sleep, 1000
            ControlClick, Button3, About mIRC ; Click 'Continue' button
            if not ErrorLevel
            {
                WinWaitActive, mIRC Options, Category, 7
                if not ErrorLevel
                {
                    Sleep, 2000
                    ControlClick, Button6, mIRC Options, Category ; Hit 'Connect'
                    if not ErrorLevel
                    {
                        WinWaitactive, mIRC,,20
                        if not ErrorLevel
                        {
                            bContinue := true
                        }
                        else
                        {
                            WinGetTitle, title, A
                            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC' is not active window. Active window caption: '%title%'`n
                        }
                    }
                    else
                    {
                        WinGetTitle, title, A
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Connect' in 'mIRC Options (Category)' window. Active window caption: '%title%'`n
                    }
                }
                else
                {
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'mIRC Options (Category)' failed to appear. Active window caption: '%title%'`n
                }
            }
            else
            {
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Continue' button in 'About mIRC' window. Active window caption: '%title%'`n
            }
        }
        else
        {
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'About mIRC' failed to appear. Active window caption: '%title%'`n
        }
    }
    else
    {
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT create and edit '%A_AppData%\mIRC\mirc.ini'. Active window caption: '%title%'`n
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
}
