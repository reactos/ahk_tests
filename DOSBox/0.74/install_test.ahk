/*
 * Designed for DOSBox 0.74
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

ModuleExe = %A_WorkingDir%\Apps\DOSBox 0.74 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("Can NOT find '" ModuleExe "'")
else
{
    Process, Close, dosbox.exe
    Process, WaitClose, dosbox.exe, 4
    if ErrorLevel
        TestsFailed("Process 'dosbox.exe' failed to close.")
    else
    {
        ; At least for 0.74 installer doesn't write any uninstall information to registry
        InstallLocation = %A_ProgramFiles%\DOSBox ; Not default!
        IfNotExist, %InstallLocation%
            bContinue := true ; No previous versions detected.
        else
        {
            IfExist, %InstallLocation%\uninstall.exe
                RunWait, %InstallLocation%\uninstall.exe /S ; Silently uninstall it

            Sleep, 2500
            IfExist, %InstallLocation%
                FileRemoveDir, %InstallLocation%, 1

            Sleep, 1000
            IfExist, %InstallLocation%
                TestsFailed("Previous version detected and failed to delete '" InstallLocation "'. 'dosbox.exe' process not detected.")
            else
                bContinue := true
        }
    }

    if bContinue
    {
        TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
        Run %ModuleExe%
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, DOSBox 0.74 Installer Setup: License Agreement, DOSBox v0.74 License, 7
    if ErrorLevel
        TestsFailed("'DOSBox 0.74 Installer Setup: License Agreement' window with 'Next' button failed to appear.")
    else
    {
        ControlClick, Button2, DOSBox 0.74 Installer Setup: License Agreement, DOSBox v0.74 License ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'License Agreement' window.")
        else
            TestsOK("'DOSBox 0.74 Installer Setup: License Agreement' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Installation Options' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, DOSBox 0.74 Installer Setup: Installation Options, Select components, 7
    if ErrorLevel
        TestsFailed("'DOSBox 0.74 Installer Setup: Installation Options' window with 'Next' button failed to appear.")
    else
    {
        ControlClick, Button2, DOSBox 0.74 Installer Setup: Installation Options, Select components ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'DOSBox 0.74 Installer Setup: Installation Options' window.")
        else
            TestsOK("'DOSBox 0.74 Installer Setup: Installation Options' appeared and 'Next' button was clicked.")
    }
}


; Test if 'Installation Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, DOSBox 0.74 Installer Setup: Installation Folder, This will install, 7
    if ErrorLevel
        TestsFailed("'DOSBox 0.74 Installer Setup: Installation Folder' window with 'Install' button failed to appear.")
    else
    {
        ControlSetText, Edit1, %A_ProgramFiles%\DOSBox, DOSBox 0.74 Installer Setup: Installation Folder, This will install ; Change installation directory
        if ErrorLevel
            TestsFailed("Unable to set installation folder to '" A_ProgramFiles "\DOSBox' in 'Installation Folder' window.")
        else
        {
            ControlClick, Button2, DOSBox 0.74 Installer Setup: Installation Folder, This will install ; Hit 'Install' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Install' button in 'DOSBox 0.74 Installer Setup: Installation Folder' window.")
            else
                TestsOK("'DOSBox 0.74 Installer Setup: Installation Folder' appeared and 'Install' button was clicked.")
        }
    }
}


; Test if 'Completed' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, DOSBox 0.74 Installer Setup: Completed, Completed, 7
    if ErrorLevel
        TestsFailed("'DOSBox 0.74 Installer Setup: Completed' window with 'Close' button failed to appear.")
    else
    {
        ControlClick, Button2, DOSBox 0.74 Installer Setup: Completed, Completed ; Hit 'Close' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Close' button in 'DOSBox 0.74 Installer Setup: Completed' window.")
        else
        {
            WinWaitClose, DOSBox 0.74 Installer Setup: Completed, Completed, 5
            if ErrorLevel
                TestsFailed("'DOSBox 0.74 Installer Setup: Completed' failed to close despite 'Close' button being clicked.")
            else
                TestsOK("'DOSBox 0.74 Installer Setup: Completed' appeared, 'Close' button clicked and window closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    IfNotExist, %InstallLocation%\dosbox.exe
        TestsFailed("Something went wrong, can't find '" InstallLocation "\dosbox.exe'.")
    else
        TestsOK("The application has been installed, because '" InstallLocation "\dosbox.exe' was found.")
}
