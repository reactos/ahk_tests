/*
 * Designed for VLC Media Player 2.0.3
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

SetupExe = %A_WorkingDir%\Apps\VLC_Media_Player_2.0.3_Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %SetupExe%
{
    ; Get rid of other versions
    IfExist, %A_ProgramFiles%\VideoLAN\VLC\uninstall.exe
    {
        Process, Close, vlc.exe
        RunWait, %A_ProgramFiles%\VideoLAN\VLC\uninstall.exe /S ; Run uninstaller in silent mode and wait until it is done
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\VideoLAN
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\VLC media player
        FileRemoveDir, %A_ProgramFiles%\VideoLAN, 1
        FileRemoveDir, %A_AppData%\vlc, 1
        Sleep, 1000
        IfExist, %A_ProgramFiles%\VideoLAN
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%A_ProgramFiles%\VideoLAN'.`n
            bContinue := false
        }
    }
    Run %SetupExe%
    bContinue := true

}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%SetupExe%' not found.`n
    bContinue := false
}


; Test if can start setup
TestsTotal++
if bContinue
{
    WinWaitActive, Installer Language, Please select a language, 15 ; Wait 15 secs for window to appear
    if not ErrorLevel ;Window is found and it is active
    {
        if LeftClickControl("Button1") ; Hit 'OK'
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installer Language' window appeared and 'OK' button was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to hit 'OK' button in 'Installer Language' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Installer Language' window failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'VLC media player 2.0.3 Setup' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, Welcome to the VLC, 15
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'VLC media player 2.0.3 Setup' window with 'Welcome to the VLC' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'VLC media player 2.0.3 Setup' window with 'Welcome to the VLC' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, License Agreement, 15
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'VLC media player 2.0.3 Setup' window with 'License Agreement' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'I Agree' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'VLC media player 2.0.3 Setup' window with 'License Agreement' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, Choose Components, 15
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'VLC media player 2.0.3 Setup' window with 'Choose Components' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'VLC media player 2.0.3 Setup' window with 'Choose Components' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, Choose Install Location, 15
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'VLC media player 2.0.3 Setup' window with 'Choose Install Location' appeared.`n
        SendInput, {ALTDOWN}i{ALTUP} ; Hit 'Install' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'VLC media player 2.0.3 Setup' window with 'Choose Install Location' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Installing' window can popup and go away
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, Installing, 7
    if not ErrorLevel
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'VLC media player 2.0.3 Setup' window with 'Installing' appeared, waiting for it to dissapear.`n
        
        WinWaitClose, VLC media player 2.0.3 Setup, Installing, 150
        if not ErrorLevel
        {
            Sleep, 250

            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'VLC media player 2.0.3 Setup' window with 'Installing' went away.`n
            bContinue := true
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'VLC media player 2.0.3 Setup' window with 'Installing' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, Completing, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'VLC media player 2.0.3 Setup' window with 'Completing' appeared.`n

        SendInput, {ALTDOWN}r{ALTUP} ; Uncheck 'Run VLC'
        SendInput, {ALTDOWN}f{ALTUP} ; Hit 'Finish' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'VLC media player 2.0.3 Setup' window with 'Completing' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 250
    AppExe = %A_ProgramFiles%\VideoLAN\VLC\vlc.exe
    IfExist, %AppExe%
    {
        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: Should be installed, because '%AppExe%' was found.`n
        bContinue := true
    }
    else
    {
        TestsFailed++
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%AppExe%'.`n
        bContinue := false
    }
}
