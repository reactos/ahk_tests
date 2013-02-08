/*
 * Designed for Super Finder XT 1.6.3.2
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

TestName = prepare

; Test if the app is installed
TestsTotal++
RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Super Finder XT_is1, UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    UninstallerPath := ExeFilePathNoParam(UninstallerPath) ; Get rid of quotes
    SplitPath, UninstallerPath,, InstalledDir
    if (InstalledDir = "")
        TestsFailed("Either registry contains empty string or we failed to read it.")
    else
    {
        ModuleExe = %InstalledDir%\SuperFinder.exe
        TestsOK("")
    }
}


; Terminate application
TestsTotal++
if bContinue
{
    SplitPath, ModuleExe, ProcessExe
    Process, Close, %ProcessExe%
    Process, WaitClose, %ProcessExe%, 4
    if ErrorLevel
        TestsFailed("Unable to terminate '" ProcessExe "' process.")
    else
        TestsOK("")
}


; Delete settings separately from RunApplication() in case we want to write our own settings
RegDelete, HKEY_CURRENT_USER, Software\FreeSoftLand


; Test if can start application
RunApplication(PathToFile)
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
            TestsFailed("Can NOT find '" ModuleExe "'.")
        else
        {
            Run, %ModuleExe%
            WinWaitActive, ahk_class TLangForm,,7 ; AHK doesn't detect window caption nor 'OK' button control name.
            if ErrorLevel
            {
                Process, Exist, %ProcessExe%
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("Window class 'TLangForm' (select your language) failed to appear. No '" ProcessExe "' process detected.")
                else
                    TestsFailed("Window class 'TLangForm' (select your language) failed to appear. '" ProcessExe "' process detected.")
            }
            else
            {
                SendInput, {ENTER} ; Choose language and hit 'OK' button.
                WinWaitClose, ahk_class TLangForm,,3
                if ErrorLevel
                    TestsFailed("Window class 'TLangForm' (select your language) failed to close despite ENTER was sent.")
                else
                {
                    WinWaitActive, ahk_class TWizardForm,,3 ; 'New Features Wizard' window
                    if ErrorLevel
                        TestsFailed("Window class 'TWizardForm' (New Features Wizard) failed to appear.")
                    else
                    {
                        SendInput, !c ; Alt+C aka hit 'Cancel' button in 'New Features Wizard' window
                        WinWaitClose, ahk_class TWizardForm,,3
                        if ErrorLevel
                            TestsFailed("Window class 'TWizardForm' (New Features Wizard) failed to close despite Alt+C was sent.")
                        else
                        {
                            WinWaitActive, ahk_class TMainForm,,3 ; 'Super Finder XT' is up and running
                            if ErrorLevel
                                TestsFailed("Window class 'TMainForm' (Super Finder XT) failed to appear.")
                            else
                            {
                                WinMaximize, ahk_class TMainForm
                                TestsOK("")
                            }
                        }
                    }
                }
            }
        }
    }
}
