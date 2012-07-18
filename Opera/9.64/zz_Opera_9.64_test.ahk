/*
 * Designed for Opera v9.64
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

#Include ..\helper_functions.ahk


if 1 = --list
{
params =
(
install
AddressBar
Download
FlashPlayer
CloseDownload
)
FileAppend, %params%, *
}
else if 1 = install
{
    #include Install.ahk
}
else
{
    #include Preparation.ahk
    if bContinue
    {
        if 1 = AddressBar
        {
            #include AddressBar.ahk
        }
        else if 1 = Download
        {
            #include Download.ahk
        }
        else if 1 = FlashPlayer
        {
            #include FlashPlayer.ahk
        }
        else if 1 = CloseDownload
        {
            #include CloseDownload.ahk
        }
        else OutputDebug, Bad parameters!`r`n
    }
}

if 1 != --list
{
    if bContinue ; Succeeded, close normally
    {
        SetTitleMatchMode, 2
        WinClose, Opera,,5
        if ErrorLevel
        {
            Process, close, Opera.exe ; Failed to close, terminate
        }
    }
    else ; We failed, so kill process
    {
        SplitPath, ModuleExe, fName ; Extract filename from given path
        WindowCleanUp(fName)  
    }

    ; Delete saved settings
    Sleep, 1500
    FileRemoveDir, %A_AppData%\Opera, 1

    TestsSkipped := TestsTotal - TestsOK - TestsFailed
    TestsExecuted := TestsOK + TestsFailed
    OutputDebug, %Module%: %TestsExecuted% tests executed (0 marked as todo, %TestsFailed% failures), %TestsSkipped% skipped.`n
}