/*
 * Designed for SeaMonkey 1.1.17
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

TestName = 2.download
szFileURL = http://iso.reactos.org/livecd/livecd-57139-dbg.7z


; Test if can download file
TestsTotal++
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, Welcome to SeaMonkey - SeaMonkey
        TestsFailed("'Welcome to SeaMonkey - SeaMonkey' is not active window.")
    else
    {
        SendInput, {ALTDOWN}d{ALTUP} ; Go to address bar
        SendInput, %szFileURL%{ENTER} 
        SplitPath, szFileURL, NameExt
        FileDelete, %A_Desktop%\%NameExt%
        WinWaitActive, Opening %NameExt%,, 10
        if ErrorLevel
            TestsFailed("Window 'Opening " NameExt "' failed to appear.")
        else
        {
            SendInput, {ALTDOWN}s{ALTUP} ; Check 'Save it to disk' radio button
            Sleep, 3000 ; wait until 'OK' gets enabled, AHK won't help
            SendInput, {ENTER} ; Hit 'OK' button
            WinWaitActive, Enter name of file to save to...,,5
            if ErrorLevel
                TestsFailed("Window 'Enter name of file to save to...' failed to appear.")
            else
            {
                ControlSetText, Edit1, %A_Desktop%\%NameExt%, Enter name of file to save to... ; Enter file path and name
                if ErrorLevel
                    TestsFailed("Unable to enter path in 'Enter name of file to save to...' window.")
                else
                {
                    ControlClick, Button2, Enter name of file to save to... ; Hit 'Save' button
                    if ErrorLevel
                        TestsFailed("Unable to hit 'Save' button in 'Enter name of file to save to...' window.")
                    else
                    {
                        WinWaitActive, Download Manager,,5
                        if ErrorLevel
                            TestsFailed("Window 'Download Manager' failed to appear.")
                        else
                        {
                            SendInput, {ALTDOWN}i{ALTUP} ; Hit 'Properties' in 'Download Manager'
                            SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
                            WinWaitActive, of %NameExt% Saved,,5
                            if ErrorLevel
                                TestsFailed("Window 'of " NameExt " Saved' failed to appear (SetTitleMatchMode=2).")
                            else
                            {   
                                iTimeOut := 240
                                while iTimeOut > 0
                                {
                                    IfWinActive, `% of %NameExt% Saved
                                    {
                                        WinWaitActive, 100`% of %NameExt% Saved,,1 ; Wait for 100
                                        if ErrorLevel
                                            iTimeOut--
                                        else
                                            break
                                    }
                                    else
                                        break ; exit the loop if something poped-up
                                }
                                
                                WinWaitActive, 100`% of %NameExt% Saved,,1
                                if ErrorLevel
                                    TestsFailed("'100% of " NameExt " Saved' window failed to appear (iTimeOut=" iTimeOut ").")
                                else
                                {
                                    Process, Close, %ProcessExe%
                                    Process, WaitClose, %ProcessExe%, 4
                                    if ErrorLevel
                                        TestsFailed("Unable to terminate '" ProcessExe "' process.")
                                    else
                                        TestsOK("'" szFileURL "' downloaded (iTimeOut=" iTimeOut "), '" ProcessExe "' terminated.")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
