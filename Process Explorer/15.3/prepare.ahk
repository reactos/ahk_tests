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
TestName = prepare

; Terminate application
SplitPath, ModuleExe, ProcessExe
bTerminateProcess(ProcessExe)


TestsTotal++
if bContinue
{
    RegRead, bEulaAccepted, HKEY_CURRENT_USER, Software\Sysinternals\Process Explorer, EulaAccepted
    if not ErrorLevel
    {
        RegDelete, HKEY_CURRENT_USER, Software\Sysinternals\Process Explorer
        if ErrorLevel
            TestsFailed("Unable to delete 'HKEY_CURRENT_USER\Software\Sysinternals\Process Explorer' key which exist.")
        else
            TestsOK("")
    }
    else
        TestsOK("Since can NOT read 'HKEY_CURRENT_USER\Software\Sysinternals\Process Explorer, EulaAccepted' assuming no settings are stored yet.")
}


TestsTotal++
if bContinue
{
    IfNotExist, %ModuleExe%
        TestsFailed("Can NOT find '" ModuleExe "'.")
    else
    {
        Run, %ModuleExe%
        WinWaitActive, Process Explorer License Agreement, EULA, 3
        if ErrorLevel
            TestsFailed("'Process Explorer License Agreement (EULA)' window failed to appear.")
        else
        {
            ControlClick, Button1, Process Explorer License Agreement, EULA ; Hit 'Agree' button
            if ErrorLevel
                TestsFailed("Unable to click 'Agree' button in 'Process Explorer License Agreement (EULA)' window.")
            else
            {
                WinWaitClose, Process Explorer License Agreement, EULA, 3
                if ErrorLevel
                    TestsFailed("'Process Explorer License Agreement (EULA)' window failed to close despite 'Agree' button being reported as clicked.")
                else
                    TestsOK("Clicked 'Agree' button in 'Process Explorer License Agreement (EULA)' window and window closed.")
            }
        }
    }
}


TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1 ; A window's title must start with the specified WinTitle to be a match.
    WinWaitActive, Process Explorer - Sysinternals: www.sysinternals.com,, 3 ; Specifying WinText for WinWaitActive wont work
    if ErrorLevel
        TestsFailed("'Process Explorer - Sysinternals: www.sysinternals.com' window failed to appear (TitleMatchMode=" A_TitleMatchMode ").")
    else
    {
        WinMaximize, Process Explorer - Sysinternals: www.sysinternals.com
        TestsOK("'Process Explorer - Sysinternals: www.sysinternals.com' window appeared (TitleMatchMode=" A_TitleMatchMode ").")
    }
}
