/*
 * Designed for WinRAR 3.80
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

#Include ..\..\helper_functions.ahk


if 1 = --list
{
params =
(

    1.install
    2.ExtractPwdProtected

)
FileAppend, %params%, *
}
else if 1 = 1.install
{
    #include install_test.ahk
}
else
{
    #include prepare.ahk
    
    if 1 = 2.ExtractPwdProtected
    {
        #include ExtractPwdProtected.ahk ; Extract password protected RAR archive
    }
    else
    OutputDebug, Bad parameters: '%1%'!`r`n
}

if 1 != --list
{
    if not bContinue
    {
        SplitPath, ModuleExe, fName ; Extract filename from given path
        WindowCleanUp(fName)  
    }

    ; Delete saved settings
    Sleep, 1500
    FileRemoveDir, %A_AppData%\WinRAR, 1

    TestsSkipped := TestsTotal - TestsOK - TestsFailed
    TestsExecuted := TestsOK + TestsFailed
    if (TestsSkipped < 0 or TestsExecuted < 0)
        OutputDebug, %TestName%: Check TestsTotal, TestsOK and TestsFailed, because results returns less than 0.`n
    OutputDebug, %TestName%: %TestsExecuted% tests executed (0 marked as todo, %TestsFailed% failures), %TestsSkipped% skipped.`n
}
