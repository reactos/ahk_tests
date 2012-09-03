/*
 * Designed for Abiword 2.6.4
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

Process, Close, AbiWord.exe

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AbiWord2, UninstallString
if ErrorLevel
{
    ModuleExe = %A_ProgramFiles%\AbiSuite2\AbiWord\bin\AbiWord.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}
else
{
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\AbiWord\bin\AbiWord.exe
}


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global bContinue
    global TestsTotal

    TestsTotal++
    Process, Close, AbiWord.exe
    Process, WaitClose, AbiWord.exe, 4
    if ErrorLevel
        TestsFailed("Unable to close 'AbiWord.exe' process.")
    else
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\AbiSuite
        Sleep, 500
        IfNotExist, %ModuleExe%
            TestsFailed("Can NOT find '" ModuleExe "'.")
        else
        {
            if PathToFile =
            {
                Run, %ModuleExe%,, Max ; Start maximized
                Sleep, 1000
                WinWaitActive, Untitled1 - AbiWord,,7
                if ErrorLevel
                    TestsFailed("Window 'Untitled1 - AbiWord' failed to appear.")
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
                    Sleep, 1000
                    SplitPath, PathToFile, NameExt
                    WinWaitActive, %NameExt% - AbiWord,,7
                    if ErrorLevel
                        TestsFailed("Window '%NameExt% - AbiWord' failed to appear.")
                    else
                        TestsOK("")
                }
            }
        }
    }
}
