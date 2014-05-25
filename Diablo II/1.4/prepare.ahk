/*
 * Designed for Diablo II 1.4
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

TestName = prepare

; Test if the app is installed
TestsTotal++
RegRead, InstalledDir, HKEY_LOCAL_MACHINE, SOFTWARE\Blizzard Entertainment\Diablo II Shareware, InstallPath
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    if (InstalledDir = "")
        TestsFailed("Either registry contains empty string or we failed to read it.")
    else
    {
        ModuleExe = %InstalledDir%\Diablo II.exe
        TestsOK("")
    }
}


; Terminate application
if bContinue
{
    SplitPath, ModuleExe, ProcessExe
    bTerminateProcess(ProcessExe)
}


; Delete settings separately from RunApplication() in case we want to write our own settings
TestsTotal++
if bContinue
{
    IfExist, %InstalledDir%\Save
    {
        FileRemoveDir, %InstalledDir%\Save, 1
        if ErrorLevel
            TestsFailed("Unable to delete '" InstalledDir "\Save'.")
        else
            TestsOK("")
    }
    else
        TestsOK("")
}


; Test if can start application
RunApplication()
{
    global ModuleExe
    global TestName
    global TestsTotal
    global bContinue
    global ProcessExe

    TestsTotal++
    if bContinue
    {
        IfNotExist, %ModuleExe%
            TestsFailed("RunApplication(): Can NOT find '" ModuleExe "'.")
        else
        {
            Run, %ModuleExe%
            WinWaitActive, Diablo II,, 3
            if ErrorLevel
            {
                Process, Exist, %ProcessExe%
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("RunApplication(): Window 'Diablo II' failed to appear. No '" ProcessExe "' process detected.")
                else
                    TestsFailed("RunApplication(): Window 'Diablo II' failed to appear. '" ProcessExe "' process detected.")
            }
            else
            {
                WinGetPos, X, Y, Width, Height, Diablo II
                iTimeOut := 60
                while (iTimeOut > 0)
                {
                    WinGetPos, X, Y, Width, Height, Diablo II
                    if (Width != A_ScreenWidth) OR (Height != A_ScreenHeight)
                    {
                        Sleep, 100
                        iTimeOut--
                    }
                    else
                        break
                }

                if (Width != A_ScreenWidth) OR (Height != A_ScreenHeight)
                    TestsFailed("RunApplication(): Window size is not equal to screen size. Is '" Width "x" Height "', should be '" A_ScreenWidth "x" A_ScreenHeight "'. iTimeOut=" iTimeOut ".")
                else
                {
                    ; FIME
                    Sleep, 1500
                    Click, 395, 205 ; Close splash 
                    Sleep, 1500
                    Click, 395, 205 ; Close splash
                    Sleep, 1500
                    Click, 395, 205 ; Single player
                    Sleep, 1500
                    Click, 395, 205 ; Select player
                    Sleep, 1500
                    PlayerName = DiabloPlayer
                    SendInput, %PlayerName% ; Fill 'Character Name' field
                    clipboard = ; Clean the clipboard
                    SendInput, ^a ; Ctrl+A aka Select All. Select all text from 'Character Name' field
                    SendInput, ^c ; Ctrl+C aka Copy
                    ClipWait, 2
                    if ErrorLevel
                        TestsFailed("RunApplication(): The attempt to copy text onto the clipboard failed.")
                    else
                    {
                        IfNotInString, clipboard, %PlayerName%
                            TestsFailed("Unexpected clipboard content. Is '" clipboard "', should be '" PlayerName "'.")
                        else
                        {
                            TestsInfo("RunApplication(): Entered player name successfully. Sending ENTER to start the actuall game.")
                            SendInput, {ENTER}
                            iTimeOut := 15
                            while (iTimeOut > 0)
                            {
                                WinGetPos, X, Y, Width, Height, Diablo II
                                if ((Width = 640) AND (Height = 480))
                                    break
                                else
                                {
                                    Sleep, 1000
                                    iTimeOut--
                                }
                            }

                            if not ((Width = 640) AND (Height = 480))
                                TestsFailed("RunApplication(): unexpected 'Diablo II' window size. Is '" Width "x" Height "', should be '640x480' (iTimeOut=" iTimeOut ").")
                            else
                                TestsOK("RunApplication(): Game is up and running (iTimeOut=" iTimeOut ").")
                        }
                    }
                }
            }
        }
    }
}
