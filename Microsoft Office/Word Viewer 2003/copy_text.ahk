/*
 * Designed for Word Viewer 2003
 * Copyright (C) 2013 Edijs Kolesnikovics
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

TestName = 2.copy_text
szDocument =  %A_WorkingDir%\Media\Microsoft Word 2003 Doc.doc ; Case sensitive!

; Test if can open Word document and copy text from it to clipboard
TestsTotal++
RunApplication(szDocument)
if bContinue
{

    RegRead, bHideExt, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt
    if ErrorLevel
        TestsFailed("Unable to read 'HideFileExt' in 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'.")
    else
    {
        if bHideExt
            SplitPath, szDocument,,,, name_no_ext
        else
            SplitPath, szDocument, NameExt
        szWndCaption = %name_no_ext%%NameExt% - Microsoft Word Viewer
        WinWaitActive, %szWndCaption%,,2
        if ErrorLevel
            TestsFailed("Window '" szWndCaption "' failed to appear.")
        else
        {
            szExpected = Hello from Word document.
            clipboard = ; clean
            TestsInfo("Cleaned clipboard contents.")
            SendInput, ^a ; Ctrl+A aka select all
            TestsInfo("About to send Ctrl+C")
            SendInput, ^c ; Ctrl+C aka copy
            TestsInfo("Sent Ctrl+C successfully")
            ClipWait, 2
            if ErrorLevel
                TestsFailed("Sent Ctrl+A and Ctrl+C to '" szWndCaption "' window, but copied nothing.")
            else
            {
                TestsInfo("About to check if strings matches")
                IfNotInString, clipboard, %szExpected%
                    TestsFailed("Sent Ctrl+A and Ctrl+C to '" szWndCaption "' window, but got unexpected results. Is '" clipboard "', should be '" szExpected "'.")
                else
                    TestsOK("Sent Ctrl+A and Ctrl+C to '" szWndCaption "' window and succeeded copying text to the clipboard.")
            }
        }
    }
}


; Test if can close application successfully
TestsTotal++
if bContinue
{
    WinClose, %szWndCaption%
    WinWaitClose, %szWndCaption%,,3
    if ErrorLevel
        TestsFailed("Unable to close '" szWndCaption "' window.")
    else
    {
        Process, WaitClose, %ProcessExe%, 4
        if ErrorLevel
            TestsFailed("'" ProcessExe "' process failed to close despite '" szWndCaption "' window closed.")
        else
            TestsOK("Closed '" szWndCaption "' window and '" ProcessExe "' process went away.")
    }
}
