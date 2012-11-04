/*
 * Designed for Miranda IM 0.10.0
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

TestName = 2.irc_chat_test

; Test if can open picture using File -> Open dialog and close application successfully
TestsTotal++
RunApplication()
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, Create new account, Enter
        TestsFailed("'Create new account (Enter)' is not an active window.")
    else
    {
        SendInput, IRCTest ; Account name (focused by default)
        ControlGetText, AccountName, Edit1
        if ErrorLevel
            TestsFailed("Unable to get account name field text from 'Create new account (Enter)' window.")
        else
        {
            if (AccountName != "IRCTest")
                TestsFailed("Account name is not the same as expected (is '" AccountName "', should be 'IRCTest').")
            else
            {
                Control, ChooseString, IRC, ComboBox1, Create new account, Enter ; Chnage protocol type to IRC
                if ErrorLevel
                    TestsFailed("Unable to change protocol type to 'IRC' in 'Create new account (Enter)' window.")
                else
                {
                    SendInput, {ENTER} ; Hit 'OK' button
                    WinWaitClose,,,3
                    if ErrorLevel
                        TestsFailed("'Create new account (Enter)' window failed to close despite ENTER was sent.")
                    else
                    {
                        WinWaitActive, Accounts, Configure, 3
                        if ErrorLevel
                            TestsFailed("'Accounts (Configure)' window failed to appear after closing 'Create new account (Enter)' window.")
                        else
                        {
                            ControlClick, ListBox1
                            if ErrorLevel
                                TestsFailed("Unable to hit ListBox1 control in 'Accounts (Configure)' window.")
                        }
                    }
                }
            }
        }
    }

    if bContinue
    {
        Control, ChooseString, FreeNode, ComboBox1, Accounts, Configure
        if ErrorLevel
            TestsFailed("Unable to change Server to 'FreeNode' in 'Accounts (Configure)' window.")
        else
        {
            ControlSetText, Edit5, MirandaIMTest ; Enter Nick
            if ErrorLevel
                TestsFailed("Unable to enter 'MirandaIMTest' to 'Nick' field in 'Accounts (Configure)' window.")
            else
            {
                ControlSetText, Edit7, MirandaIMTest@reactos.org ; Enter Full name (e-mail)
                if ErrorLevel
                    TestsFailed("Unable to enter 'MirandaIMTest@reactos.org' to 'Full name (e-mail)' field in 'Accounts (Configure)' window.")
                else
                {
                    SendInput, {ENTER} ; Hit 'OK' button
                    WinWaitClose, Accounts, Configure, 3
                    if ErrorLevel
                        TestsFailed("'Accounts (Configure)' window failed to close despite ENTER was sent.")
                    else
                    {
                        WinActivate, Miranda IM
                        WinWaitActive, Miranda IM,, 3
                        if ErrorLevel
                            TestsFailed("Unable to activate 'Miranda IM' window.")
                        else
                        {
                            SendInput, {ALT}{DOWN}{RIGHT}{ENTER} ; Miranda -> IRCTest -> Quick connect
                            WinWaitActive, Quick connect, Please, 3
                            if ErrorLevel
                                TestsFailed("'Quick connect (Please)' window failed to appear.")
                        }
                    }
                }
            }
        }
    }

    if bContinue
    {
        Control, ChooseString, FreeNode, ComboBox1, Quick connect, Please
        if ErrorLevel
            TestsFailed("Unable to change Server to 'FreeNode' in 'Quick connect (Please)' window.")
        else
        {
            SendInput, {ENTER} ; Hit 'Connect' button
            WinWaitClose, Quick connect, Please, 3
            if ErrorLevel
                TestsFailed("'Quick connect (Please)' window failed to close despite ENTER was sent.")
            else
            {
                Sleep, 5500 ; Let it to connect to server. FIXME: remove hardcoded value
                WinWaitActive, Miranda IM,,3
                if ErrorLevel
                    TestsFailed("'Miranda IM' window failed to appear after closing 'Quick connect (Please)' window.")
                else
                {
                    SendInput, {ALT}{DOWN}{RIGHT}{DOWN}{ENTER} ; Miranda -> IRCTest -> Join channel
                    WinWaitActive, Question, Join channel, 3
                    if ErrorLevel
                        TestsFailed("'Question (Join channel)' window failed to appear.")
                    else
                    {
                        SendInput, reactos-testers ; Enter channel name
                        ControlGetText, ChannelName, Edit1, Question, Join channel
                        if ErrorLevel
                            TestsFailed("Unable to get channel name from 'Question (Join channel)' window.")
                        else
                        {
                            if (ChannelName != "reactos-testers")
                                TestsFailed("Channel name is not the same as expected (is '" ChannelName "', should be 'reactos-testers') in 'Question (Join channel)' window.")
                            else
                            {
                                SendInput, {ENTER} ; Hit 'OK' button
                                WinWaitClose,  Question, Join channel, 3
                                if ErrorLevel
                                    TestsFailed("'Question (Join channel)' window failed to close despite ENTER was sent.")
                            }
                        }
                    }
                }
            }
        }
    }

    if bContinue
    {
        SetTitleMatchMode, 1 ; A window's title must start with the specified WinTitle to be a match
        WinWaitActive, #reactos-testers: Chat Room,,3
        if ErrorLevel
            TestsFailed("'#reactos-testers: Chat Room' window failed to appear (SetTitleMatchMode=" A_TitleMatchMode ").")
        else
        {
            TextToSend = I confirm that Miranda IM 0.10.0 works on ReactOS
            SendInput, %TextToSend% ; Send text to channel
            Sleep, 200 ; Some delay required before sending text to channel
            IfWinNotActive, #reactos-testers: Chat Room
                TestsFailed("Slept for a while and '#reactos-testers: Chat Room' window became inactive (SetTitleMatchMode=" A_TitleMatchMode ").")
            else
            {
                SendInput, {ENTER}
                
                TestsInfo("Waiting for sent text to appear in channel.")
                iTimeOut := 50
                while iTimeOut > 0
                {
                    IfWinActive, #reactos-testers: Chat Room
                    {
                        ControlGetText, ChannelText, RichEdit20W2 ; Get text from channel window
                        IfNotInString, ChannelText, %TextToSend% ; Check if channel text contains the text we sent
                        {
                            Sleep, 100
                            iTimeOut--
                        }
                        else
                            break ; Yes, it is there
                    }
                    else
                        break ; exit the loop if something poped-up
                }

                ControlGetText, ChannelText, RichEdit20W2 ; Get text from channel window
                if ErrorLevel
                    TestsFailed("Unable to get text from channel window in '#reactos-testers: Chat Room' window (SetTitleMatchMode=" A_TitleMatchMode ", iTimeOut=" iTimeOut ").")
                else
                {
                    IfNotInString, ChannelText, %TextToSend% ; Check if channel text contains the text we sent
                        TestsFailed("Channel text doesn't contain the text we sent (iTimeOut=" iTimeOut ").")
                    else
                    {
                        Process, Close, %ProcessExe%
                        Process, WaitClose, %ProcessExe%, 4
                        if ErrorLevel
                            TestsFailed("Almost succeeded, but failed to terminate '" ProcessExe "' process.")
                        else
                            TestsOK("Configured IRC and typed some text in #reactos-tetsers.")
                    }
                }
            }
        }
    }
}
