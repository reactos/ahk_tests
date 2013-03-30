/*
 * Designed for Adobe Reader 7.1.0
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

TestName = 3.view_fulscreen
szDocument =  %A_WorkingDir%\Media\Book.pdf ; Case sensitive!

; Test if can open PDF document and view it in fullscreen mode
TestsTotal++
RunApplication(szDocument)
if bContinue
{
    SplitPath, szDocument, NameExt
    IfWinNotActive, Adobe Reader - [%NameExt%]
        TestsFailed("Window 'Adobe Reader - [" NameExt "]' is not active.")
    else
    {
        WinGetPos, X1, Y1, Width1, Height1, Adobe Reader - [%NameExt%]
        SendInput, ^l ; Cltr+L aka View->Full Screen. WinMenuSelectItem doesn't work here

        iTimeOut := 15
        while (iTimeOut > 0)
        {
            WinGetPos, X, Y, Width, Height, Adobe Reader - [%NameExt%]
            if ((X = -4) AND (Y < Y1) AND (Width > Width1) AND (Height > Height1))
                break
            Sleep, 100
            iTimeOut--
        }

        WinGetPos, X, Y, Width, Height, Adobe Reader - [%NameExt%]
        if not ((X = -4) AND (Y < Y1) AND (Width > Width1) AND (Height > Height1))
            TestsFailed("Something went wrong. Before sending Cltr+L 'Adobe Reader - [" NameExt "]' window was: '" X1 "x" Y1 "', '" Width1 "x" Height1 "', now it is '" X "x" Y "', '" Width "x" Height "'.")
        else
            TestsOK("Sent Cltr+L and 'Adobe Reader - [" NameExt "]' window went fullscreen.")
    }
}


bTerminateProcess(ProcessExe)
