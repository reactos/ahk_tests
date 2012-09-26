/*
 * Designed for Filzip 3.0.6
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

ModuleExe = %A_WorkingDir%\Apps\Filzip 3.0.6 Setup.exe
TestName = 1.install
MainAppFile = Filzip.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Filzip 3.0.6.93_is1, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\Filzip
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\unins000.exe /SILENT
                WaitUninstallDone(UninstallerPath, 3)
                if bContinue
                {
                    IfNotExist, %szDefaultDir% ; Uninstaller might delete the dir
                    {
                        TestsInfo("Uninstaller deleted hardcoded path: '" szDefaultDir "'.")
                        bContinue := true
                    }
                    else
                    {
                        FileRemoveDir, %szDefaultDir%, 1
                        if ErrorLevel
                            TestsFailed("Unable to delete hardcoded path '" szDefaultDir "' ('" MainAppFile "' process is reported as terminated).'")
                        else
                        {
                            TestsInfo("Succeeded deleting hardcoded path, because uninstaller did not: '" szDefaultDir "'.")
                            bContinue := true
                        }
                    }
                }
            }
        }
        else
        {
            UninstallerPath := ExeFilePathNoParam(UninstallerPath)
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
            {
                TestsInfo("Got '" InstalledDir "' from registry and such path does not exist.")
                bContinue := true
            }
            else
            {
                UninstallerPath = %UninstallerPath% /SILENT
                WaitUninstallDone(UninstallerPath, 3) ; Child '_iu14D2N.tmp'
                if bContinue
                {
                    IfNotExist, %InstalledDir%
                    {
                        TestsInfo("Uninstaller deleted path (registry data): '" InstalledDir "'.")
                        bContinue := true
                    }
                    else
                    {
                        FileRemoveDir, %InstalledDir%, 1 ; Uninstaller leaved the path for us to delete, so, do it
                        if ErrorLevel
                            TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
                        else
                        {
                            TestsInfo("Succeeded deleting path (registry data), because uninstaller did not: '" InstalledDir "'.")
                            bContinue := true
                        }
                    }
                }
            }
        }
    }

    if bContinue
    {
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\Filzip
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Filzip 3.0.6.93_is1

        if bContinue
        {
            if bHardcoded
                TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
            else
                TestsOK("Either there was no previous versions or we succeeded removing it using data from registry.")
            Run %ModuleExe%
        }
    }
}


; Test if 'Select Setup Language' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Select Setup Language, Select the language, 7
    if ErrorLevel
        TestsFailed("'Select Setup Language (Select the language)' window failed to appear.")
    else
    {
        ControlClick, TButton1, Select Setup Language, Select the language ; hit 'OK' button
        if ErrorLevel
            TestsFailed("Unable to hit 'OK' button in 'Select Setup Language (Select the language)' window.")
        else
        {
            WinWaitClose, Select Setup Language, Select the language, 3
            if ErrorLevel
                TestsFailed("'Select Setup Language (Select the language)' window failed to close despite 'OK' button being clicked.")
            else
                TestsOK("'Select Setup Language (Select the language)' window appeared, 'OK' button clicked and window closed.")
        }
    }
}


; Test if 'Welcome' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Welcome, 7
    if ErrorLevel
        TestsFailed("'Setup - Filzip (Welcome)' window failed to appear.")
    else
    {
        ControlClick, TButton1, Setup - Filzip, Welcome ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Filzip (Welcome)' window.")
        else
            TestsOK("'Setup - Filzip (Welcome)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, License Agreement, 3
    if ErrorLevel
        TestsFailed("'Setup - Filzip (License Agreement)' window failed to appear.")
    else
    {
        Control, Check,, TRadioButton1, Setup - Filzip, License Agreement ; Check 'I accept the agreement' radio button
        if ErrorLevel
            TestsFailed("Unable to check 'I accept the agreement' radiobutton in 'Setup - Filzip (License Agreement)' window.")
        else
        {
            ControlClick, TButton2, Setup - Filzip, License Agreement ; Hit 'Next' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Next' button in 'Setup - Filzip (License Agreement)' window.")
            else
                TestsOK("'Setup - Filzip (License Agreement)' window appeared, radiobutton 'I accept' checked and 'Next' button was clicked.")
        }
    }
}


; Test if 'Select Destination Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Select Destination Location, 3
    if ErrorLevel
        TestsFailed("'Setup - Filzip (Select Destination Location)' window failed to appear.")
    else
    {
        ControlClick, TButton3, Setup - Filzip, Select Destination Location ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Filzip (Select Destination Location)' window.")
        else
            TestsOK("'Setup - Filzip (Select Destination Location)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Select Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Select Components, 3
    if ErrorLevel
        TestsFailed("'Setup - Filzip (Select Components)' window failed to appear.")
    else
    {
        ControlClick, TButton3, Setup - Filzip, Select Components ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Filzip (Select Components)' window.")
        else
            TestsOK("'Setup - Filzip (Select Components)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Select Start Menu Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Select Start Menu Folder, 3
    if ErrorLevel
        TestsFailed("'Setup - Filzip (Select Start Menu Folder)' window failed to appear.")
    else
    {
        ControlClick, TButton4, Setup - Filzip, Select Start Menu Folder ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Filzip (Select Start Menu Folder)' window.")
        else
            TestsOK("'Setup - Filzip (Select Start Menu Folder)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Ready to Install, 3
    if ErrorLevel
        TestsFailed("'Setup - Filzip (Ready to Install)' window failed to appear.")
    else
    {
        ControlClick, TButton4, Setup - Filzip, Ready to Install ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Setup - Filzip (Ready to Install)' window.")
        else
            TestsOK("'Setup - Filzip (Ready to Install)' window appeared and 'Install' was clicked.")
    }
}


; Test if can get trhu 'Installing' window
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Installing, 3
    if ErrorLevel
        TestsFailed("'Setup - Filzip (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'Setup - Filzip (Installing)' window appeared, waiting for it to close.")
        WinWaitClose, Setup - Filzip, Installing, 15
        if ErrorLevel
            TestsFailed("'Setup - Filzip (Installing)' window failed to close.")
        else
            TestsOK("'Setup - Filzip (Installing)' window went away.")
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Completing, 3
    if ErrorLevel
        TestsFailed("'Setup - Filzip (Completing)' window failed to appear.")
    else
    {
        Sleep, 700 ; Sleep ultil there is better way to uncheck control
        SendInput, {SPACE}{DOWN}{SPACE} ; Uncheck 'View readme.txt' and 'Run Filzip' //FIXME: is there a better way? Control, Uncheck won't work here
        ControlClick, TButton4, Setup - Filzip, Completing ; Hit 'Finish' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Finish' button in 'Setup - Filzip (Completing)' window.")
        else
        {
            WinWaitClose, Setup - Filzip, Completing
            if ErrorLevel
                TestsFailed("'Setup - Filzip (Completing)' window failed to close despite 'Finish' button being clicked.")
            else
            {
                Process, Wait, %MainAppFile%, 3
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID <> 0
                {
                    TestsFailed("Process '" MainAppFile "' appeared despite 'Run Filzip' being reported as unchecked.")
                    Process, Close, %MainAppFile%
                    Process, Close, Notepad.exe
                }
                else
                    TestsOK("'Setup - Filzip (Completing)' window appeared, 'View readme.txt', 'Run Filzip' were unchecked, 'Finish' clicked and window closed.")
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Filzip 3.0.6.93_is1, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        StringReplace, UninstallerPath, UninstallerPath, `",, All ; The Filzip uninstaller path is quoted, remove quotes
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
