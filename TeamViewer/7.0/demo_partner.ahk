/*
 * Designed for TeamViewer 7.0 (7.0.12979)
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

TestName = 2.demo_partner

; Test if can remote control TeamViewer demo partner.
TestsTotal++
RunApplication("")
if bContinue
{
    szPartnerID = 12345
    ControlSetText, Edit1, %szPartnerID%, TeamViewer, Ready to connect ; Fill 'Partner ID' field
    if ErrorLevel
        TestsFailed("Unable to fill 'Partner ID' field with '" szPartnerID "' in 'TeamViewer (Ready to connect)' window.")
    else
    {
        ControlClick, Button2, TeamViewer, Ready to connect
        if ErrorLevel
            TestsFailed("Unable to click 'Connect to partner' button in 'TeamViewer (Ready to connect)' window.")
        else
        {
            WinWaitActive, TeamViewer Authentication, Please enter, 6
            if ErrorLevel
                TestsFailed("'TeamViewer Authentication (Please enter)' window failed to appear despite 'Connect to partner' button being clicked.")
            else
            {
                szPasswordApp = %A_WorkingDir%\Apps\GetPassword.exe ; Thanks to Mysoft
                IfNotExist, %szPasswordApp%
                    TestsFailed("Application (" szPasswordApp ") to get TeamViewer password NOT found.")
                else
                {
                    clipboard = ; clean
                    Run, %szPasswordApp%
                    SplitPath, szPasswordApp, szProcess
                    Process, WaitClose, %szProcess%, 3
                    if ErrorLevel
                    {
                        bTerminateProcess(szProcess)
                        TestsFailed("'" szProcess "' process failed to close.")
                    }
                    else
                    {
                        ClipWait, 2
                        if ErrorLevel
                            TestsFailed("Clipboard does NOT contain the password.")
                        else
                        {
                            StringTrimLeft, nPassword, clipboard, 9 ; clipboard=Password=xxxx, nPassword=xxxx
                            ControlSetText, Edit1, %nPassword%, TeamViewer Authentication, Please enter
                            if ErrorLevel
                                TestsFailed("Unable to fill 'Password:' field in 'TeamViewer Authentication (Please enter)' window.")
                            else
                                TestsOK("Filled 'Password:' field in 'TeamViewer Authentication (Please enter)' window with '" nPassword "'.")
                        }
                    }
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    ControlClick, Button1, TeamViewer Authentication, Please enter
    if ErrorLevel
        TestsFailed("Unable to click 'Log On' button in 'TeamViewer Authentication (Please enter)' window.")
    else
    {
        WinWaitClose, TeamViewer Authentication, Please enter, 3
        if ErrorLevel
            TestsFailed("'TeamViewer Authentication (Please enter)' failed to close despite 'Log On' button being clicked.")
        else
        {
            SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
            WinWaitActive, - TeamViewer, TV_CClientToolBar, 5 ; Actual remote control window. 2k3 and XP wnd captions differs
            if ErrorLevel
                TestsFailed("'- TeamViewer' window (TitleMatchMode=" A_TitleMatchMode ") failed to appear.")
            else
            {
                ControlGetPos,,, Width, Height, TV_REMOTEDESKTOP_CLASS1, - TeamViewer, TV_CClientToolBar
                if (!Width)
                    TestsFailed("Unable to get 'TV_REMOTEDESKTOP_CLASS1' control size of '- TeamViewer' window (TitleMatchMode=" A_TitleMatchMode ").")
                else
                {
                    SetFormat, float, 0.0 ; Integer
                    nMiddleX := Width / 2
                    nMiddleY := Height / 2
                    Click, %nMiddleX%, %nMiddleY%
                    clipboard = ; clean
                    SendInput, ^a ; Select All
                    SendInput, ^c ; Ctrl+C aka Copy
                    ClipWait, 3
                    if ErrorLevel
                        TestsFailed("Clipboard contains no text. Unable to focus 'welcome - WordPad' window in remote desktop?")
                    else
                    {
                        szSearchFor = Have fun with testing TeamViewer
                        IfNotInString, clipboard, %szSearchFor%
                            TestsFailed("Clipboard text does NOT contain '" szSearchFor "'. Clipboard='" clipboard "'")
                        else
                            TestsOK("Connecte to '" szPartnerID "' with '" nPassword "' as a password and copied some text of remote desktop.")
                    }
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    WinClose, - TeamViewer, TV_CClientToolBar
    WinWaitClose, - TeamViewer, TV_CClientToolBar, 3
    if ErrorLevel
        TestsFailed("'- TeamViewer' window (TitleMatchMode=" A_TitleMatchMode ") failed to close.")
    else
    {
        WinWaitActive, TeamViewer, The session with, 3
        if ErrorLevel
            TestsFailed("'TeamViewer (The session with)' window failed to appear despite '- TeamViewer' window (TitleMatchMode=" A_TitleMatchMode ") being closed.")
        else
        {
            WinClose, TeamViewer, The session with
            WinWaitClose, TeamViewer, The session with, 3
            if ErrorLevel
                TestsFailed("'TeamViewer (The session with)' window failed to close.")
            else
            {
                Process, WaitClose, %ProcessExe%, 5
                if ErrorLevel
                    TestsFailed("'" ProcessExe "' process failed to close despite 'TeamViewer (The session with)' window being closed.")
                else
                    TestsOK("Closed 'TeamViewer (The session with)' window and '" ProcessExe "' closed too.")
            }
        }
    }
}