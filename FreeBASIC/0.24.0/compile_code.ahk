/*
 * Designed for FreeBASIC 0.24.0
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

TestName = 2.compile_code
szDocument = %A_WorkingDir%\Media\Hanoi2.bas

; Test if can compile FreeBasic source code and run exe
TestsTotal++
RunApplication()
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, %ModuleExe%
        TestsFailed("'" ModuleExe "' window is not an active.")
    else
    {
        IfNotExist, %szDocument%
            TestsFailed("Unable to find '" szDocument "'.")
        else
        {
            FileCopy, %szDocument%, C:\, 1 ; overwrite existing files
            if ErrorLevel <> 0 ; Number of files that can't be copied
                TestsFailed("Unable to make a copy of '" szDocument "' in C:\.")
            else
            {
                SplitPath, szDocument,,,, szFileName ; get file name no ext
                szCompiledPath = C:\%szFileName%.exe
                IfExist, %szCompiledPath%
                {
                    FileDelete, %szCompiledPath%
                    if ErrorLevel
                        TestsFailed("Unable to delete '" szCompiledPath "'.")
                }

                if bContinue ; Either file did not exist or we succeeded deleting it
                {
                    SendInput, cd c:\{ENTER} ; Go to C:\
                    IfWinNotActive, %ModuleExe% ; Check if nothing bad happened
                        TestsFailed("'" ModuleExe "' window is not an active anymore.")
                    else
                    {
                        SendInput, fbc %szFileName%.bas{ENTER}
                        Sleep, 1000 ; Sleep for a second until code is compiled
                        IfNotExist, %szCompiledPath%
                            TestsFailed("Typed 'fbc " szFileName ".bas', but exe file did not appear.")
                        else
                            TestsOK("Typed 'fbc " szFileName ".bas' and '" szCompiledPath "' file appeared.")
                    }
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    WinClose, %ModuleExe% ; Close compiler window
    WinWaitClose,,,3
    if ErrorLevel
        TestsFailed("Unable to close '" ModuleExe "' window.")
    else
    {
        Run, %szCompiledPath%
        WinWaitActive, Hanoi2 by Mysoft,,3
        if ErrorLevel
            TestsFailed("'Hanoi2 by Mysoft' window failed to appear.")
        else
        {
            WinMove, 0, 0
            CoordX = 347
            CoordY = 343
            szColor = 0x402010
            PixelGetColor, color, %CoordX%, %CoordY%
            if ErrorLevel
                TestsFailed("Unable to get pixel color of '" CoordX "x" CoordY "'.")
            else
            {
                if (color != szColor)
                    TestsFailed("Pixel colors doesn't match (is " color ", should be " szColor ").")
                else
                {
                    Process, Close, Hanoi2.exe
                    Process, WaitClose, Hanoi2.exe, 4
                    if ErrorLevel
                        TestsFailed("Unable to terminate 'Hanoi2.exe' process.")
                    else
                        TestsOK("Ran compiled app, checked pixel color, everything is OK.")
                }
            }
        }
    }
}
