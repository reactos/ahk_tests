/*
 * Designed for SDL Mixer 1.2.12
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

ModuleExe = %A_WorkingDir%\Apps\SDL Mixer 1.2.12 Setup.exe
TestName = 1.install
MainAppFile = SDL_mixer.dll

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("Can NOT find '" ModuleExe "'")
else
{
    InstallLocation = %A_WinDir%\system32
    IfNotExist, %InstallLocation%\%MainAppFile%
        bContinue := true ; No previous versions detected.
    else
    {
        FileDelete, %InstallLocation%\%MainAppFile%
        if ErrorLevel
            TestsFailed("Previous version detected and failed to delete '" InstallLocation "\" MainAppFile "'.")
        else
            bContinue := true
    }
    
    if bContinue
    {
        TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
        Run %ModuleExe%
    }
}


; Test if 'WinRAR self-extracting archive (Extract)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, WinRAR self-extracting archive, Extract, 5
    if ErrorLevel
        TestsFailed("'WinRAR self-extracting archive' window with 'Extract' button failed to appear.")
    else
    {
        clipboard = ; Empty the clipboard
        SendInput, ^c ; Path field is focused by default and all text is selected. Copy it to clipboard
        ClipWait, 2
        if ErrorLevel
            TestsFailed("The attempt to copy path onto the clipboard failed.")
        else
        {
            if clipboard <> %InstallLocation% ; archive is made to extract to %WinDir%\system32
                TestsFailed("Paths do NOT match. Expected '" InstallLocation "', got '" clipboard "'.")
            else
            {
                ControlClick, Button2, WinRAR self-extracting archive, Extract ; Hit 'Extract' button
                if ErrorLevel
                    TestsFailed("Unable to click 'Extract' in 'WinRAR self-extracting archive' window.")
                else
                {
                    WinWaitClose, WinRAR self-extracting archive, Extract, 3
                    if ErrorLevel
                        TestsFailed("'WinRAR self-extracting archive' window failed to close despite 'Extract' button being clicked.")
                    else
                        TestsOK("'WinRAR self-extracting archive' window appeared, 'Extract' button clicked, window closed.")
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
    WinWaitActive, WinRAR self-extracting archive, Extracting, 3
    if ErrorLevel
    {
        ; Sometimes files are extracted so fast that AHK doesn't detect the window
        IfNotExist, %InstallLocation%\%MainAppFile%
            TestsFailed("'WinRAR self-extracting archive (Extracting)' window failed to appear (SetTitleMatchMode=2) and '" InstallLocation "\" MainAppFile "' doesnt exist.")
        else
            TestsOK("AHK unabled to detect 'WinRAR self-extracting archive (Extracting)' window, but '" InstallLocation "\" MainAppFile "' exist.")
    }
    else
    {
        TestsInfo("'Extracting' window appeared, waiting for it to close.")
        WinWaitClose, WinRAR self-extracting archive, Extracting, 3
        if ErrorLevel
            TestsFailed("'WinRAR self-extracting archive (Extracting)' window failed to close.")
        else
            TestsOK("'WinRAR self-extracting archive (Extracting)' window went away.")
    }
}


; Check if program exist
TestsTotal++
if bContinue
{
    IfExist, %InstallLocation%\%MainAppFile%
        TestsOK("The application has been installed, because '" InstallLocation "\" MainAppFile "' was found.")
    else
        TestsFailed("Something went wrong, can't find '" InstallLocation "\" MainAppFile "'.")
}
