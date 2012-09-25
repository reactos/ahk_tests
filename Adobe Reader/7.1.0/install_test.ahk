/*
 * Designed for Adobe Reader 7.1.0
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

ModuleExe = %A_WorkingDir%\Apps\Adobe Reader 7.1.0 Setup.exe
TestName = 1.install
MainAppFile = AcroRd32.exe ; Mostly this is going to be process we need to look for

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
        RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{AC76BA86-7AD7-1033-7B44-A71000000002}, InstallLocation
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\Adobe\Acrobat 7.0
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %A_WinDir%\System32\MsiExec.exe /qn /norestart /x {AC76BA86-7AD7-1033-7B44-A71000000002}
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
                UninstallerPath = %A_WinDir%\System32\MsiExec.exe /qn /norestart /x {AC76BA86-7AD7-1033-7B44-A71000000002}
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Adobe\Acrobat Reader
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Adobe\Repair\Acrobat Reader
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\Adobe\Acrobat Reader
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{AC76BA86-7AD7-1033-7B44-A71000000002}
        IfExist, %A_AppData%\Adobe\Acrobat
        {
            FileRemoveDir, %A_AppData%\Adobe\Acrobat, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\Adobe\Acrobat'.")
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


; Test if 'Please wait' and Setup windows appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe Reader 7.1.0, Resume, 15
    if ErrorLevel
        TestsFailed("'Adobe Reader 7.1.0 (Resume)' window failed to appear.")
    else
    {
        ; 'Adobe Reader 7.1.0 (Resume)' window is in the background, so, WinWaitClose won't work here
        WinWaitActive, Adobe Reader 7.1.0 - Setup, Next, 50
        if ErrorLevel
            TestsFailed("First 'Adobe Reader 7.1.0 - Setup' window (Splash Screen) failed to appear.")
        else
        {
            TestsInfo("Active window is 'Adobe Reader 7.1.0 - Setup' window (Splash Screen).")
            Sleep, 650 ; Sleep is a must!
            ; One time Button1 is 'Next', next time it is 'Cancel'. So, check what button do we need to click
            szNextButtonText = Next
            ControlGetText, szButtonText, Button1, Adobe Reader 7.1.0 - Setup, Next
            if ErrorLevel
                TestsFailed("Unable to get 'Button1' text in 'Adobe Reader 7.1.0 - Setup (Next)' window.")
            else
            {
                TestsInfo("'Button1 (" szButtonText ")'")
                IfInString, szButtonText, %szNextButtonText%
                    szTheButton = Button1
                else
                {
                    ControlGetText, szButtonText, Button2, Adobe Reader 7.1.0 - Setup, Next
                    if ErrorLevel
                        TestsFailed("Unable to get 'Button2' text in 'Adobe Reader 7.1.0 - Setup (Next)' window.")
                    else
                    {
                        TestsInfo("'Button2 (" szButtonText ")'")
                        IfInString, szButtonText, %szNextButtonText%
                            szTheButton = Button2
                        else
                        {
                            ControlGetText, szButtonText, Button3, Adobe Reader 7.1.0 - Setup, Next
                            if ErrorLevel
                                TestsFailed("Unable to get 'Button3' text in 'Adobe Reader 7.1.0 - Setup (Next)' window.")
                            else
                            {
                                TestsInfo("'Button3 (" szButtonText ")'")
                                IfInString, szButtonText, %szNextButtonText%
                                    szTheButton = Button3
                                else
                                    TestsFailed("None of 3 button caption contained '" szNextButtonText "'.")
                            }
                        }
                    }
                }
            }

            if bContinue
            {
                ControlClick, %szTheButton%, Adobe Reader 7.1.0 - Setup, Next
                if ErrorLevel
                    TestsFailed("Unable to click '" szTheButton "(" szButtonText ")' in 'Adobe Reader 7.1.0 - Setup' splashscreen window.")
                else
                    TestsOK("'Adobe Reader 7.1.0 - Setup' window appeared and first '" szTheButton "(" szButtonText ")' button clicked.")
            }
        }
    } 
}


; Test if 'Adobe Reader 7.1.0 - Setup (Welcome to Setup)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe Reader 7.1.0 - Setup, Welcome to Setup, 3
    if ErrorLevel
        TestsFailed("'Adobe Reader 7.1.0 - Setup (Welcome to Setup)' window failed to appear.")
    else
    {
        TestsInfo("Active window is 'Adobe Reader 7.1.0 - Setup (Welcome to Setup)'.")
        Sleep, 650 ; Sleep is a must!
        ; One time Button1 is 'Next', next time it is 'Cancel'. So, check what button do we need to click
        szNextButtonText = Next
        ControlGetText, szButtonText, Button1, Adobe Reader 7.1.0 - Setup, Welcome to Setup
        if ErrorLevel
            TestsFailed("Unable to get 'Button1' text in 'Adobe Reader 7.1.0 - Setup (Welcome to Setup)' window.")
        else
        {
            TestsInfo("'Button1 (" szButtonText ")'")
            IfInString, szButtonText, %szNextButtonText%
                szTheButton = Button1
            else
            {
                ControlGetText, szButtonText, Button2, Adobe Reader 7.1.0 - Setup, Welcome to Setup
                if ErrorLevel
                    TestsFailed("Unable to get 'Button2' text in 'Adobe Reader 7.1.0 - Setup (Welcome to Setup)' window.")
                else
                {
                    TestsInfo("'Button2 (" szButtonText ")'")
                    IfInString, szButtonText, %szNextButtonText%
                        szTheButton = Button2
                    else
                    {
                        ControlGetText, szButtonText, Button3, Adobe Reader 7.1.0 - Setup, Welcome to Setup
                        if ErrorLevel
                            TestsFailed("Unable to get 'Button3' text in 'Adobe Reader 7.1.0 - Setup (Welcome to Setup)' window.")
                        else
                        {
                            TestsInfo("'Button3 (" szButtonText ")'")
                            IfInString, szButtonText, %szNextButtonText%
                                szTheButton = Button3
                            else
                                TestsFailed("None of 3 button caption contained '" szNextButtonText "'.")
                        }
                    }
                }
            }
        }

        if bContinue
        {
            ControlClick, %szTheButton%, Adobe Reader 7.1.0 - Setup, Welcome to Setup
            if ErrorLevel
                TestsFailed("Unable to hit '" szTheButton "(" szButtonText ")' button in 'Adobe Reader 7.1.0 - Setup (Welcome to Setup)' window.")
            else
                TestsOK("'Adobe Reader 7.1.0 - Setup (Welcome to Setup)' window appeared and '" szTheButton "(" szButtonText ")' button was clicked.")
        }
    }
}


; Test if 'Adobe Reader 7.1.0 - Setup (Destination Folder)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe Reader 7.1.0 - Setup, Destination Folder, 7
    if ErrorLevel
        TestsFailed("'Adobe Reader 7.1.0 - Setup (Destination Folder)' window failed to appear.")
    else
    {
        ControlClick, Button1, Adobe Reader 7.1.0 - Setup, Destination Folder
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in ' Adobe Reader 7.1.0 - Setup (Destination Folder)' window.")
        else
            TestsOK("'Adobe Reader 7.1.0 - Setup (Destination Folder)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Adobe Reader 7.1.0 - Setup (Ready to Install)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe Reader 7.1.0 - Setup, Ready to Install, 3
    if ErrorLevel
        TestsFailed("'Adobe Reader 7.1.0 - Setup (Ready to Install)' window failed to appear.")
    else
    {
        ControlClick, Button1, Adobe Reader 7.1.0 - Setup, Ready to Install ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Adobe Reader 7.1.0 - Setup (Ready to Install)' window.")
        else
            TestsOK("'Adobe Reader 7.1.0 - Setup (Ready to Install)' window appeared and 'Install' button was clicked.")
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe Reader 7.1.0 - Setup, Installing Adobe, 7
    if ErrorLevel
        TestsFailed("'Adobe Reader 7.1.0 - Setup (Installing Adobe)' window failed to appear.")
    else
    {
        TestsInfo("'Adobe Reader 7.1.0 - Setup (Installing Adobe)' window appeared, waiting for it to close.")
        WinWaitClose, Adobe Reader 7.1.0 - Setup, Installing Adobe, 85
        if ErrorLevel
            TestsFailed("'Adobe Reader 7.1.0 - Setup (Installing Adobe)' window failed to dissapear.")
        else
        {
            WinWaitActive, Adobe Reader 7.1.0 - Setup, Setup Completed, 3
            if ErrorLevel
                TestsFailed("'Adobe Reader 7.1.0 - Setup (Setup Completed)' window failed to appear.")
            else
            {
                ControlClick, Button1, Adobe Reader 7.1.0 - Setup, Setup Completed ; Hit 'Finish' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Finish' button in 'Adobe Reader 7.1.0 - Setup (Setup Completed)' window.")
                else
                {
                    WinWaitClose, Adobe Reader 7.1.0 - Setup, Setup Completed, 3
                    if ErrorLevel
                        TestsFailed("'Adobe Reader 7.1.0 - Setup (Setup Completed)' window failed to close despite 'Finish' button being clicked.")
                    else
                        TestsOK("'Adobe Reader 7.1.0 - Setup (Setup Completed)' window closed after 'Finish' button was clicked.")
                }
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{AC76BA86-7AD7-1033-7B44-A71000000002}, InstallLocation
    if not ErrorLevel
    {
        IfExist, %InstallLocation%%MainAppFile% ; Registry path contains trailing backslash
            TestsOK("The application has been installed, because '" InstallLocation MainAppFile "' was found.")
        else
            TestsFailed("Something went wrong, can't find '" InstallLocation MainAppFile "'.")
    }
    else
        TestsFailed("Either we can't read from registry or data doesn't exist.")
}
