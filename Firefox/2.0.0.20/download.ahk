/*
 * Designed for Mozilla Firefox 2.0.0.20
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

TestName = 3.download
szURL = https://svn.reactos.org/storage/sylvain/50MiB.dat
ExpectedSize := 52428800 ; 50 MiB (52,428,800 bytes)
SplitPath, szURL, szFileName
szDownloadTo = %A_Desktop%\%szFileName% ; Desktop is our download dir. See prepare.ahk

 
; Check if can download some file
TestsTotal++
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, Mozilla Firefox Start Page - Mozilla Firefox
        TestsFailed("'Mozilla Firefox Start Page - Mozilla Firefox' is not active window.")
    else
    {
        FileDelete, %szDownloadTo% ; Make sure it doesn't exist before continuing
        IfExist, %szDownloadTo%
            TestsFailed("Failed to delete '" szDownloadTo "'.")
        else
        {
            SendInput, {CTRLDOWN}l{CTRLUP}%szURL%{ENTER} ;Download some file
            
            WinWaitActive, Opening %szFileName%,,10
            if ErrorLevel
                TestsFailed("'Opening " szFileName "' window failed to appear, so, downloading failed.")
            else
            {
                ; 'ControlClick' won't work here
                SendInput, {ALTDOWN}s{ALTUP} ; Check 'Save file' radio button
                ; 'OK' button is disabled for split of second. There is no way for us to find out
                ; is it enabled or not (there is no control name AHK could use), so, sleep is a must
                Sleep, 500 ; Depends on connection speed?
                SendInput, {ENTER} ; Save file by hitting 'OK'. The button is focused by default
                WinWaitClose,,,5
                if ErrorLevel
                    TestsFailed("'Opening " szFileName "' window failed to close despite 'ENTER' was sent.")
                else
                {
                    SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
                    WinWaitActive, of 1 file - Downloads,,10
                    if ErrorLevel
                        TestsFailed("Window 'of 1 file - Downloads' failed to appear (SetTitleMatchMode=" A_TitleMatchMode ").")
                    else
                    {
                        TestsInfo("Window 'of 1 file - Downloads' appeared, waiting for it to close. (SetTitleMatchMode=" A_TitleMatchMode ").")
                        iTimeOut := 95
                        while iTimeOut > 0
                        {
                            IfWinActive, of 1 file - Downloads
                            {
                                WinWaitClose, of 1 file - Downloads,, 1
                                iTimeOut--
                            }
                            else
                            {
                                WinGetActiveTitle, ActiveWndTitle
                                TestsInfo("'" ActiveWndTitle "' window poped-up.")
                                break ; exit the loop if something poped-up
                            }
                        }

                        SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match.
                        WinWaitActive, Downloads,,1 ; Should be enought time to download the file?
                        if ErrorLevel
                            TestsFailed("'Downloads' window failed to appear, so, downloading failed. Wasn't enough time? (SetTitleMatchMode=" A_TitleMatchMode ")")
                        else
                        {
                            FileGetSize, DFileSize, %szDownloadTo% ; Desktop is our download dir. See prepare.ahk
                            if DFileSize <> %ExpectedSize%
                                TestsFailed("Downloaded file size is NOT the same as expected [is " DFileSize " and should be " ExpectedSize "].")
                            else
                            {
                                Process, Close, %ProcessExe%
                                Process, WaitClose, %ProcessExe%, 5
                                if ErrorLevel ; The PID still exists.
                                    TestsFailed("Unable to terminate '" ProcessExe "' process.")
                                else
                                    TestsOK("File downloaded. Size the same as expected, '" ProcessExe "' process closed.")
                            }
                        }
                    }
                }
            }
        } 
    }
}
