/*
 * Designed for Adobe Flash Player v10.3 (10.3.181.26)
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

Module = FlashPlayer_10.3.181.26:%1%
bContinue := false

SetupExe = %A_WorkingDir%\Apps\Adobe_Flash_Player_10.3.exe

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists
TestsTotal++
IfExist, %SetupExe%
{
    TestsOK++
    Run %SetupExe%
    bContinue := true
}
else
{
    TestsFailed++
    OutputDebug, FAILED: %Module%:%A_LineNumber%: '%SetupExe%' not found.`n
    bContinue := false
}

; Test if can start setup
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe® Flash® Player 10.3 Installer,, 15 ; Wait 15 secs for window to appear
    if not ErrorLevel ;Window is found and it is active
    {
        TestsOK++
        OutputDebug, OK: %Module%:%A_LineNumber%: 'Adobe Flash Player 10.3 Installer' window with checkbox appeared.`n
        Sleep, 2500
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: 'Adobe Flash Player 10.3 Installer' window with checkbox failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

; Test if done
TestsTotal++
if bContinue
{
    Control, Check, , Button4, Adobe® Flash® Player 10.3 Installer ; Check 'I agree' checkbox
    if not ErrorLevel
    {
        Sleep, 700
        ControlFocus, Button3, Adobe® Flash® Player 10.3 Installer ; Move focus on 'Install' button
        if not ErrorLevel
        {
            Sleep, 700
            SendInput, {ENTER} ; We know for sure we are on right place
        
            WinWaitActive, Adobe® Flash® Player 10.3 Installer,D, 15 ; Wait 15 secs for installation to be done
            if not ErrorLevel ;Window is found and it is active
            {
                Sleep, 1500
                ControlFocus, Button3, Adobe® Flash® Player 10.3 Installer ; Move focus on 'Done' button
                if not ErrorLevel
                {
                    TestsOK++
                    OutputDebug, OK: %Module%:%A_LineNumber%: 'Adobe Flash Player 10.3 Installer' window with 'DONE' button appeared.`n
                    Sleep, 1500

                    SendInput, {ENTER}
                    bContinue := true
                }
                 else
                {
                    TestsFailed++
                    WinGetTitle, title, A
                    OutputDebug, FAILED: %Module%:%A_LineNumber%: There was problem with focusing 'Done' button. Active window caption: '%title%'.`n
                    bContinue := false
                }
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, FAILED: %Module%:%A_LineNumber%: 'Adobe Flash Player 10.3 Installer' window with 'DONE' button failed to appear. Active window caption: '%title%'.`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, FAILED: %Module%:%A_LineNumber%: There was problem with focusing 'Install' button. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: There was problem with checking 'License Agreement' checkbox. Active window caption: '%title%'.`n
        bContinue := false
    }
}

;Check if FlashUtil10t_Plugin.exe exists
TestsTotal++
if bContinue
{
    Sleep, 2500
    IfExist, %A_WinDir%\system32\Macromed\Flash\FlashUtil10t_Plugin.exe
    {
        TestsOK++
        OutputDebug, OK: %Module%:%A_LineNumber%: Should be installed, because '%A_WinDir%\system32\Macromed\Flash\FlashUtil10t_Plugin.exe' was found.`n
        bContinue := true
    }
    else
    {
        TestsFailed++
        OutputDebug, FAILED: %Module%:%A_LineNumber%: Can NOT find '%A_WinDir%\system32\Macromed\Flash\FlashUtil10t_Plugin.exe'.`n
        bContinue := false
    }
}
