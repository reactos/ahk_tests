/*
 * Designed for Fox Audio Player 0.9.1
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

TestName = 2.play_wav
szDocument =  %A_WorkingDir%\Media\ReactOS_LogOn.wav ; Case insensitive

; Test if can play wav and exit application
TestsTotal++
RunApplication(szDocument) ; it will check for file existence
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    SplitPath, szDocument,,,, name_no_ext
    IfWinNotActive, %name_no_ext%
        TestsFailed("'" name_no_ext "' window is not an active.")
    else
    {
        PosX = 115
        PosY = 82
        szColorGreen = 0x00E300 ; Green
        szColorRed = 0x0000E3
        Sleep, 1000 ; Small delay required for playing to start
        PixelGetColor, color, %PosX%, %PosY% ; red/green circle in top left side of the window
        if (color != szColorGreen)
            TestsFailed("Pixel colors doesn't match (is '" color "', should be '" szColorGreen "').")
        else
        {
            ; Color is green, wait until playing stops
            iTimeOut = 8 ; wav length is 3sec, but we want to be REALLY sure
            while (color = szColorGreen)
            {
                iTimeOut--
                Sleep, 1000
                PixelGetColor, color, %PosX%, %PosY%
                if (iTimeOut = 0)
                    break ; Timed out, break the loop
            }

            PixelGetColor, color, %PosX%, %PosY%
            if (color = szColorGreen)
                TestsFailed("Pixel color is still '" szColorGreen "' (iTimeOut=" iTimeOut ").")
            else
            {
                WinClose
                WinWaitClose, %name_no_ext%,,3
                if ErrorLevel
                    TestsFailed("Unable to close '" name_no_ext "' window.")
                else
                {
                    Process, WaitClose, %ProcessExe%, 4
                    if ErrorLevel
                        TestsFailed("'" ProcessExe "' process failed to close despite '" name_no_ext "' window closed.")
                    else
                        TestsOK("Played wav, closed '" name_no_ext "' window, '" ProcessExe "' process closed too.")
                }
            }
        }
    }
}
