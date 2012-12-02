/*
 * Designed for LibreOffice 3.6.2
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
RegRead, InstalledDir, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1E85458A-9B00-443F-A187-2E06DBB15E43}, InstallLocation
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    ModuleExe = %InstalledDir%program\soffice.exe
    TestsOK("")
}


; Terminate application
if bContinue
{
    SplitPath, ModuleExe, ProcessExe,,, Process_no_ext
    bTerminateProcess(ProcessExe)
    ProcessBin = %Process_no_ext%.bin
    bTerminateProcess(ProcessBin)
}


; Delete settings separately from RunApplication() in case we want to write our own settings
TestsTotal++
if bContinue
{
    IfExist, %A_AppData%\LibreOffice
    {
        FileRemoveDir, %A_AppData%\LibreOffice, 1
        if ErrorLevel
            TestsFailed("Unable to delete '" A_AppData "\LibreOffice'.")
        else
            TestsOK("")
    }
    else
        TestsOK("")
}


; Test if can start application
RunApplication()
{
    global ModuleExe
    global TestName
    global TestsTotal
    global bContinue
    global ProcessExe

    TestsTotal++
    if bContinue
    {
        IfNotExist, %ModuleExe%
            TestsFailed("Can NOT find '" ModuleExe "'.")
        else
        {
            Run, %ModuleExe%,, Max ; Start maximized
            WinWaitActive, LibreOffice,,15 ; Takes a bit to load
            if ErrorLevel
            {
                Process, Exist, %ProcessExe%
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("Window 'LibreOffice' failed to appear. No '" ProcessExe "' process detected.")
                else
                    TestsFailed("Window 'LibreOffice' failed to appear. '" ProcessExe "' process detected.")
            }
            else
                TestsOK("")
        }
    }
}
