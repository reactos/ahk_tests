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

TestName = prepare

; Disable some windows, configure, start mirc, connect to irc.freenode.net, #ReactOS_Test channel

Process, Close, mirc.exe
Sleep, 1500

RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\mIRC, InstallLocation
if ErrorLevel
{
    ModuleExe = %A_ProgramFiles%\mIRC\mirc.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}
else
    ModuleExe = %InstallLocation%\mirc.exe


; Terminate application
TestsTotal++
SplitPath, ModuleExe, ProcessExe
Process, Close, %ProcessExe%
Process, WaitClose, %ProcessExe%, 4
if ErrorLevel
    TestsFailed("Process '" ProcessExe "' failed to close.")
else
    TestsOK("")


; Delete settings separately from RunApplication()
TestsTotal++
IfExist, %A_AppData%\mIRC
    FileRemoveDir, %A_AppData%\mIRC, 1 ; Delete saved settings
IfExist, %A_AppData%\mIRC
    TestsFailed("Unable to delete '" A_AppData "\mIRC'.")
else
{
    FileCreateDir, %A_AppData%\mIRC
    if ErrorLevel
        TestsFailed("Unable to create '" A_AppData "\mIRC'.")
    else
    {
        szNoUpdate := "[Update]`nCheck=0`n" ; Disable update check
        szUserInfo := "[mirc]`nuser=Edijs Kole`nemail=fake_email@yahoo.com`nnick=mIRC_Test`nanick=ROS_mIRC`n" ; Enter user information
        szServerAndChan := "host=FreenodeSERVER:irc.freenode.net:6667`n[chanfolder]`nn0=#ReactOS-testers`,`,`,`,1`n"
        szNoConError := "[wizard]`nwarning=2`n" ; Disable connection error window
        szNoFavourites1 := "[options]`nn1=5`,100`,1`,1`,0`,2`,6`,2`,0`,1`,0`,1`,1`,1`,1`,1`,1`,1`,0`,0`,1`,1`,1`,0`,5`,0`,1`,0`,0`,0`,1`,0`,0`,0`,1`,10`n"
        szNoFavourites2 := "n4=1`,1`,1`,0`,0`,3`,9999`,0`,0`,1`,1`,0`,1024`,1`,1`,99`,60`,0`,0`,0`,1`,1`,1`,0`,0`,5000`,1`,5`,0`,0`,3`,0`,1`,1`,0`,0`,1`n"
        FileAppend, %szNoUpdate%%szUserInfo%%szServerAndChan%%szNoConError%%szNoFavourites1%%szNoFavourites2%, %A_AppData%\mIRC\mirc.ini
        if ErrorLevel
            TestsFailed("Can NOT create and edit '" A_AppData "\mIRC\mirc.ini'.")
        else
            TestsOK("")
    }
}


TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("Can NOT find '" ModuleExe "'.")
else
{
    Run, %ModuleExe%,, Max
    WinWaitActive, About mIRC,,10
    if ErrorLevel
        TestsFailed("Window 'About mIRC' failed to appear.")
    else
    {
        Sleep, 1000
        ControlClick, Button3, About mIRC ; Click 'Continue' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Continue' button in 'About mIRC' window.")
        else
        {
            WinWaitActive, mIRC Options, Category, 7
            if ErrorLevel
                TestsFailed("Window 'mIRC Options (Category)' failed to appear.")
            else
            {
                Sleep, 2000
                ControlClick, Button6, mIRC Options, Category ; Hit 'Connect'
                if ErrorLevel
                    TestsFailed("Unable to hit 'Connect' in 'mIRC Options (Category)' window.")
                else
                {
                    WinWaitactive, mIRC,,20
                    if ErrorLevel
                        TestsFailed("'mIRC' is not active window.")
                    else
                        TestsOK("")
                }
            }
        }
    }
}