/*
 * Designed for WinRAR 3.80
 * Copyright (C) 2014 Edijs Kolesnikovics
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

TestName = 4.drag_and_drop

; Test if can create an archive using command line parameters
TestsTotal++
if bContinue
{
    IfNotExist, %ModuleExe%
        TestsFailed("Can NOT find '" ModuleExe "'.")
    else
    {
        szFileToArchive = C:\WinRAR_drag_and_drop.txt
        IfExist, %szFileToArchive%
        {
            FileDelete, %szFileToArchive%
            if ErrorLevel
                TestsFailed("Unable to delete existing '" szFileToArchive "'.")
        }

        if bContinue
        {
            szFileText = drag_and_drop_test
            FileAppend, %szFileText%, %szFileToArchive%
            if ErrorLevel
                TestsFailed("Unable to create '" szFileToArchive "'.")
            else
            {
                szArchiveFilename = C:\MyArchive.rar
                Run, %ModuleExe% a %szArchiveFilename% %szFileToArchive%
                Process, WaitClose, %ProcessExe%, 2
                if ErrorLevel ; The PID still exists
                    TestsFailed("Creating archive with a plain text file in it took too long.")
                else
                {
                    IfNotExist, %szArchiveFilename%
                        TestsFailed("'" ProcessExe "' process closed, but '" szArchiveFilename "' does NOT exist. Problems with WinRAR command line parameters?")
                    else
                        TestsOK("Archive created using WinRAR command line parameters.")
                }
            }
        }
    }
}

; Make sure file does NOT exist in the place we are dropping it to
TestsTotal++
if bContinue
{
    SplitPath, szFileToArchive, NameExt
    szDesktopFile = %A_Desktop%\%NameExt%
    IfExist, %szDesktopFile%
    {
        FileDelete, %szDesktopFile%
        if ErrorLevel
            TestsFailed("Unable to delete '" szDesktopFile "'.")
    }

    if bContinue
        TestsOK("Either '" szDesktopFile "' did not exist or we deleted it.")
}

; Test if can drag and drop to shell
TestsTotal++
RunApplication(szArchiveFilename)
if bContinue
{
    SplitPath, szArchiveFilename, NameExt
    WinWaitActive, %NameExt% - WinRAR (evaluation copy),,5
    if ErrorLevel
        TestsFailed("Window '" NameExt " - WinRAR (evaluation copy)' failed to appear.")
    else
    {
        ; Window appeared, we need to resize it, so, drop target is visible
        WinRestore
        WinMove, %NameExt% - WinRAR (evaluation copy),, 0, 0, 150, 280 ; Move the window to the upper-left corner of the screen and resize it
        ; We need to check if we are at right place, e.g. make sure if we are dragging what we are supposed to
        WinRARFileX := 20
        WinRARFileY := 215
        MouseMove, %WinRARFileX%, %WinRARFileY%
        MouseGetPos, , , OutputHWND, ControlOverMouse
        WinGetClass, WndClassName, ahk_id %OutputHWND%
        WinRARClass = WinRarWindow
        IfNotInString, WinRARClass, %WndClassName%
            TestsFailed("Mouse cursor is not over window with a class name of '" WinRARClass "', but '" WndClassName "'.")
        else
        {
            ; Window class is correct, now, lets check if cursor is under correct control
            ControlName = SysListView321
            IfNotInString, ControlName, %ControlOverMouse%
                TestsFailed("Mouse cursor is not over WinRARs '" ControlName "' control, but '" ControlOverMouse "'.")
            else
            {
                ; OK, coordinates of WinRAR are good, now, find an empty place in Desktop
                MouseMove, A_ScreenWidth - 1, 1
                MouseGetPos, , , OutputHWND, ControlOverMouse
                WinGetClass, WndClassName, ahk_id %OutputHWND%
                DesktopClass = Progman
                IfNotInString, DesktopClass, %WndClassName%
                    TestsFailed("Mouse cursor is not over window with a class name of '" DesktopClass "', but '" WndClassName "'.")
                else
                {
                    IfNotInString, ControlName, %ControlOverMouse%
                        TestsFailed("Mouse cursor is not over Desktops '" ControlName "' control, but '" ControlOverMouse "'.")
                    else
                    {
                        MouseClickDrag, L, %WinRARFileX%, %WinRARFileY%, A_ScreenWidth - 1, 1
                        Sleep, 500 ; Some sleep is required
                        IfNotExist, %szDesktopFile%
                            TestsFailed("Unable to drag&drop because '" szDesktopFile "' does NOT exist. Visual conditions were perfect. #CORE-3760?")
                        else
                        {
                            ; Seems we can drag and drop, lets make sure file contents are correct
                            FileReadLine, FileContents, %szDesktopFile%, 1
                            if ErrorLevel
                                TestsFailed("Failure reading existing '" szDesktopFile "'.")
                            else
                            {
                                IfNotInString, szFileText, %FileContents%
                                    TestsFailed("Unexpected '" szDesktopFile "' contents. Is '" FileContents "', should be '" szFileText "'.")
                                else
                                    TestsOK("Drag and drop works.")
                            }
                        }
                    }
                }
            }
        }
    }
}


bTerminateProcess(ProcessExe)
