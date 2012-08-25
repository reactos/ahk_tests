/*
 * Designed for FAR Manager 1.70.2087
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

TestName = 2.open_folder

; Test if can open 'Plugins' folder
TestsTotal++
RunApplication()
if bContinue
{
    IfWinActive, {%A_ProgramFiles%\Far} - Far
    {
        SendInput, {DOWN}{DOWN}{DOWN} ; Focus 'Plugins'
        Sleep, 1000
        SendInput, {ENTER} ; Open 'Plugins' folder
        WinWaitActive, {%A_ProgramFiles%\Far\Plugins} - Far,,5
        if not ErrorLevel
            TestsOK("")
        else
            TestsFailed("Window '{" A_ProgramFiles "\Far\Plugins} - Far' is not active.")
    }
    else
        TestsFailed("Window '{" A_ProgramFiles "\Far} - Far' is not active.")
}
else
    TestsFailed("We failed somewhere in prepare.ahk.")

Process, Close, Far.exe
