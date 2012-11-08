/*
 * Designed for Super Finder XT 1.6.3.2
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

TestName = 2.find_file
szDocument =  %A_Desktop%\XT_TestFile.txt ; Filename must be at least 4 char long (not including .ext)

; Test if can create file and find it using Super Finder XT
TestsTotal++
RunApplication("")
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfExist, %szDocument%
    {
        FileDelete, %szDocument%
        if ErrorLevel <> 0
            TestsFailed("Unable to delete '" szDocument "'.")
    }

    if bContinue
    {
        szDocTex = This is Super Finder XT 1.6.3.2 test
        FileAppend, %szDocTex%, %szDocument%
        if ErrorLevel
            TestsFailed("Unable to create '" szDocument "'.")
        else
        {
            IfWinNotActive, ahk_class TMainForm
                TestsFailed("Window class 'TMainForm' (Super Finder XT) is not an active window.")
            else
            {
                SplitPath, szDocument, szFileName,, szExt
                NewStr := SubStr(szFileName, 1, 4) ; Create a substring (4 chars of filename)
                ControlSetText, Edit4, %NewStr%*.%szExt%, ahk_class TMainForm ; Enter 'File name'
                if ErrorLevel
                    TestsFailed("Unable to enter '" NewStr "*." szExt "' in 'File name' field.")
                else
                {
                    ControlSetText, Edit1, %A_Desktop%, ahk_class TMainForm ; Enter 'Path or Locations'
                    if ErrorLevel
                        TestsFailed("Unable to enter '" A_Desktop "' in 'Path or Locations'.")
                    else
                        TestsOK("Entered text in 'File name' and 'Path or Locations'.")
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    IfWinNotActive, ahk_class TMainForm
        TestsFailed("Window class 'TMainForm' is not an active anymore.")
    else
    {
        SendInput, !s ; Alt+S aka hit 'Search' button
        Sleep, 1500
        ControlClick, TListView1, ahk_class TMainForm ; Hit on the list. Can't get text of status bar.
        if ErrorLevel
            TestsFailed("Unable to hit ListView control in 'TMainForm' window class.")
        else
        {
            SendInput, {DOWN}{ENTER} ; Select and open the file. 
            WinWaitActive, ahk_class Notepad,, 3
            if ErrorLevel
                TestsFailed("'Notepad' window class failed to appear.")
            else
            {
                ControlGetText, szNotepadText, Edit1, ahk_class Notepad ; Get text from opened Notepad window
                if ErrorLevel
                {
                    Process, Close, Notepad.exe
                    Process, WaitClose, Notepad.exe, 4
                    if ErrorLevel
                        TestsInfo("Unable to terminate 'Notepad.exe' process.")

                    TestsFailed("Unable to get text from Notepad window.")
                }
                else
                {
                    WinClose
                    WinWaitClose,,,3
                    if ErrorLevel
                        TestsFailed("Unable to close 'Notepad' window class.")
                    else
                    {
                        if (szNotepadText != szDocTex)
                            TestsFailed("Text doesn't match (is '" szNotepadText "', should be '" szDocTex "').")
                        else
                            TestsOK("Found result, opened it with Notepad, compared text, everything is OK.")
                    }
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    IfWinNotActive, ahk_class TMainForm
        TestsFailed("'TMainForm' window class is not an active.")
    else
    {
        ; WinClose will close XT to TaskBar. Writing 'CloseToTray' registry setting 
        ; won't help, since it looks for 'Language' first 
        Process, Close, %ProcessExe%
        Process, WaitClose, %ProcessExe%, 4
        if ErrorLevel
            TestsFailed("Unable to terminate '" ProcessExe "' process.")
        else
            TestsOK("Search works.")
    }
}
