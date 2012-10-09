/*
 * Designed for LibreOffice 3.6.2
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

ModuleExe = %A_WorkingDir%\Apps\LibreOffice 3.6.2 Setup.msi
TestName = 1.install
MainAppFile = soffice.exe ; Mostly this is going to be process we need to look for

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
        RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1E85458A-9B00-443F-A187-2E06DBB15E43}, InstallLocation
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\LibreOffice 3.6
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %A_WinDir%\System32\MsiExec.exe /qn /norestart /x {1E85458A-9B00-443F-A187-2E06DBB15E43}
                WaitUninstallDone(UninstallerPath, 7)
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
            InstalledDir = %InstallLocation%
            IfNotExist, %InstalledDir%
            {
                TestsInfo("Got '" InstalledDir "' from registry and such path does not exist.")
                bContinue := true
            }
            else
            {
                UninstallerPath = %A_WinDir%\System32\MsiExec.exe /qn /norestart /x {1E85458A-9B00-443F-A187-2E06DBB15E43}
                WaitUninstallDone(UninstallerPath, 7)
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{1E85458A-9B00-443F-A187-2E06DBB15E43}
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\LibreOffice
        IfExist, %A_AppData%\IrfanView
        {
            FileRemoveDir, %A_AppData%\IrfanView, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\IrfanView'.")
        }

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


; Test if 'Windows Installer (Preparing to install...)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Windows Installer, Preparing to install..., 7
    if ErrorLevel
        TestsFailed("'Windows Installer (Preparing to install...)' window failed to appear.")
    else
    {
        TestsInfo("'Windows Installer (Preparing to install...)' window appeared, waiting for it to close.")
        
        iTimeOut := 45
        while iTimeOut > 0
        {
            IfWinActive, Windows Installer, Preparing to install...
            {
                WinWaitClose, Windows Installer, Preparing to install..., 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
        
        WinWaitClose, Windows Installer, Preparing to install..., 1
        if ErrorLevel
            TestsFailed("'Windows Installer (Preparing to install...)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'Windows Installer (Preparing to install...)' window closed (iTimeOut=" iTimeOut ").")
    }
}


; Test if 'Welcome' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, LibreOffice 3.6 - Installation Wizard, Welcome, 7
    if ErrorLevel
        TestsFailed("'LibreOffice 3.6 - Installation Wizard (Welcome)' window failed to appear.")
    else
    {
        ; Wait until Button1 caption is 'Next'
        szExpected := "&Next >"
        ControlGetText, szBtnCaption, Button1, LibreOffice 3.6 - Installation Wizard, Welcome
        iTimeOut := 40
        while iTimeOut > 0
        {
            ControlGetText, szBtnCaption, Button1, LibreOffice 3.6 - Installation Wizard, Welcome
            if szBtnCaption <> %szExpected%
            {
                iTimeOut--
                Sleep, 100
            }
            else
                break
        }

        ControlClick, Button1, LibreOffice 3.6 - Installation Wizard, Welcome ; Hit 'Next' button. We need all params here
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'LibreOffice 3.6 - Installation Wizard (Welcome)' window (iTimeOut=" iTimeOut ").")
        else
        {
            WinWaitClose, LibreOffice 3.6 - Installation Wizard, Welcome, 3
            if ErrorLevel
                TestsFailed("'LibreOffice 3.6 - Installation Wizard (Welcome)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'LibreOffice 3.6 - Installation Wizard (Welcome)' window appeared, 'Next' button clicked and window closed (iTimeOut=" iTimeOut ").")
        }
    }
}


; Test if 'Setup Type' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, LibreOffice 3.6 - Installation Wizard, Setup Type, 3
    if ErrorLevel
        TestsFailed("'LibreOffice 3.6 - Installation Wizard (Setup Type)' window failed to appear.")
    else
    {
        ControlClick, Button5 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'LibreOffice 3.6 - Installation Wizard (Setup Type)' window.")
        else
            TestsOK("'LibreOffice 3.6 - Installation Wizard (Setup Type)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, LibreOffice 3.6 - Installation Wizard, Ready to Install, 3
    if ErrorLevel
        TestsFailed("'LibreOffice 3.6 - Installation Wizard (Ready to Install)' window failed to appear.")
    else
    {
        ControlClick, Button1 ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'LibreOffice 3.6 - Installation Wizard (Ready to Install)' window.")
        else
            TestsOK("'LibreOffice 3.6 - Installation Wizard (Ready to Install)' window appeared and 'Install' button was clicked.")
    }
}


; Test if can get thru 'Installing' window
TestsTotal++
if bContinue
{
    WinWaitActive, LibreOffice 3.6 - Installation Wizard, Installing, 3
    if ErrorLevel
        TestsFailed("'LibreOffice 3.6 - Installation Wizard (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'Windows Installer (Preparing to install...)' window appeared, waiting for it to close.")
        
        iTimeOut := 120
        while iTimeOut > 0
        {
            IfWinActive, LibreOffice 3.6 - Installation Wizard, Installing
            {
                WinWaitClose, LibreOffice 3.6 - Installation Wizard, Installing, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
        
        WinWaitClose, LibreOffice 3.6 - Installation Wizard, Installing, 1
        if ErrorLevel
            TestsFailed("'LibreOffice 3.6 - Installation Wizard (Installing)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("''LibreOffice 3.6 - Installation Wizard (Installing)' window closed (iTimeOut=" iTimeOut ").")
    }
}


; Test if 'Completed' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, LibreOffice 3.6 - Installation Wizard, Completed, 3
    if ErrorLevel
        TestsFailed("'LibreOffice 3.6 - Installation Wizard (Completed)' window failed to appear.")
    else
    {
        ControlClick, Button1 ; Hit 'Finish' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Finish' button in 'LibreOffice 3.6 - Installation Wizard (Completed)' window.")
        else
        {
            WinWaitClose, LibreOffice 3.6 - Installation Wizard, Completed, 3
            if ErrorLevel
                TestsFailed("'LibreOffice 3.6 - Installation Wizard (Completed)' window failed to close despite 'Finish' button being clicked.")
            else
                TestsOK("'LibreOffice 3.6 - Installation Wizard (Completed)' window appeared, 'Finish' button clicked and window closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    ; No need to sleep, because we already waited for process to appear
    RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1E85458A-9B00-443F-A187-2E06DBB15E43}, InstallLocation
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        IfNotExist, %InstallLocation%program\%MainAppFile% ; Registry path contains trailing backslash
            TestsFailed("Something went wrong, can't find '" InstallLocation "program\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstallLocation "program\" MainAppFile "' was found.")
    }
}
