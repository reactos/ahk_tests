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

TestName = 3.Download
szURL = http://iso.reactos.org/livecd/livecd-57637-rel.7z
ExpectedSize := 22672499 ; File size of szURL in bytes

; Test if we can download some file
TestsTotal++
if not bContinue
    TestsFailed("We failed somewhere in prepare.ahk")
else
{
    IfWinNotActive, Speed Dial - Opera
        TestsFailed("Window 'Speed Dial - Opera' is not active window.")
    else
    {
        SplitPath, szURL, szFileName
        szLocalCopy = %A_MyDocuments%\%szFileName%
        IfExist, %szLocalCopy%
            FileDelete, %szLocalCopy%
        SendInput, {CTRLDOWN}l{CTRLUP} ; Toggle address bar
        SendInput, %szURL% ; Enter address
        Sleep, 3500 ; FIXME: remove hardcoded sleep call
        clipboard = ; Empty the clipboard
        Send, ^a ; Ctrl+A
        Send, ^c ; Ctrl+C
        ClipWait, 2
        if ErrorLevel
            TestsFailed(" The attempt to copy text onto the clipboard failed.")
        else
        {
            if clipboard <> %szURL%
                TestsFailed("Clipboard and URL contents are not the same (expected '" szURL "', got '" clipboard "'). Ctrl+L doesnt work?")
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
                    TestsFailed("Window 'Downloading file " szFileName "' failed to appear (iTimeOut=" iTimeOut ").")
                else
                {
                    TestsInfo("'Downloading file " szFileName "' window appeared (iTimeOut=" iTimeOut ").")
                    SendInput, {ENTER} ; Default option is 'Save' and Alt+S doesn't work here. :/
                    SetTitleMatchMode, 1 ; ReactOS 'Save as', WinXP 'Save As', so match if wnd starts with 'Save'
                    WinWaitActive, Save,, 7
                    if ErrorLevel
                        TestsFailed("'Save as' dialog failed to appear.")
                    else
                    {
                        SendInput, !n ; Focus 'File name' field
                        SendInput, %szLocalCopy%
                        SendInput, {ALTDOWN}s{ALTUP} ; Hit 'Save'
                        WinWaitClose, Save,,3
                        if ErrorLevel
                            TestsFailed("'Save' dialog failed to close.")
                        else
                        {
                            WinWaitActive, Blank page - Opera,, 3
                            if ErrorLevel
                                TestsFailed("'Blank page - Opera' window failed to appear.")
                            else
                            {
                                SendInput, {CTRLDOWN}{TAB}{CTRLUP} ; Navigate thru tabs to 'Transfers' tab
                                SetTitleMatchMode, 1 ; A window's title must start with the specified WinTitle to be a match.
                                WinWaitActive, Transfers 0,, 5 ; Expected window title is something like 'Transfers 03:12 - Opera'
                                if ErrorLevel
                                    TestsFailed("Window 'Transfers 0' failed to appear ( SetTitleMatchMode=" A_TitleMatchMode ").")
                                else
                                {
                                    iTimeOut := 120
                                    while iTimeOut > 0
                                    {
                                        IfNotExist, %szLocalCopy%
                                        {
                                            TestsFailed("'" szLocalCopy "' does not exist, but we saved it there.")
                                            break
                                        }
                                        else
                                        {
                                            IfWinActive, Transfers 0
                                            {
                                                WinWaitActive, Transfers - Opera,,1
                                                iTimeOut--
                                            }
                                            else
                                                break ; exit the loop if something poped-up
                                        }
                                    }

                                    WinWaitActive, Transfers - Opera,,1
                                    if ErrorLevel
                                        TestsFailed("Window 'Transfers - Opera' failed to appear (iTimeOut=" iTimeOut ").")
                                    else
                                    {
                                        TestsInfo("Active window is 'Transfers - Opera', download is almost done (iTimeOut=" iTimeOut ").")
                                        ; Extra sleep is required, because download is not actually done
                                        iTimeOut := 6
                                        while iTimeOut > 0
                                        {
                                            FileGetSize, DFileSize, %szLocalCopy%
                                            if DFileSize <> %ExpectedSize%
                                            {
                                                Sleep, 1000
                                                iTimeOut--
                                            }
                                            else
                                                break
                                        }
                                        
                                        FileGetSize, DFileSize, %szLocalCopy%
                                        if DFileSize <> %ExpectedSize%
                                            TestsFailed("Downloaded file size is NOT the same as expected [is " DFileSize " and should be " ExpectedSize "] (iTimeOut=" iTimeOut ").")
                                        else
                                        {
                                            Process, Close, %ProcessExe%
                                            Process, WaitClose, %ProcessExe%, 4
                                            if ErrorLevel
                                                TestsFailed("Unable to terminate '" ProcessExe "' process.")
                                            else
                                                TestsOK("File downloaded. Size the same as expected (iTimeOut=" iTimeOut ").")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
