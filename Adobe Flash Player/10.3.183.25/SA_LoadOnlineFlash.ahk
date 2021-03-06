/*
 * Designed for Flash Player 10.3.183.25
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
        TestsInfo("FIXME: use one line when CORE-6737 is fixed.")
        SendInput, !f ; Alt+f aka File
        Sleep, 2
        SendInput, o ; Open
        ; SendInput, ^o ; Ctrl+O aka File->Open ; Disabled due CORE-6737
        WinWaitActive, Open, Enter the, 3
        if ErrorLevel
            TestsFailed("'Open (Enter the)' window failed to appear despite Ctrl+O was sent.")
        else
        {
            SendInput, %szDocument%{ENTER} ; Enter path in 'Open (Enter the)' dialog and hit 'OK' button
            WinWaitClose, Open, Enter the, 3
            if ErrorLevel
                TestsFailed("'Open (Enter the)' window failed to close despite ENTER was sent.")
            else
            {
                IfWinNotActive, Adobe Flash Player 10
                    TestsFailed("Loaded '" szDocument "'. 'Adobe Flash Player 10' is not active anymore.")
                else
                {
                    WinMove, Adobe Flash Player 10,, 10, 10 ; Change window coordinates
                    SearchImg = %A_WorkingDir%\Media\SA_LoadOnlineFlashIMG.jpg
        
                    IfNotExist, %SearchImg%
                        TestsFailed("Can NOT find '" SearchImg "'.")
                    else
                    {
                        TestsInfo("Typed URL. Waiting for ImageSearch to return results.")
                        TimeOut = 43
                        while TimeOut > 0
                        {
                            IfWinActive, Adobe Flash Player 10
                            {
                                ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *60 %SearchImg%
                                if ErrorLevel = 2
                                {
                                    TestsFailed("Could not conduct the ImageSearch ('" SearchImg "' exist).")
                                    break
                                }
                                else if ErrorLevel = 1
                                {
                                    bFound := false
                                    TimeOut--
                                    Sleep, 1000
                                    TestsInfo("TimeOut=" TimeOut ", continuing...")
                                }
                                else
                                {
                                    bFound := true
                                    break
                                }
                            }
                            else
                                break
                        }
                        
                        if not bFound
                            TestsFailed("The search image '" SearchImg "' could NOT be found on the screen (TimeOut=" TimeOut ").")
                        else
                        {
                            Process, Close, %MainAppFile%
                            Process, WaitClose, %MainAppFile%, 4
                            if ErrorLevel
                                TestsFailed("Unable to terminate '" MainAppFile "' process.")
                            else
                                TestsOK("Found '" SearchImg "' on the screen, so, we can play '" szDocument "' (TimeOut=" TimeOut ").")
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
