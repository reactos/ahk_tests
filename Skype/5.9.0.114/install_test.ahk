/*
 * Designed for Skype v5.9 (5.9.0.114)
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

ModuleExe = %A_WorkingDir%\Apps\Skype 5.9.0.114 Setup.exe ; Not fully offline installer, is it?
TestName = 1.install
MainAppFile = Skype.exe ; Mostly this is going to be process we need to look for

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
        RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{EE7257A2-39A2-4D2F-9DAC-F9F25B8AE1D8}, InstallLocation
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\Skype
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %A_WinDir%\System32\MsiExec.exe /qn /norestart /x {EE7257A2-39A2-4D2F-9DAC-F9F25B8AE1D8}
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
            InstalledDir = %InstallLocation%
            IfNotExist, %InstalledDir%
            {
                TestsInfo("Got '" InstalledDir "' from registry and such path does not exist.")
                bContinue := true
            }
            else
            {
                UninstallerPath = %A_WinDir%\System32\MsiExec.exe /qn /norestart /x {EE7257A2-39A2-4D2F-9DAC-F9F25B8AE1D8}
                WaitUninstallDone(UninstallerPath, 3)
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
        RegDelete, HKEY_LOCAL_MACHINE, SYSTEM\ControlSet001\Control\Session Manager, PendingFileRenameOperations ; Delete or 'A previous program installation' window will pop-up
        RegDelete, HKEY_CLASSES_ROOT, Installer\Products\7692FC6BE18C0C0489510C7547EF1F02
        RegDelete, HKEY_CLASSES_ROOT, Installer\Products\2A7527EE2A93F2D4D9CA9F2FB5A81E8D ; Delete this or 'Updating Skype' window will show up
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Skype
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\Skype ; Delete or 'Installing Skype (Install Skype Click to Call)' window will not show up
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{EE7257A2-39A2-4D2F-9DAC-F9F25B8AE1D8}
        IfExist, %A_AppData%\Skype
        {
            FileRemoveDir, %A_AppData%\Skype, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\Skype'.")
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


; Test if 'Installing Skype (More Options)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installing Skype, More Options, 20
    if ErrorLevel
    {
        IfWinActive, Updating Skype
            TestsFailed("We probably failed to delete 'HKCR\Installer\Products\2A7527EE2A93F2D4D9CA9F2FB5A81E8D'.")
        else
            TestsFailed("'Installing Skype (More Options)' window failed to appear.")
    }
    else
    {
        ControlClick, TButton1, Installing Skype, More Options ; Hit 'I agree - next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'I agree - next' button in 'Installing Skype (More Options)' window.")
        else
        {
            WinWaitClose, Installing Skype, More Options, 3
            if ErrorLevel
                TestsFailed("'Installing Skype (More Options)' window failed to close despite 'I agree - next' button being clicked.")
            else
                TestsOK("'Installing Skype (More Options)' window appeared and 'I agree - next' button was clicked.")
        }
    }
}


; Test if 'Installing Skype (Install Skype Click to Call)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installing Skype, Install Skype Click to Call, 3
    if ErrorLevel
        TestsFailed("'Installing Skype (Install Skype Click to Call)' window failed to appear. Unable to delete HKCU\Software\Skype?.")
    else
    {
        Control, Uncheck,, TCheckBox1, Installing Skype, Install Skype Click to Call ; Uncheck 'Install Skype Click to Call' checkbox
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Install Skype Click to Call' checkobx in 'Installing Skype (Install Skype Click to Call)' window.")
        else
        {
            ControlClick, TButton1, Installing Skype, Install Skype Click to Call ; Hit 'Continue' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Continue' button in 'Installing Skype (Install Skype Click to Call)' window.")
            else
                TestsOK("'Installing Skype (Install Skype Click to Call)' window appeared, checkbox 'Install Skype Click to Call' unchecked and 'Continue' button was clicked.")
        }
    }
}


; Test if 'Installing Skype (Install the Bing Bar)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installing Skype, Install the Bing Bar, 3
    if ErrorLevel
        TestsFailed("'Installing Skype (Install the Bing Bar)' window failed to appear.")
    else
    {
        Control, Uncheck,, TCheckBox2, Installing Skype, Install the Bing Bar ; Uncheck 'Install the Bing Bar' checkbox
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Install the Bing Bar' checkobx in 'Installing Skype (Install the Bing Bar)' window.")
        else
        {
            ControlClick, TButton1, Installing Skype, Install the Bing Bar ; Hit 'Continue' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Continue' button in 'Installing Skype (Install the Bing Bar)' window.")
            else
                TestsOK("'Installing Skype (Install the Bing Bar)' window appeared, checkbox 'Install the Bing Bar' unchecked and 'Continue' button clicked.")
        }
    }
}


; Test if 'Installing Skype' window can close
TestsTotal++
if bContinue
{
    iTimeOut := 120
    while iTimeOut > 0
    {
        IfWinActive, Installing Skype
        {
            WinWaitClose, Installing Skype,,1
            iTimeOut--
        }
        else
            break ; exit the loop if something poped-up
    }

    WinWaitClose, Installing Skype,,1
    if ErrorLevel
        TestsFailed("'Installing Skype' window failed to close (iTimeOut=" iTimeOut ").")
    else
    {
        Process, wait, %MainAppFile%, 7
        NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
        if NewPID = 0
            TestsFailed("'Installing Skype' window closed (iTimeOut=" iTimeOut "), but '" MainAppFile "' process failed to appear.")
        else
        {
            Process, Close, %MainAppFile%
            Process, WaitClose, %MainAppFile%, 5
            if ErrorLevel ; The PID still exists
                TestsFailed("Unable to terminate '" MainAppFile "' process.")
            else
                TestsOK("'Installing Skype' window closed (iTimeOut=" iTimeOut "), '" MainAppFile "' process appeared and we terminated it.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{EE7257A2-39A2-4D2F-9DAC-F9F25B8AE1D8}, InstallLocation
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        IfNotExist, %InstallLocation%Phone\%MainAppFile% ; Registry string contains trailing backslash
            TestsFailed("Something went wrong, can't find '" InstallLocation "Phone\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstallLocation "Phone\" MainAppFile "' was found.")
    }
}