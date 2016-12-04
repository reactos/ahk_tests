/*
 * Designed for OllyDbg 1.10
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

TestName = 2.debug_run
szDocument =  %A_WinDir%\System32\calc.exe ; File name is case sensitive!

; Test if can 
TestsTotal++
SplitPath, szDocument, NameExt
Process, Close, %NameExt% ; Terminate external app, because we don't want it running
Process, WaitClose, %NameExt%, 4
if ErrorLevel
    TestsFailed("Unable to terminate '" NameExt "' process.")
else
{
    RunApplication(szDocument)
    if not bContinue
        TestsFailed("We failed somewhere in prepare.ahk.")
    else
    {
        IfWinNotActive, OllyDbg - %NameExt%
            TestsFailed("Window 'OllyDbg - " NameExt "' is not active.")
        else
        {
            WinMenuSelectItem, OllyDbg - %NameExt%, , Debug, Run
            if ErrorLevel
                TestsFailed("Unable to hit 'Debug -> Run' in 'OllyDbg - " NameExt "' window.")
            else
            {
                WinWaitActive, ReactOS Calculator,,5
                if not ErrorLevel
                    WindowTitle = ReactOS Calculator
                else
                {
                    WindowTitle = Calculator
                    WinWaitActive,Calculator,,5
                }
                if ErrorLevel
                {
                    Process, Exist, %NameExt%
                    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                    if NewPID = 0
                        TestsFailed("Window 'Calculator' failed to appear. No '" NameExt "' process detected.")
                    else
                        TestsFailed("Window 'Calculator' failed to appear. '" NameExt "' process detected.")
                }
                else
                {
                    WinClose, %WindowTitle%
                    WinWaitClose, %WindowTitle%,, 3
                    if ErrorLevel
                        TestsFailed("'Calculator' window failed to close.")
                    else
                    {
                        WinWaitActive, OllyDbg - %NameExt%,, 5
                        if ErrorLevel
                            TestsFailed("Window 'OllyDbg - " NameExt "' did not became active after closing 'Calculator' window.")
                        else
                        {
                            WinClose, OllyDbg - %NameExt%
                            WinWaitClose, OllyDbg - %NameExt%,, 3
                            if ErrorLevel
                                TestsFailed("'OllyDbg - " NameExt "' window failed to close.")
                            else
                                TestsOK("'" NameExt "' was opened via command line, ran it via 'Debug -> Run', closed its window and closed OllyDbg successfully.")
                        }
                    }
                }
            }
        }
    }
}
