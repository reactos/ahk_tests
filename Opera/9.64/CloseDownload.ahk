/*
 * Designed for Opera 9.64
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

TestName = 5.CloseDownload
szURL = https://svn.reactos.org/storage/sylvain/50MiB.dat
SplitPath, szFileURL, szFileName

; Test if we can exit properly when download in progress. Bug #CORE-5134
TestsTotal++
RunApplication("","")
if bContinue
{
    IfWinNotActive, Speed Dial - Opera
        TestsFailed("Window 'Speed Dial - Opera' is not active window.")
    else
    {
        IfExist, %A_MyDocuments%\%szFileName%
            FileDelete, %A_MyDocuments%\%szFileName%
        SetKeyDelay, 250, 150 ; FIXME: remove this line
        SendInput, {CTRLDOWN}l{CTRLUP} ; Toggle address bar
        SendInput, %szURL% ; Enter address
        clipboard = ; Empty the clipboard
        Send, ^a ; Ctrl+A
        Send, ^c ; Ctrl+C
        ClipWait, 2
        if ErrorLevel
            TestsFailed(" The attempt to copy text onto the clipboard failed.")
        else
        {
            if clipboard <> %szURL%
                TestsFailed("Clipboard and URL contents are not the same (expected '" %szURL% "', got '" clipboard "'). Ctrl+L doesnt work?")
            else
            {
                SendInput, {ENTER} ; go to specified address
                iTimeOut := 45
                while iTimeOut > 0
                {
                    IfWinActive, Blank page - Opera
                    {
                        WinWaitActive, Downloading file %szFileName%,,1
                        iTimeOut--
                    }
                    else
                        break ; exit the loop if something poped-up
                }

                WinWaitActive, Downloading file %szFileName%,, 1
                if ErrorLevel
                    TestsFailed("Window 'Downloading file 50MiB.dat' failed to appear (iTimeOut=" iTimeOut ").")
                else
                {
                    TestsInfo("'Downloading file 50MiB.dat' window appeared (iTimeOut=" iTimeOut ").")
                    SendInput, !n ; Focus 'File name' field
                    SendInput, %A_MyDocuments%\%szFileName%
                    SendInput, {ENTER} ; Hit 'Save'
                    SetTitleMatchMode, 1 ; A window's title must start with the specified WinTitle to be a match.
                    WinWaitActive, Save,, 7
                    if ErrorLevel
                        TestsFailed("'Save as' dialog failed to appear (SetTitleMatchMode=" A_TitleMatchMode ").")
                    else
                    {
                        SendInput, {ALTDOWN}s{ALTUP} ; Hit 'Save' in 'Save as'
                        Sleep, 3500 ; Download for 3.5 sec before closing Opera
                        WinClose, Blank page - Opera,,5
                        WinWaitActive, Active,,7 ; ROS 'Active transfers', WinXP 'Active Transfers'
                        if ErrorLevel
                            TestsFailed("'Active' dialog failed to appear(SetTitleMatchMode=" A_TitleMatchMode ").")
                        else
                        {
                            SendInput, {ENTER} ; Hit 'OK'
                            WinWaitClose, Blank page - Opera,,10
                            if ErrorLevel
                                TestsFailed("Window 'Blank page - Opera' failed to close.")
                            else
                                TestsOK("Closing Opera while download is in progress works.")
                        }
                    }
                }
            }
        }
    }
}
