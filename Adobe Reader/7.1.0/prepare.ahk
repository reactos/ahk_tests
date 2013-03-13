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

TestName = prepare

; Test if the app is installed
TestsTotal++
RegRead, InstalledPathReg, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{AC76BA86-7AD7-1033-7B44-A71000000002}, InstallLocation
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    if (InstalledPathReg = "")
        TestsFailed("Either registry contains empty string or we failed to read it.")
    else
    {
        ModuleExe = %InstalledPathReg%AcroRd32.exe ; InstalledPathReg already contains backslash
        TestsOK("")
    }
}


; Terminate application
if bContinue
{
    SplitPath, ModuleExe, ProcessExe
    bTerminateProcess(ProcessExe)
}


; Get rid of application settings
TestsTotal++
if bContinue
{
    RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Adobe\Acrobat Reader
    RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Adobe\Repair\Acrobat Reader
    RegDelete, HKEY_CURRENT_USER, SOFTWARE\Adobe\Acrobat Reader
    IfExist, %A_AppData%\Adobe\Acrobat
        FileRemoveDir, %A_AppData%\Adobe\Acrobat, 1

    IfExist, %A_AppData%\Adobe\Acrobat
        TestsFailed("Unable to delete '" A_AppData "\Adobe\Acrobat'.")
    else
        TestsOK("")
}


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global bContinue
    global TestsTotal

    TestsTotal++
    if bContinue
    {
        RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE, SOFTWARE\Adobe\Acrobat Reader\7.0\AdobeViewer, EULA, 1 ; Accept EULA
        IfNotExist, %ModuleExe%
            TestsFailed("RunApplication(): Can NOT find '" ModuleExe "'.")
        else
        {
            if PathToFile =
            {
                Run, %ModuleExe%,, Max ; Start maximized
                WinWaitActive, Adobe Reader,,15
                if ErrorLevel
                {
                    Process, Exist, AcroRd32.exe
                    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                    if NewPID = 0
                        TestsFailed("RunApplication(): Window 'Adobe Reader' failed to appear. No 'AcroRd32.exe' process detected.")
                    else
                        TestsFailed("RunApplication(): Window 'Adobe Reader' failed to appear. 'AcroRd32.exe' process detected.")
                }
                else
                    TestsOK("")
            }
            else
            {
                IfNotExist, %PathToFile%
                    TestsFailed("Can NOT find '" PathToFile "'.")
                else
                {
                    Run, %ModuleExe% "%PathToFile%",, Max
                    SplitPath, PathToFile, NameExt
                    WinWaitActive, Adobe Reader - [%NameExt%],,15
                    if ErrorLevel
                    {
                        Process, Exist, AcroRd32.exe.exe
                        NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                        if NewPID = 0
                            TestsFailed("RunApplication(): Window 'Adobe Reader - [" NameExt "]' failed to appear. No 'AcroRd32.exe.exe' process detected.")
                        else
                            TestsFailed("RunApplication(): Window 'Adobe Reader - [" NameExt "]' failed to appear. 'AcroRd32.exe.exe' process detected.")
                    }
                    else
                        TestsOK("")
                }
            }
        }
    }
}
