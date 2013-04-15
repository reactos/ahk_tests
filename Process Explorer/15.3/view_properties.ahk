/*
 * Designed for Process Explorer 15.3
 * Copyright (C) 2013 Edijs Kolesnikovics
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

ModuleExe = %A_WorkingDir%\Apps\Process_Explorer_15.3.exe
TestName = 1.view_properties
SetTitleMatchMode, 1 ; A window's title must start with the specified WinTitle to be a match.

; Check if can view properties of selected process
TestsTotal++
if bContinue
{
    IfWinNotActive, Process Explorer - Sysinternals: www.sysinternals.com
        TestsFailed("'Process Explorer - Sysinternals: www.sysinternals.com' window is NOT active.")
    else
    {
        ControlClick, TreeListWindowClass1, Process Explorer - Sysinternals: www.sysinternals.com,, RIGHT,, NA x400 y150 ; right-click at coordinates of control
        if ErrorLevel
            TestsFailed("Unable to perform right-click in 'Process Explorer - Sysinternals: www.sysinternals.com' window.")
        else
        {
            SendInput, p ; Choose 'Properties' from right-click menu
            SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
            WinWaitActive, Properties, Image File, 3
            if ErrorLevel
                TestsFailed("Right-clicked, sent 'p' to select 'Properties' from menu, but 'Properties (Image File)' window failed to appear.")
            else
            {
                ControlGetText, szPath, Edit2, Properties, Image File ; Get text of 'Path' field
                if ErrorLevel
                    TestsFailed("Unable to get text of 'Path' field in 'Properties (Image File)' window.")
                else
                {
                    IfNotExist, %szPath%
                        TestsFailed("'path' field in 'Properties (Image File)' window contains '" szPath "' and such file does NOT exist.")
                    else
                        TestsOK("Read 'Path' fiend in 'Properties (Image File)', got '" szPath "' and such file exist.")
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    WinClose, Properties, Image File
    WinWaitClose, Properties, Image File, 3
    if ErrorLevel
        TestsFailed("Unable to close 'Properties (Image File)' window.")
    else
    {
        WinWaitActive, Process Explorer - Sysinternals: www.sysinternals.com,,3
        if ErrorLevel
            TestsFailed("Closed 'Properties (Image File)' window, but 'Process Explorer - Sysinternals: www.sysinternals.com' window failed to activate.")
        else
        {
            WinClose, Process Explorer - Sysinternals: www.sysinternals.com
            WinWaitClose, Process Explorer - Sysinternals: www.sysinternals.com,,3
            if ErrorLevel
                TestsFailed("Unable to close 'Process Explorer - Sysinternals: www.sysinternals.com' window.")
            else
            {
                Process, WaitClose, %ProcessExe%, 15 ; It takes some time for process to close
                if ErrorLevel
                    TestsFailed("'Process Explorer - Sysinternals: www.sysinternals.com' window closed, but '" ProcessExe "' process failed to.")
                else
                    TestsOK("Closed 'Process Explorer - Sysinternals: www.sysinternals.com' window and '" ProcessExe "' process closed too.")
            }
        }
    }
}
