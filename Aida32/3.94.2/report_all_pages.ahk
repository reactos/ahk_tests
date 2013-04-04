/*
 * Designed for Aida32 3.94.2
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

TestName = 3.report_all_pages

; Test if can do "Report -> Report Wizard"
TestsTotal++
RunApplication()
if bContinue
{
    IfWinNotactive, AIDA32 - Enterprise System Information
        TestsFailed("'AIDA32 - Enterprise System Information' window is NOT active.")
    else
    {
        SendInput, !r ; Alt+R to open 'Report' menu
        SendInput, {ENTER} ; Choose 'Report Wizard...'
        WinWaitActive, Report Wizard - AIDA32,,3
        if ErrorLevel
            TestsFailed("'Report Wizard - AIDA32' window failed to open despite Alt+R, ENTER were sent.")
        else
        {
            ControlClick, TButton2, Report Wizard - AIDA32 ; Hit 'Next' button
            if ErrorLevel
                TestsFailed("Unable to click 'Next' button in 'Report Wizard - AIDA32' window.")
            else
            {
                WinWaitActive, Report Wizard - AIDA32, All pages, 3
                if ErrorLevel
                    TestsFailed("'Report Wizard - AIDA32 (All pages)' window failed to appear.")
                else
                {
                    SendInput, !a ; Check 'All pages' radiobutton
                    ControlClick, TButton2, Report Wizard - AIDA32 ; Hit 'Next' button.
                    if ErrorLevel
                        TestsFailed("Unable to click 'Next' button in 'Report Wizard - AIDA32 (All pages)' window.")
                    else
                    {
                        WinWaitActive, Report Wizard - AIDA32, Plain &Text, 3
                        if ErrorLevel
                            TestsFailed("'Report Wizard - AIDA32 (Plain Text)' failed to appear.")
                        else
                        {
                            SendInput, !t ; Check 'Plain Text' radiobutton
                            Sleep, 700 ; Delay is required in order to make test to work in WinXP SP3
                            ControlClick, TButton2, Report Wizard - AIDA32, Plain &Text ; Hit 'Finish' button
                            if ErrorLevel
                                TestsFailed("Unable to click 'Finish' button in 'Report Wizard - AIDA32 (Plain Text)' window.")
                            else
                            {
                                WinWaitClose, Report Wizard - AIDA32, Plain &Text, 3
                                if ErrorLevel
                                    TestsFailed("'Report Wizard - AIDA32 (Plain Text)' window failed to close despite 'Finish' button being clicked.")
                                else
                                    TestsOK("'Report Wizard - AIDA32 (Plain Text)' window closed.")
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
    WinWaitActive, Report - AIDA32,, 3
    if ErrorLevel
        TestsFailed("'Report - AIDA32' window failed to appear.")
    else
    {
        WinWait, ahk_class tooltips_class32,,3
        if ErrorLevel
            TestsFailed("No tooltips window detected.")
        else
        {
            iTimeOut := 20
            while (iTimeOut > 0)
            {
                IfWinNotActive, Report - AIDA32
                    break
                else
                {
                    ControlGet, bVisible, Visible,, Internet Explorer_Server1, Report - AIDA32
                    if bVisible = 1 ; Control is visible
                        break
                    else
                    {
                        iTimeOut--
                        Sleep, 1000
                    }
                }
            }

            IfWinNotActive, Report - AIDA32
                TestsFailed("'Report - AIDA32' window is NOT active anymore (iTimeOut=" iTimeOut ").")
            else
            {
                TestsInfo("iTimeOut=" iTimeOut "")
                ControlClick, x142 y31, Report - AIDA32
                if ErrorLevel
                    TestsFailed("Unable to click at 142x31 (Save To File) in 'Report - AIDA32' window.")
                else
                {
                    WinWaitActive, Save Report,,3
                    if ErrorLevel
                        TestsFailed("'Save Report' widnow failed to appear despite 142x31 (Save To File) being clicked in 'Report - AIDA32' window.")
                    else
                    {
                        szFilePath = %A_Desktop%\report_all_pages.txt
                        ControlSetText, Edit1, %szFilePath%, Save Report
                        if ErrorLevel
                            TestsFailed("Unable to set Edit1 control text to '" szFilePath "' in 'Save Report' window.")
                        else
                        {
                            SendInput, {ENTER} ; Hit 'Save' button
                            WinWaitClose, Save Report,,3
                            if ErrorLevel
                                TestsFailed("'Save Report' window failed to close despite ENTER being sent.") ; Window will be closed when app terminated
                            else
                                TestsOK("'Save Report' window closed.")
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
    WinWaitActive, Success, Report saved, 3
    if ErrorLevel
        TestsFailed("'Succes (Report saved)' window failed to appear.")
    else
    {
        SendInput, {ENTER} ; Hit 'Button1' aka 'OK' button. ControlClick doesn't work here.
        WinWaitClose, Success, Report saved, 3
        if ErrorLevel
            TestsFailed("'Succes (Report saved)' window failed to close despite 'OK' button being clicked (Sent ENTER).")
        else
        {
            WinWaitActive, Report - AIDA32,,3
            if ErrorLevel
                TestsFailed("'Report - AIDA32' failed to activate.")
            else
            {
                IfNotExist, %szFilePath%
                    TestsFailed("'" szFilePath "' does NOT exist.")
                else
                {
                    FileReadLine, szText, %szFilePath%, 8 ; Line 8:     Generator                                         Administrator
                    if ErrorLevel
                        TestsFailed("Unable to read '" szFilePath "' despite file exist.")
                    else
                    {
                        szUser = Administrator
                        IfNotInString, szText, %szUser%
                            TestsFailed("Unexpected text in line 8. Is '" szText "', should CONTAIN '" szUser "'.")
                        else
                            TestsOK("File contails expected text.")
                    }
                }
            }
        }
    }
}


bTerminateProcess("aida32.exe")
bTerminateProcess("aida32.bin")
