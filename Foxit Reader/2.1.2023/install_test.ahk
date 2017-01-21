/*
 * Designed for Foxit Reader 2.1.2023
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

ModuleExe = %A_WorkingDir%\Apps\Foxit Reader 2.1.2023 Setup.exe
TestName = 1.install
MainAppFile = Foxit Reader.exe ; Mostly this is going to be process we need to look for

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    Process, Close, %MainAppFile% ; Teminate process
    Process, WaitClose, %MainAppFile%, 4
    if ErrorLevel ; The PID still exists.
        TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
    else
    {
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Foxit Reader, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %A_ProgramFiles%\Foxit Software\Foxit Reader
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not

                IfNotExist, %A_ProgramFiles%\Foxit Software\Foxit Reader ; No silent switch, so, delete
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\Foxit Software\Foxit Reader, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" A_ProgramFiles "\Foxit Software\Foxit Reader' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
                bContinue := true
            else
            {
                IfNotExist, %InstalledDir%
                    bContinue := true
                else
                {
                    FileRemoveDir, %InstalledDir%, 1 ; No silent switch, so, delete
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
                    else
                        bContinue := true
                }
            }
        }
    }

    IfNotExist, %A_WinDir%\System32\mfc42.dll
        TestsFailed("'" A_WinDir "\System32\mfc42.dll' is required, but it was not found (VC++6).")
    else
        if bContinue
        {
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Foxit Software
            RegDelete, HKEY_CURRENT_USER, SOFTWARE\Foxit Software
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Foxit Reader

            if bHardcoded
                TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
            else
                TestsOK("Either there was no previous versions or we succeeded removing it using data from registry.")
            Run %ModuleExe%
        }
}



; Test if 'Setup will install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Foxit Reader Install Wizard, Setup will install, 8
    if ErrorLevel
        TestsFailed("'Foxit Reader Install Wizard (Setup will install)' window failed to appear.")
    else
    {
        ControlClick, Button1, Foxit Reader Install Wizard, Setup will install
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' in 'Foxit Reader Install Wizard (Setup will install)' window.")
        else
        {
            WinWaitClose, Foxit Reader Install Wizard, Setup will install, 3
            if ErrorLevel
                TestsFailed("'Foxit Reader Install Wizard (Setup will install)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'Foxit Reader Install Wizard (Setup will install)' window appeared and 'Next' button was clicked.")
        }
    }
}


; Test if 'New features' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Foxit Reader Install Wizard, New features, 3
    if ErrorLevel
        TestsFailed("'Foxit Reader Install Wizard (New features)' window failed to appear.")
    else
    {
        ControlClick, Button1, Foxit Reader Install Wizard, New features
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' in 'Foxit Reader Install Wizard (New features)' window. ")
        else
            TestsOK("'Foxit Reader Install Wizard (New features)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Please read the license' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Foxit Reader Install Wizard, Please read the license, 3
    if ErrorLevel
        TestsFailed("'Foxit Reader Install Wizard (Please read the license)' window failed to appear.")
    else
    {
        ControlClick, Button1, Foxit Reader Install Wizard, Please read the license ; Hit 'I agree' button
        if ErrorLevel
            TestsFailed("Unable to hit 'I agree' button in 'Foxit Reader Install Wizard (Please read the license)' window.")
        else
            TestsOK("'Foxit Reader Install Wizard (Please read the license)' window appeared and 'I agree' button was clicked.")
    }
}


; Test if 'installation type' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Foxit Reader Install Wizard, installation type, 3
    if ErrorLevel
        TestsFailed("'Foxit Reader Install Wizard (installation type)' window failed to appear.")
    else
    {
        ControlClick, Button1, Foxit Reader Install Wizard, installation type ; Hit 'Default' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' in 'Foxit Reader Install Wizard (installation type)' window.")
        else
            TestsOK("'Foxit Reader Install Wizard (installation type)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Click Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Foxit Reader Install Wizard, Click Install, 3
    if ErrorLevel
        TestsFailed("'Foxit Reader Install Wizard (Click Install)' window failed to appear.")
    else
    {
        ControlClick, Button1, Foxit Reader Install Wizard, Click Install ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' in 'Foxit Reader Install Wizard (Click Install)' window.")
        else
            TestsOK("'Foxit Reader Install Wizard (Click Install)' window appeared and 'Next' button was clicked.")
    }   
}


; Test if 'Setup has successfully installed' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Foxit Reader Install Wizard, Setup has successfully installed, 7
    if ErrorLevel
        TestsFailed("'Foxit Reader Install Wizard (Setup has successfully installed)' window failed to appear.")
    else
    {
        ControlClick, Button3, Foxit Reader Install Wizard, Setup has successfully installed ; Uncheck 'Make it your default PDF reader'
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Make it your default PDF reader' checkbox in 'Foxit Reader Install Wizard (Setup has successfully installed)' window.")
        else
        {
            ControlClick, Button2, Foxit Reader Install Wizard, Setup has successfully installed ; Uncheck 'Run Foxit Reader'
            if ErrorLevel
                TestsFailed("Unable to uncheck 'Run Foxit Reader' checkbox in 'Foxit Reader Install Wizard (Setup has successfully installed)' window.")
            else
            {
                Sleep,500
                ControlGet, bChecked, Checked,, Button2
                if bChecked = 1
                    TestsFailed("'Run Foxit Reader' checkbox in 'Foxit Reader Install Wizard (Setup has successfully installed)' window reported as unchecked, but further inspection proves that it was still checked.")
                else
                {
                    ControlClick, Button1, Foxit Reader Install Wizard, Setup has successfully installed ; Hit 'Finish'
                    if ErrorLevel
                        TestsFailed("Unable to click 'Finish' in 'Foxit Reader Install Wizard (Setup has successfully installed)' window.")
                    else
                    {
                        WinWaitClose, Foxit Reader Install Wizard, Setup has successfully installed, 3
                        if ErrorLevel
                            TestsFailed("'Foxit Reader Install Wizard (Setup has successfully installed)' failed to close despite 'Finish' was clicked.")
                        else
                            TestsOK("'Foxit Reader Install Wizard (Setup has successfully installed)' window appeared, checkboxes unchecked, 'Finish' button clicked, window closed.")
                    }
                }
            }
        }
    }
}


; Check if program exists in program files
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Foxit Reader, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
