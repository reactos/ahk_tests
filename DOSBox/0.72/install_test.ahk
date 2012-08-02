/*
 * Designed for DOSBox 0.72
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

ModuleExe = %A_WorkingDir%\Apps\DOSBox 0.72 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    Process, Close, dosbox.exe
    ; At least for 0.72 installer doesn't write any uninstall information to registry
    InstallLocation = %A_ProgramFiles%\DOSBox ; Not default!
    ; Get rid of other versions
    IfExist, %InstallLocation%
    {
        IfExist, %InstallLocation%\uninstall.exe
        {
            RunWait, %InstallLocation%\uninstall.exe /S ; Silently uninstall it
        }
        Sleep, 2500
        FileRemoveDir, %InstallLocation%, 1
        Sleep, 1000
        IfExist, %InstallLocation%
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%InstallLocation%'.`n
            bContinue := false
        }
        else
        {
            bContinue := true
        }
    }
    else
    {
        ; No previous versions detected.
        bContinue := true
    }
    if bContinue
    {
        Run %ModuleExe%
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%ModuleExe%' not found.`n
    bContinue := false
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, DOSBox 0.72 Installer Setup: License Agreement, DOSBox v0.72 License, 7
    if not ErrorLevel
    {
        ControlClick, Button2, DOSBox 0.72 Installer Setup: License Agreement, DOSBox v0.72 License ; Hit 'Next' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, %TestName%:%A_LineNumber%: OK: 'DOSBox 0.72 Installer Setup: License Agreement' appeared and 'Next' button was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: unable to hit 'Next' button in 'License Agreement'. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'DOSBox 0.72 Installer Setup: License Agreement' window with 'Next' button failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'Installation Options' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, DOSBox 0.72 Installer Setup: Installation Options, Select components, 7
    if not ErrorLevel
    {
        ControlClick, Button2, DOSBox 0.72 Installer Setup: Installation Options, Select components ; Hit 'Next' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, %TestName%:%A_LineNumber%: OK: 'DOSBox 0.72 Installer Setup: Installation Options' appeared and 'Next' button was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: unable to hit 'Next' button in 'Installation Options' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'DOSBox 0.72 Installer Setup: Installation Options' window with 'Next' button failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'Installation Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, DOSBox 0.72 Installer Setup: Installation Folder, This will install, 7
    if not ErrorLevel
    {
        ControlSetText, Edit1, %A_ProgramFiles%\DOSBox, DOSBox 0.72 Installer Setup: Installation Folder, This will install ; Change installation directory
        if not ErrorLevel
        {
            ControlClick, Button2, DOSBox 0.72 Installer Setup: Installation Folder, This will install ; Hit 'Install' button
            if not ErrorLevel
            {
                TestsOK()
                OutputDebug, %TestName%:%A_LineNumber%: OK: 'DOSBox 0.72 Installer Setup: Installation Folder' appeared and 'Install' button was clicked.`n
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: unable to hit 'Install' button in 'Installation Folder' window. Active window caption: '%title%'.`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: unable to set installation folder in 'Installation Folder' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'DOSBox 0.72 Installer Setup: Installation Folder' window with 'Install' button failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'Completed' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, DOSBox 0.72 Installer Setup: Completed, Completed, 7
    if not ErrorLevel
    {
        ControlClick, Button2, DOSBox 0.72 Installer Setup: Completed, Completed ; Hit 'Close' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, %TestName%:%A_LineNumber%: OK: 'DOSBox 0.72 Installer Setup: Completed' appeared and 'Close' button was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: unable to hit 'Close' button in 'Completed' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'DOSBox 0.72 Installer Setup: Completed' window with 'Close' button failed to appear. Active window caption: '%title%'.`n
    }
}


;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 2000
    IfExist, %InstallLocation%
    {
        TestsOK()
        OutputDebug, OK: %TestName%:%A_LineNumber%: The application has been installed, because '%InstallLocation%' was found.`n
    }
    else
    {
        TestsFailed()
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Something went wrong, can't find '%InstallLocation%'.`n
    }
}
