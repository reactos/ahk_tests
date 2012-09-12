/*
 * Designed for Flash Player 10.3.183.11
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

TestName = 3.SA_LoadOnlineFlash
szDocument =  http://beastybombs.com/game/beastybombs_1_0_beta_1.swf ; Case insensitive.

; Test if can play online located SWF
TestsTotal++
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, Adobe Flash Player 10
        TestsFailed("'Adobe Flash Player 10' window is not active window.")
    else
    {
        ; FIXME: check if online file %szDocument% exist
        WinMenuSelectItem, Adobe Flash Player 10, , File, Open ; File -> Open
        if ErrorLevel
            TestsFailed("Unable to click 'File -> Open' in 'Adobe Flash Player 10' window.")
        else
        {
            WinWaitActive, Open, Enter the, 7
            if ErrorLevel
                TestsFailed("'Open (Enter the)' window is not active window.")
            else
            {
                ControlSetText, Edit1, %szDocument%, Open, Enter the ; Enter path in 'Open' dialog
                if ErrorLevel
                    TestsFailed("Unable to enter path '" szDocument "' in 'Open (Enter the)' window.")
                else
                {
                    Sleep, 700
                    OutputDebug, %TestName%:%A_LineNumber%: If BSOD, then bug 6023.`n
                    ControlClick, Button1, Open, Enter the
                    if ErrorLevel
                        TestsFailed("Unable to hit 'OK' button in 'Open (Enter the)' window.")
                    else
                    {
                        WinWaitClose, Open, Enter the, 5
                        if ErrorLevel
                            TestsFailed("'Open (Enter the)' window failed to close despite 'OK' button being clicked.")
                        else
                        {
                            WinMove, Adobe Flash Player 10,, 10, 10 ; Change window coordinates
                            Sleep, 25000 ; Depends on connection speed
                            IfWinNotActive, Adobe Flash Player 10
                                TestsFailed("Loaded '" szDocument "'. 'Adobe Flash Player 10' is not active anymore.")
                            else
                            {
                                SearchImg = %A_WorkingDir%\Media\SA_LoadOnlineFlashIMG.jpg
                    
                                IfNotExist, %SearchImg%
                                    TestsFailed("Can NOT find '" SearchImg "'.")
                                else
                                {
                                    bFound := false
                                    while TimeOut < 400
                                    {
                                        ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *60 %SearchImg%
                                        if ErrorLevel = 2
                                        {
                                            TestsFailed("Could not conduct the ImageSearch ('" SearchImg "' exist).")
                                            TimeOut := 400 ; Exit the loop
                                        }
                                        else if ErrorLevel = 1
                                        {
                                            bFound := false
                                        }
                                        else
                                        {
                                            TimeOut := 400 ; Exit the loop
                                            bFound := true
                                        }
                                        TimeOut++
                                        Sleep, 10
                                    }
                                    
                                    if not bFound
                                        TestsFailed("The search image '" SearchImg "' could NOT be found on the screen. Color quality not 32bit?")
                                    else
                                    {
                                        Process, Close, %MainAppFile%
                                        Process, WaitClose, %MainAppFile%, 4
                                        if ErrorLevel
                                            TestsFailed("Unable to terminate '" MainAppFile "' process.")
                                        else
                                            TestsOK("Found '" SearchImg "' on the screen, so, we can play '" szDocument "'.")
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

; UrlDownloadToFile requires Internet Explorer 3 or greater, so, bad solution for ReactOS
; Thanks to Lethe Denova for the COM code
;WebFileExists(URL)
;{
;    oHTTP := ComObjCreate("winhttp.winhttprequest.5.1")
;    oHTTP.Open("GET", URL)
;    oHTTP.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:9.0.1) Gecko/20100101 Firefox/9.0.1")
;    oHTTP.Send()
;    oReceived := oHTTP.ResponseText
;    If (Instr(oRecieved, "404"))
;        Flag := False
;    else
;        Flag := True
;    Return Flag
;}
 
;If WebFileExists("http://beastybombs.com/game/beastybombs_1_0_beta_1.swf")
;    Msgbox, This file exists, yo.
;else
;    Msgbox, This file does not exist, yo.
 
;If WebFileExists("http://slonky.com/404")
;    Msgbox, This file exists, yo.
;else
;    Msgbox, This file does not exist, yo.
