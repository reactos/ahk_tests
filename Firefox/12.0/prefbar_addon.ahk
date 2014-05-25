/*
 * Designed for Mozilla Firefox 12.0
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

TestName = 6.prefbar_addon
 
; Check if can open some website by typing text in address bar
TestsTotal++
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, Mozilla Firefox Start Page - Mozilla Firefox
        TestsFailed("'Mozilla Firefox Start Page - Mozilla Firefox' is not active window.")
    else
    {
        SendInput, ^+a ; Ctrl+Shift+A aka Main Menu -> Add-ons
        WinWaitActive, Add-ons Manager - Mozilla Firefox,,3
        if ErrorLevel
            TestsFailed("Sent Ctrl+Shift+A to 'Mozilla Firefox Start Page - Mozilla Firefox', but 'Add-ons Manager - Mozilla Firefox' window failed to appear.")
        else
        {
            szSearchTerm = PrefBar ; Case sensitive
            SendInput, {TAB} ; Focus 'Search all add-ons' field
            SendInput, %szSearchTerm%
            clipboard = ; empty
            SendInput, ^a ; Ctrl+A
            SendInput, ^c ; Ctrl+C
            ClipWait, 2
            if ErrorLevel
                TestsFailed("Unable to copy text into clipboard. Unable to focus 'Search all add-ons' field?")
            else
            {
                IfNotInString, clipboard, %szSearchTerm%
                    TestsFailed("Clipboard is expected to have '" szSearchTerm "', but it holds '" clipboard "'.")
                else
                {
                    SendInput, {ENTER} ; Start the search

                    TestsTotal++
                    WaitForPageToLoad("Add-ons Manager - Mozilla Firefox", "7")
                    if bContinue
                    {
                        AddOnX := 490
                        AddOnY := 213
                        Click right %AddOnX%, %AddOnY%
                        Sleep, 550 ; Wait for popup menu to appear
                        SendInput, {DOWN 3}{ENTER} ; Navigate to 'About' in right click menu and click it
                        WinWaitActive, About %szSearchTerm%,,3
                        if ErrorLevel
                            TestsFailed("Something went wrong, because 'About " szSearchTerm "' window failed to appear.")
                        else
                        {
                            SendInput, {ESC} ; Close dialog
                            WinWaitClose, About %szSearchTerm%,,3
                            if ErrorLevel
                                TestsFailed("'About " szSearchTerm "' dialog failed to close despite ESC being sent.")
                            else
                            {
                                WinWaitActive, Add-ons Manager - Mozilla Firefox,,3
                                if ErrorLevel
                                    TestsFailed("Closed 'About " szSearchTerm "' dialog, but 'Add-ons Manager - Mozilla Firefox' window failed to activate.")
                                else
                                    TestsOK("We are at right place of getting '" szSearchTerm "' add-on.")
                            }
                        }
                    }
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    IfWinNotActive, Add-ons Manager - Mozilla Firefox
        TestsFailed("'Add-ons Manager - Mozilla Firefox' window is not active anymore.")
    else
    {
        Click right %AddOnX%, %AddOnY%
        Sleep, 550 ; Wait for popup menu to appear
        SendInput, {DOWN 2}{ENTER} ; Navigate to 'Install' in right click menu and click it
        Sleep, 3000 ; FIXME: wait for installation to be done.
        WinClose, Add-ons Manager - Mozilla Firefox
        WinWaitClose, Add-ons Manager - Mozilla Firefox,,5
        if ErrorLevel
            TestsFailed("Unable to close 'Add-ons Manager - Mozilla Firefox' window.")
        else
        {
            szURL = http://www.reactos.org/sysreg/Static_HTML.html
            Run, %ModuleExe% "%szURL%"
            WinWaitActive, Static HTML - Mozilla Firefox,,3
            if ErrorLevel
                TestsFailed("Ran '" ModuleExe " `"`"" szURL `"`""', but 'Static HTML - Mozilla Firefox' window failed to appear.")
            else
            {
                TestsTotal++
                WaitForPageToLoad("Static HTML - Mozilla Firefox", "7")
                if bContinue
                {
                    if not bImageLoaded()
                        TestsFailed("Seems like image is NOT loaded.")
                    else
                        TestsOK("Image was found. Lets disable image loading and try again.")
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    IfWinNotActive, Static HTML - Mozilla Firefox
        TestsFailed("'Static HTML - Mozilla Firefox' window is NOT active.")
    else
    {
        SendInput, ^t ; Ctrl+T to open new tab
        SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match.
        WinWaitActive, Mozilla Firefox,,3
        if ErrorLevel
            TestsFailed("'Mozilla Firefox' window failed to appear. Unable to open new tab using Ctrl+T combination?")
        else
        {
            ImagesCheckboxX := 84
            ImagesCheckboxY := 124
            Click left %ImagesCheckboxX%, %ImagesCheckboxY% ; Uncheck 'Images' checkbox in PrefBar add-on.

            TestsTotal++
            EnterURL(szURL)
            if bContinue
            {
                WinWaitActive, Static HTML - Mozilla Firefox,,5
                if ErrorLevel
                    TestsFailed("'Static HTML - Mozilla Firefox' window failed to appear.")
                else
                {
                    TestsTotal++
                    WaitForPageToLoad("Static HTML - Mozilla Firefox", "7")
                    if bContinue
                    {
                        if bImageLoaded()
                            TestsFailed("Hmm, image is visible. Failed to uncheck 'Images' checkbox in 'PrefBar' add-on?.")
                        else
                            TestsOK("Succeeded: image was not found. " szSearchTerm " works.")
                    }
                }
            }
        }
    }
}


bTerminateProcess(ProcessExe)


bImageLoaded()
{
    IfWinNotActive, Static HTML - Mozilla Firefox
    {
        TestsInfo("'Static HTML - Mozilla Firefox' window is NOT active.")
        return 0
    }
    else
    {
        clipboard = ; clean the clipboard
        ImgX := 130
        ImgY := 340
        Click right %ImgX%, %ImgY%
        Sleep, 500
        SendInput, o
        ClipWait, 1
        if ErrorLevel
            SendInput, {ESC}
        else
        {
            szImgURL = http://www.reactos.org/sysreg/free.jpg
            IfNotInString, clipboard, %szImgURL%
            {
                TestsInfo("Clipboard contains unexpected data. Is '" clipboard "', should be '" szImgURL "'.")
                return 0
            }
            else
                return 1
        }
    }
}