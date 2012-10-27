/*
 * Designed for Samba-TNG 0.5-RC1
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

ModuleExe = %A_WorkingDir%\Apps\Samba-TNG_0.5-RC1_Setup.exe
TestName = 1.install

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("Can NOT find '" ModuleExe "'")
else
{
    ; Get rid of other versions
    IfExist, C:\ReactOS\Samba-TNG
    {
        FileRemoveDir, C:\ReactOS\Samba-TNG, 1
        if ErrorLevel
            TestsFailed("Can NOT delete existing 'C:\ReactOS\Samba-TNG'.")
        else
            bContinue := true
    }
    else
        bContinue := true
    
    if bContinue
    {
        TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
        Run %ModuleExe%
    }
}


; Test if '7-Zip self-extracting archive' window with 'Extract' button appeared
TestsTotal++
if bContinue
{
    WinWaitActive, 7-Zip self-extracting archive, Extract, 5
    if ErrorLevel
        TestsFailed("'7-Zip self-extracting archive' window with 'Extract' button failed to appear.")
    else
    {
        ControlSetText, Edit1, C:\ReactOS\Samba-TNG, 7-Zip self-extracting archive, Extract ; Path
        if ErrorLevel
            TestsFailed("Unable to change 'Edit1' control text to 'C:\ReactOS\Samba-TNG'.")
        else
        {
            ControlClick, Button2, 7-Zip self-extracting archive, Extract ; Hit 'Extract' button
            if ErrorLevel
                TestsFailed("Unable to click 'Extract' in '7-Zip self-extracting archive' window.")
            else
            {
                WinWaitClose, 7-Zip self-extracting archive, Extract, 4
                if ErrorLevel
                    TestsFailed("'7-Zip self-extracting archive' window failed to close despite 'Extract' button being clicked.")
                else
                    TestsOK("'7-Zip self-extracting archive' window appeared, 'Extract' button clicked, window closed.")
            }
        }
    }
}


TestsTotal++
if bContinue
{
    SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
    WinWaitActive, Extracting, Cancel, 3
    if ErrorLevel
    {
        ; Sometimes files are extracted so fast that AHK doesn't detect the window
        IfNotExist, C:\ReactOS\Samba-TNG
            TestsFailed("'Extracting' window failed to appear (SetTitleMatchMode=" A_TitleMatchMode ") and 'C:\ReactOS\Samba-TNG' doesnt exist.")
        else
            TestsOK("AHK unabled to detect 'Extracting' window, but 'C:\ReactOS\Samba-TNG' exist.")
    }
    else
    {
        TestsInfo("'Extracting' window appeared, waiting for it to close.")
        WinWaitClose, Extracting, Cancel, 15
        if ErrorLevel
            TestsFailed("'Extracting' window failed to close.")
        else
            TestsOK("'Extracting' window went away.")
    }
}


; Check if program exist
TestsTotal++
if bContinue
{
    IfExist, C:\ReactOS\Samba-TNG
        TestsOK("The application has been installed, because 'C:\ReactOS\Samba-TNG' was found.")
    else
        TestsFailed("Something went wrong, can't find 'C:\ReactOS\Samba-TNG'.")
}
