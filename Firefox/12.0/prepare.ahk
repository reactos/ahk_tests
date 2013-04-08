/*
 * Designed for Mozilla Firefox 12.0
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

TestName = prepare

; Test if the app is installed
TestsTotal++
RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox 12.0 (x86 en-US), UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    SplitPath, UninstallerPath,, InstalledDir
    SplitPath, InstalledDir,, InstalledDir ; Need to split twice
    if (InstalledDir = "")
        TestsFailed("Either registry contains empty string or we failed to read it.")
    else
    {
        ModuleExe = %InstalledDir%\firefox.exe
        TestsOK("")
    }
}


TestsTotal++
if bContinue
{
    IfNotExist, %ModuleExe%
        TestsFailed("Can NOT find '" ModuleExe "'.")
    else
    {
        SplitPath, ModuleExe, ProcessExe
        Process, Close, %ProcessExe%
        Process, WaitClose, %ProcessExe%, 5
        if ErrorLevel ; The PID still exists.
            TestsFailed("Unable to terminate '" ProcessExe "' process.")
        else
        {
            FileRemoveDir, %A_AppData%\Mozilla, 1 ; Delete all saved settings
            IfExist, %A_AppData%\Mozilla
                TestsFailed("Seems like we failed to delete '" A_AppData "\Mozilla'.")
            else
            {
                FileCreateDir, %A_AppData%\Mozilla\Firefox\Profiles\ReactOS.default
                if ErrorLevel
                    TestsFailed("Failed to create dir tree '" A_AppData "\Mozilla\Firefox\ReactOS.default'.")
                else
                {
                    FileAppend, [General]`nStartWithLastProfile=0`n`n[Profile0]`nName=default`nIsRelative=1`nPath=Profiles/ReactOS.default`n, %A_AppData%\Mozilla\Firefox\profiles.ini
                    if ErrorLevel
                        TestsFailed("Failed to create and edit '" A_AppData "\Mozilla\Firefox\profiles.ini'.")
                    else
                    {
                        szNoWarningOnClose := "user_pref(""browser.tabs.warnOnClose""`, false)`;" ; Now, new do not want any warnings when closing multiple tabs
                        szNoFirstRun := "user_pref(""browser.startup.homepage_override.mstone""`, ""rv:12.0"")`;" ; Lets pretend we ran it once
                        szRightsShown := "user_pref(""browser.rights.3.shown""`, true)`;" ; We know your rights, no need to ask
                        szNoImprvHelp := "user_pref(""toolkit.telemetry.prompted""`, 2)`;`nuser_pref(""toolkit.telemetry.rejected""`, true)`;" ; We don't want to help to improve
                        szDownloadDir := "user_pref(""browser.download.folderList""`, 0)`;" ; Desktop is our default download directory
                        FileAppend, %szNoWarningOnClose%`n%szNoFirstRun%`n%szRightsShown%`n%szNoImprvHelp%`n`n%szDownloadDir%, %A_AppData%\Mozilla\Firefox\Profiles\ReactOS.default\prefs.js
                        if ErrorLevel
                            TestsFailed("Failed to create and edit '" A_AppData "\Mozilla\Firefox\Profiles\ReactOS.default\prefs.js'.")
                        else
                        {
                            Run, %ModuleExe%,,Max ; Start maximized
                            WinWaitActive, Mozilla Firefox Start Page - Mozilla Firefox,, 15
                            if ErrorLevel
                            {
                                Process, Exist, %ProcessExe%
                                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                                if NewPID = 0
                                    TestsFailed("'Mozilla Firefox Start Page - Mozilla Firefox' window failed to appear. No '" ProcessExe "' process detected.")
                                else
                                    TestsFailed("'Mozilla Firefox Start Page - Mozilla Firefox' window failed to appear. '" ProcessExe "' process detected.")
                            }
                            else
                            {
                                TestsInfo("I was here.")
                                WinWaitActive, Default Browser,,3 ; This shouldn't happen
                                if not ErrorLevel
                                {
                                    TestsInfo("I was here 2.")
                                    TestsFailed++ ; 'Default Browser' dialog appeared -> this is a failure
                                    szDefaultBrowserBug = 4107
                                    TestsInfo("'Default Browser' window appeared, but it shouldn't (#CORE-" szDefaultBrowserBug "?). Ignoring.")
                                    TestsTotal++
                                    SendInput, {ENTER} ; Hit 'Yes' in 'Default Browser' dialog
                                    WinWaitClose, Default Browser,,3
                                    if ErrorLevel
                                        TestsFailed("'Default Browser' dialog appeared (when it shouldn't [#CORE-" szDefaultBrowserBug "?]) we sent ENTER to hit 'Yes' button, but dialog failed to close.")
                                    else
                                    {
                                        TestsInfo("I was here 3.")
                                        WinWaitActive, Mozilla Firefox Start Page - Mozilla Firefox,, 3
                                        if ErrorLevel
                                            TestsFailed("'Mozilla Firefox Start Page - Mozilla Firefox' window failed to appear despite 'Default Browser' (#CORE-" szDefaultBrowserBug "?) dialog was closed.")
                                        else
                                            TestsOK("Despite 'Default Browser' dialog appeared (when it shouldn't [#CORE-" szDefaultBrowserBug "?]), we managed to start Firefox.")
                                    }
                                }
                                else
                                    TestsOK("Everything went as expected.")
                            }
                        }
                    }
                }
            }
        }
    }
}


EnterURL(TheURL)
{
    global TestName
    global bContinue
    global TestsTotal

    SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
    IfWinNotActive, - Mozilla Firefox
        TestsFailed("'- Mozilla Firefox' is NOT active window. (TitleMatchMode=" A_TitleMatchMode ")")
    else
    {
        clipboard = ; Empty the clipboard
        SendInput, {ALTDOWN}d{ALTUP} ; Go to address bar
        TestsInfo("Sent Alt+D to focus address bar.")
        IfWinActive, Mozilla Firefox Start Page - Mozilla Firefox ; Our default window. Address bar holds 'about:home'
        {
            Send, ^a ; Ctrl+A
            Send, ^c ; Ctrl+C
            clipboard = ; clean
            ClipWait, 2
            if ErrorLevel
            {
                TestsFailed("The attempt to copy address bar text from 'Mozilla Firefox Start Page - Mozilla Firefox' window onto the clipboard failed.")
                TestsTotal++
                Sleep, 2500 ; Maybe ReactOS is not just fast enough to focus address bar, so, wait a bit
                SendInput, !d ; Alt+D
                clipboard = ; clean
                Send, ^a ; Ctrl+A
                Send, ^c ; Ctrl+C
                ClipWait, 2
                if ErrorLevel
                    TestsFailed("Still can NOT copy text from address bar. Lag? Alt+D does not work?")
                else
                    TestsFailed("OK, copied text from address bar, but you should NOT see this line. It only means ReactOS is slow, etc.") ; Still failure
            }
            else
            {
                szDefaultText = about:home
                IfNotInString, clipboard, %szDefaultText%
                    TestsFailed("Copied address bar text of 'Mozilla Firefox Start Page - Mozilla Firefox' window and got unexpected results. Is '" clipboard "', should be '" szDefaultText "'.")
                else
                    TestsInfo("Address bar is focused for sure.") ; Yes, TestsInfo
            }
        }

        SendInput, %TheURL% ; Address bar should be focused
        clipboard = ; Empty the clipboard
        Send, ^a ; Ctrl+A
        Send, ^c ; Ctrl+C
        ClipWait, 2
        if ErrorLevel
            TestsFailed("The attempt to copy text onto the clipboard failed when entering '" TheURL "'. Unable to focus address bar?")
        else
        {
            IfNotInString, TheURL, %clipboard%
                TestsFailed("Entered URL to addressbar, copied it and clipboard content is wrong. Is '" clipboard "', should be '" TheURL "'.")
            else
            {
                SendInput, {ENTER} ; Go to URL
                TestsOK("Focused address bar using Alt+D, entered '" TheURL "' and sent ENTER to go to it.")
            }
        }
    }
    SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match.
}


; Waits specified amount of seconds for page to be loaded
WaitForPageToLoad(szExpectedWindowTitle, nTimeOut)
{
    global TestName
    global bContinue
    global TestsTotal

    while (nTimeOut > 0)
    {
        SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
        IfWinNotActive, - Mozilla Firefox
            TestsFailed("'- Mozilla Firefox' is NOT active window. TitleMatchMode=" A_TitleMatchMode)
        else
        {
            SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match.
            WinWaitActive, %szExpectedWindowTitle%,,1
            if ErrorLevel
            {
                ; WinGetActiveTitle, Title
                ; TestsInfo(szExpectedWindowTitle " is not active. " Title " is active.")
                nTimeOut--
            }
            else
            {
                ; get pixel, if it is still loading - sleep
                StatusBarX := 230
                StatusBarY := 565

                if not bStatusBarAppeared
                {
                    iColorTimeOut := 200
                    while (iColorTimeOut > 0)
                    {
                        IfWinNotActive, %szExpectedWindowTitle%
                            TestsFailed("'" szExpectedWindowTitle "' window is NOT active anymore.")
                        else
                        {
                            PixelGetColor, szColor, %StatusBarX%, %StatusBarY%
                            if ErrorLevel
                                TestsFailed("Unable to get '" StatusBarX "x" StatusBarY "' pixel color.")
                            else
                            {
                                szLoadedColor = 0xF2F2F2
                                IfInString, szColor, %szLoadedColor%
                                {
                                    bStatusBarAppeared := true
                                    break ; Page loading is started
                                }
                                else
                                {
                                    ; TestsInfo("Waiting for statusbar to appear.")
                                    iColorTimeOut--
                                    Sleep, 10
                                }
                            }
                        }
                    }
                }

                PixelGetColor, szColor, %StatusBarX%, %StatusBarY%
                if ErrorLevel
                    TestsFailed("Unable to get '" StatusBarX "x" StatusBarY "' pixel color.")
                else
                {
                    ; TestsInfo(StatusBarX "x" StatusBarY " color: " szColor)
                    IfNotInString, szColor, %szLoadedColor%
                    {
                        TestsOK("Page is loaded, because statusbar is hidden.")
                        break
                    }
                    else
                    {
                        Sleep, 1000
                        nTimeOut--
                    }
                }
            }
        }
    }

    if (nTimeOut <= 0)
        TestsFailed("WaitForPageToLoad(): timed out.")
    SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match.
}
