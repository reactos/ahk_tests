/*
 * Designed for Total Commander 8.0
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

TestName = 2.find_files
 
; Check if can find calc.exe in WinDir\..
TestsTotal++
RunApplication()
if not bContinue
    TestsFailed("We failed somewhere in prepare.ahk.")
else
{
    IfWinNotActive, Total Commander 8.0 - NOT REGISTERED
        TestsFailed("'Total Commander 8.0 - NOT REGISTERED' is not active window.")
    else
    {
        WinMenuSelectItem, Total Commander 8.0 - NOT REGISTERED, , Commands, Search
        if ErrorLevel
            TestsFailed("Unable to hit 'Commands -> Search' in 'Total Commander 8.0 - NOT REGISTERED' window.")
        else
        {
            WinWaitActive, Find Files, &Start search, 5
            if ErrorLevel
                TestsFailed("'Find Files (Start search)' window failed to appear.")
            else
            {
                ControlSetText, Edit3, calc.exe, Find Files, &Start search ; Search for
                if ErrorLevel
                    TestsFailed("Unable to set 'Search for' to 'calc.exe' in 'Find Files (Start search)' window.")
                else
                {
                    SendInput, {ALTDOWN}i{ALTUP} ;  Focus 'Search in' field, ControlSetText will cause problems
                    SendInput, %A_WinDir%
                    ControlClick, TButton16, Find Files, &Start search ; Hit 'Start search' button
                    if ErrorLevel
                        TestsFailed("Unable to hit 'Start search' button in 'Find Files (Start search)' window.")
                    else
                    {
                        ControlText := " [1 files and 0 directories found]"
                        ControlGetText, OutputVar, TMyPanel1, Find Files
                        if ErrorLevel
                            TestsFailed("Unable to get caption of 'Start search' button in 'Find Files (Start search)' window.")
                        else
                        {
                            TimeOut := 0
                            while (OutputVar <> ControlText) and (TimeOut < 40)
                            {
                                Sleep, 500
                                ControlGetText, OutputVar, TMyPanel1, Find Files
                                TimeOut++
                            }
                            
                            if not (OutputVar == ControlText)
                                TestsFailed("Timed out, result: '" OutputVar "'.")
                            else
                            {
                                Process, Close, %ProcessExe%
                                Process, WaitClose, %ProcessExe%, 4
                                if ErrorLevel
                                    TestsFailed("Unable to terminate '" ProcessExe "' process after search.")
                                else
                                    TestsOK("'Find Files' executed by 'Commands -> Search' successfully, process '" ProcessExe "' terminated.")
                            }
                        }
                    }
                }
            }
        }
    }
}
