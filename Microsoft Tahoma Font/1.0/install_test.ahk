/*
 * Designed for Microsoft Tahoma Font 1.0
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

ModuleExe = %A_WorkingDir%\Apps\Microsoft Tahome Font 1.0 Setup.exe
TestName = 1.install
MainAppFile = Tahomabd.TTF

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
RunAsAdmin()
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    IfNotExist, %A_WinDir%\Fonts\%MainAppFile%
        bContinue := true
    else
    {
        ; Deleting using GUI succeeds
        ; Deleting using 'cmd.exe del %WinDir%\fonts\tahoma.ttf' fails 'access denied'
        ; AHK 'FileDelete' fails too
        FileDelete, %A_WinDir%\Fonts\%MainAppFile%
        if ErrorLevel
            TestsFailed("Unable to delete hardcoded path '" A_WinDir "\Fonts\" MainAppFile "'. FIXME: fails on win2k3 sp2 too.")
        else
            bContinue := true
    }

    if bContinue
    {
        TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
        Run %ModuleExe%
    }
}


; Test if 'Tahoma Font Family (Please read)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Tahoma Font Family, Please read, 7
    if ErrorLevel
        TestsFailed("'Tahoma Font Family (Please read)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button1, Tahoma Font Family, Please read ; Hit 'Yes' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Yes' button in 'Tahoma Font Family (Please read)' window.")
        else
        {
            WinWaitClose, Tahoma Font Family, Please read, 5
            if ErrorLevel
                TestsFailed("'Tahoma Font Family (Please read)' window failed to close despite 'Yes' button being clicked.")
            else
                TestsOK("'Tahoma Font Family (Please read)' window appeared, 'Yes' button clicked and window closed.")
        }
    }
}


; Test if 'Tahome Font Family (Tahoma Regular and Bold)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Tahoma Font Family, Tahoma Regular and Bold, 7
    if ErrorLevel
        TestsFailed("'Tahoma Font Family (Tahoma Regular and Bold)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button1, Tahoma Font Family, Tahoma Regular and Bold ; Hit 'OK' button
        if ErrorLevel
            TestsFailed("Unable to hit 'OK' button in 'Tahoma Font Family (Tahoma Regular and Bold)' window.")
        else
        {
            WinWaitClose, Tahoma Font Family, Tahoma Regular and Bold, 5
            if ErrorLevel
                TestsFailed("'Tahoma Font Family (Tahoma Regular and Bold)' window failed to close despite 'OK' button being clicked.")
            else
                TestsOK("'Tahoma Font Family (Tahoma Regular and Bold)' window appeared, 'OK' button clicked and window closed.")
        }
    }
}


; Check if file exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    szFont = %A_WinDir%\Fonts\%MainAppFile%
    IfNotExist, %szFont%
        TestsFailed("Something went wrong, can't find '" szFont "'.")
    else
        TestsOK("The application has been installed, because '" szFont "' was found.")
}


RunAsAdmin() 
{
    ; http://www.autohotkey.com/community/viewtopic.php?t=50448
    Loop, %0%  ; For each parameter:
    {
        param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
        params .= A_Space . param
    }
    ShellExecute := A_IsUnicode ? "shell32\ShellExecute":"shell32\ShellExecuteA"

    if not A_IsAdmin
    {
        If A_IsCompiled
            DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
        Else
            DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
        ExitApp
    }
}