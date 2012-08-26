/*
 * Designed for Notepad Lite 3.3.1.0
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

TestName = 2.replace
szDocument =  %A_WinDir%\TextFile.dat ; Case sensitive!

; Test if can open document, replace some text, save it and exit Notepad Lite.
TestsTotal++
FileDelete, %szDocument%
FileAppend, My name is Egijs Kolesnikovics, %szDocument%
if not ErrorLevel
{
    RunApplication(szDocument)
    if bContinue
    {
        IfWinActive, GridinSoft Notepad Lite - [%szDocument%]
        {
            SendInput, {ALTDOWN}s{ALTUP} ; WinMenuSelectItem does not work here
            Sleep, 500
            SendInput, r
            WinWaitActive, GridinSoft Notepad - Replace,,5
            if not ErrorLevel
            {
                ControlSetText, Edit2, Egijs, GridinSoft Notepad - Replace ; Search for
                if not ErrorLevel
                {
                    Sleep, 1000
                    ControlSetText, Edit1, Edijs, GridinSoft Notepad - Replace ; Replace with
                    if not ErrorLevel
                    {
                        Sleep, 1000
                        SendInput, {ALTDOWN}o{ALTUP} ; Hit 'OK' button. 'ControlClick' does not report any error, but it fails all the time
                        Sleep, 1000
                        WinWaitClose, GridinSoft Notepad - Replace,,5
                        if not ErrorLevel
                        {
                            Sleep, 1000
                            WinWaitActive, Confirm replace,,5
                            if not ErrorLevel
                            {
                                Sleep, 1000
                                ControlClick, TButton1, Confirm replace ; Hit 'Yes to all' button
                                if not ErrorLevel
                                {
                                    WinWaitClose, Confirm replace,,5
                                    if not ErrorLevel
                                    {
                                        WinWaitActive, GridinSoft Notepad Lite - [%szDocument%],,5
                                        if not ErrorLevel
                                        {
                                            WinClose, GridinSoft Notepad Lite - [%szDocument%]
                                            SplitPath, szDocument, NameExt
                                            WinWaitActive, *%NameExt% - GridinSoft Notepad,,5
                                            if not ErrorLevel
                                            {
                                                Sleep, 1000
                                                ControlClick, Button1, *%NameExt% - GridinSoft Notepad ; Hit 'Yes' button
                                                if not ErrorLevel
                                                {
                                                    WinWaitClose, GridinSoft Notepad Lite - [%szDocument%],,5
                                                    if not ErrorLevel
                                                        TestsOK("Opened document, replaced some text, saved and closed Notepad Lite successfully.")
                                                    else
                                                        TestsFailed("Window 'GridinSoft Notepad Lite - [" szDocument "]' failed to close.")
                                                }
                                                else
                                                    TestsFailed("Unable to hit 'Yes' button in '*" NameExt " - GridinSoft Notepad' window.")
                                            }
                                            else
                                                TestsFailed("Window '*" NameExt " - GridinSoft Notepad' failed to appear.")
                                        }
                                        else
                                            TestsFailed("Window 'GridinSoft Notepad Lite - [" szDocument "]' is not active.")
                                    }
                                    else
                                        TestsFailed("Window 'Confirm replace' failed to close.")
                                }
                                else
                                    TestsFailed("Unable to hit 'Yes to all' button in 'Confirm replace' window.")
                            }
                            else
                                TestsFailed("Window 'Confirm replace' failed to appear.")
                        }
                        else
                            TestsFailed("Window 'GridinSoft Notepad - Replace' failed to close.")
                    }
                    else
                        TestsFailed("Unable to set 'Replace with' text in 'GridinSoft Notepad - Replace' window.")
                }
                else
                    TestsFailed("Unable to set 'Search for' text in 'GridinSoft Notepad - Replace' window.")
            }
            else
                TestsFailed("Window 'GridinSoft Notepad - Replace' failed to appear.")
        }
        else
            TestsFailed("Window 'GridinSoft Notepad Lite - [" szDocument "]' failed to appear.")
    }
    else
        TestsFailed("We failed somewhere in prepare.ahk.")
}
else
    TestsFailed("Unable to create '%szDocument%'.")
