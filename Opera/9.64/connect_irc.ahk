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

TestName = 9.connect_irc

; Test if can configure and connect to IRC server
TestsTotal++
if bContinue
{
    IfWinNotActive, Speed Dial - Opera
        TestsFailed("Window 'Speed Dial - Opera' is not active window.")
    else
    {
        iTimeOut := 20 ; Some delay required or test will not always succeed
        while (iTimeOut > 0) 
        {
            IfWinActive, Speed Dial - Opera
            {
                SendInput, !t ; Alt+T aka Tools from main menu. WinMenuSelectItem doesn't work here
                SendInput, {ENTER} ; Tools -> Mail and Chat Accounts
                Sleep, 100
                iTimeOut--
            }
            else
                break
        }

        WinWaitActive, Account Needed,, 1
        if ErrorLevel
            TestsFailed("'Account Needed' window failed to appear. Unable to do Alt+T, ENTER?")
        else
        {
            SendInput, {ENTER} ; Hit 'Yes' button ; Button haves no control name
            WinWaitClose, Account Needed,, 3
            if ErrorLevel
                TestsFailed("Sent ENTER to hit 'Yes' button in 'Account Needed' window, but window failed to close.")
            else
            {
                WinWaitActive, New Account Wizard,,3
                if ErrorLevel
                    TestsFailed("'New Account Wizard' window failed to appear.")
                else
                {
                    ; Select 'Chat (IRC)'
                    Loop, 3
                        SendInput, {DOWN}
                    SendInput, {ENTER} ; Hit 'Next' button in 'New Account Wizard' window
                    Real_Name = Opera_Chat_Test
                    SendInput, %Real_Name%
                    SendInput, ^a ; Ctrl+A
                    clipboard = ; Clean the clipboard
                    SendInput, ^c ; Ctrl+C
                    ClipWait, 2
                    if ErrorLevel
                        TestsFailed("Unable to copy 'Real Name' field text into clipboard.")
                    else
                    {
                        if (clipboard != Real_Name)
                            TestsFailed("Tried to enter text into 'Real Name' field in 'New Account Wizard' window, but got unexpected data. Is '" clipboard "', should be '" Real_Name "'.")
                        else
                        {
                            SendInput, {TAB} ; Focus 'E-mail' address field
                            E_Mail = reactos.dev@gmail.com
                            SendInput, %E_Mail%
                            SendInput, ^a ; Ctrl+A
                            clipboard = ; Clean the clipboard
                            SendInput, ^c ; Ctrl+C
                            ClipWait, 2
                            if ErrorLevel
                                TestsFailed("Unable to copy 'E-Mail address' field text into clipboard.")
                            else
                            {
                                if (clipboard != E_Mail)
                                    TestsFailed("Tried to enter text into 'E-mail address' field in 'New Account Wizard' window, but got unexpected data. Is '" clipboard "', should be '" E_Mail "'.")
                                else
                                {
                                    SendInput, {ENTER} ; Go to next page
                                    TestsOK("Seems like we were able to select 'Chat IRC', hit 'Next', fill 'Real Name' and 'E-mail address' fields.")
                                }
                            }
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
    IfWinNotActive, New Account Wizard
        TestsFailed("'New Account Wizard' window is not active anymore.")
    else
    {
        szNick = Opera_IRC
        SendInput, %szNick%
        SendInput, ^a ; Ctrl+A
        clipboard = ; Clean the clipboard
        SendInput, ^c ; Ctrl+C
        ClipWait, 2
        if ErrorLevel
            TestsFailed("Unable to copy 'Nick' field text into clipboard.")
        else
        {
            if (clipboard != szNick)
                TestsFailed("Tried to enter text into 'Nick' field in 'New Account Wizard' window, but got unexpected data. Is '" clipboard "', should be '" szNick "'.")
            else
            {
                SendInput, {ENTER} ; Go to next page
                clipboard = ; Clean the clipboard
                SendInput, ^c ; Copy text from 'Choose IRC network or type in server name' in 'New Account Wizard' window
                ClipWait, 2
                if ErrorLevel
                    TestsFailed("Unable to copy 'Choose IRC network or type in server name' field text into clipboard.")
                else
                {
                    szDefaultServer = OperaNet, Europe
                    if (clipboard != szDefaultServer)
                        TestsFailed("Tried to get text from 'Choose IRC network or type in server name' field in 'New Account Wizard' window, but got unexpected data. Is '" clipboard "', should be '" szDefaultServer "'.")
                    else
                    {
                        szNewServer = irc.freenode.net
                        SendInput, %szNewServer% ; Enter new server address
                        clipboard = ; Clean the clipboard
                        SendInput, ^a ; Ctrl+A
                        SendInput, ^c ; Copy text from 'Choose IRC network or type in server name' in 'New Account Wizard' window
                        ClipWait, 2
                        if ErrorLevel
                            TestsFailed("Unable to copy 'Choose IRC network or type in server name' field text into clipboard after entering '" szNewServer "'.")
                        else
                        {
                            if (clipboard != szNewServer)
                                TestsFailed("Tried to enter text into 'Choose IRC network or type in server name' field in 'New Account Wizard' window, but got unexpected data. Is '" clipboard "', should be '" szNewServer "'.")
                            else
                            {
                                SendInput, {ENTER} ; Hit 'Finish' button in 'New Account Wizard' window
                                WinWaitClose, New Account Wizard,,3
                                if ErrorLevel
                                    TestsFailed("'New Account Wizard' window failed to close despite ENTER was sent to hit 'Finish' button.")
                                else
                                    TestsOK("'New Account Wizard' window closed.")
                            }
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
    WinWaitActive, Speed Dial - Opera,,3
    if ErrorLevel
        TestsFailed("'Speed Dial - Opera' window is not active.")
    else
    {
        WinActivate, Chat Rooms
        WinWaitActive, Chat Rooms,,3
        if ErrorLevel
            TestsFailed("Unable to activate 'Chat Rooms' window.")
        else
        {
            Sleep, 2700 ; Let Opera to fetch room list for a while
            IfWinNotActive, Chat Rooms
                TestsFailed("Some problem occurred while fetching room list.")
            else
            {
                WinMove, Chat Rooms,, 0, 0
                Click, 524, 117 ; Hit 'Join' button in 'Chat Rooms' window
                WinWaitActive, Join Chat Room,,3
                if ErrorLevel
                    TestsFailed("'Join Chat Room' window failed to appear.")
                else
                {
                    szChatRoom = reactos-testers
                    SendInput, %szChatRoom%
                    clipboard = ; Clean the clipboard
                    SendInput, ^a ; Ctrl+A
                    SendInput, ^c ; Ctrl+C
                    ClipWait, 2
                    if ErrorLevel
                        TestsFailed("Unable to copy 'Room' field text into clipboard after entering '" szChatRoom "'.")
                    else
                    {
                        if (clipboard != szChatRoom)
                            TestsFailed("Tried to enter text into 'Room' field in 'Join Chat Room' window, but got unexpected data. Is '" clipboard "', should be '" szChatRoom "'.")
                        else
                        {
                            SendInput, {ENTER} ; Hit 'OK' button in 'Join Chat Room' window
                            WinWaitClose, Join Chat Room,,3
                            if ErrorLevel
                                TestsFailed("Unable to close 'Join Chat Room' window.")
                            else
                            {
                                WinClose, Chat Rooms
                                WinWaitClose, Chat Rooms,,3
                                if ErrorLevel
                                    TestsFailed("Unable to close 'Chat Rooms' window.")
                                else
                                    TestsOK("We should be in a '" szChatRoom "' chat room.")
                            }
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
    WinWaitActive, %szChatRoom% - Opera,,3
    if ErrorLevel
        TestsFailed("'" szChatRoom " - Opera' window is not active.")
    else
    {
        szChatText = Room topic is
        bChatLoaded := false
        iTimeOut := 120
        while (iTimeOut > 0)
        {
            IfWinActive, %szChatRoom% - Opera
            {
                ControlClick, OperaWindowClass4, %szChatRoom% - Opera
                SendInput, ^a ; Ctrl+A
                SendInput, ^c ; Ctrl+C
                IfInString, clipboard, %szChatText%
                {
                    bChatLoaded := true
                    break
                }
                Sleep, 100
                iTimeOut--
            }
            else
                break
        }

        if not bChatLoaded
            TestsFailed("Chat window failed to load properly. (iTimeOut='" iTimeOut "')")
        else
        {
            TestsInfo("Chat window loaded properly. (iTimeOut='" iTimeOut "')")
            SendInput, {TAB}{TAB} ; Focus the area where we have to enter the text in order to send it to the chat
            szTextToEnter = I confirm that Opera 9.64 works in ReactOS. I also would like to tell revision number, but it is hardcoded in shell32.dll
            SendInput, %szTextToEnter% ; Enter text into chat room text field
            clipboard = ; Clean the clipboard
            SendInput, ^a ; Ctrl+A
            SendInput, ^c ; Ctrl+C
            ClipWait, 2
            if ErrorLevel
                TestsFailed("Unable to copy chat field text into clipboard after entering '" szTextToEnter "'.")
            else
            {
                if (clipboard != szTextToEnter)
                    TestsFailed("Tried to enter text into chat field in '" szChatRoom " - Opera' window, but got unexpected data. Is '" clipboard "', should be '" szTextToEnter "'.")
                else
                {
                    SendInput, {ENTER} ; Send text to channel

                    bMessageSent := false
                    iTimeOut := 30
                    while (iTimeOut > 0)
                    {
                        IfWinActive, %szChatRoom% - Opera
                        {
                            ControlClick, OperaWindowClass4, %szChatRoom% - Opera
                            SendInput, ^a ; Ctrl+A
                            SendInput, ^c ; Ctrl+C
                            IfInString, clipboard, %szTextToEnter%
                            {
                                bMessageSent := true
                                break
                            }
                            Sleep, 100
                            iTimeOut--
                        }
                        else
                            break
                    }

                    if not bMessageSent
                        TestsFailed("Unable to send text to channel. (iTimeOut='" iTimeOut "')")
                    else
                        TestsOK("Opera IRC client works perfectly. (iTimeOut='" iTimeOut "')")
                }
            }
        }
    }
}


bTerminateProcess("Opera.exe")
