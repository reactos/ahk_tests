/*
 * Designed for VLC Media Player 2.0.3
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

; Test if can take and save snapshot

TestName = 3.take_snapshot
szDocument =  %A_WorkingDir%\Media\Foundry accident.mp4 ; Case sensitive!

TestsTotal++
RunApplication(szDocument)
if bContinue
{
    SplitPath, szDocument, NameExt
    WinWaitActive, %NameExt% - VLC media player,,3
    if ErrorLevel
        TestsFailed("'" NameExt " - VLC media player' window failed to appear.")
    else
    {
        WndW = 439
        WndH = 359
        WinGetPos, X, Y, Width, Height, %NameExt% - VLC media player
        if not ((Width > WndW) AND Height > WndH) ; Video is 440x360
            TestsFailed("Size of '" NameExt " - VLC media player' window is not as expected when playing '" szDocument "' (is '" Width "x" Height "', should be at least '" WndW "x" WndH "').")
        else
        {
            Sleep, 2000 ; Play some video
            IfWinNotActive, %NameExt% - VLC media player
                TestsFailed("Slept for a while and '" NameExt " - VLC media player' window became inactive.")
            else
            {
                FileDelete, %A_MyDocuments%\My Pictures\*.png
                if ErrorLevel
                    TestsFailed("Unable to delete '" A_MyDocuments "\My Pictures\*png'.")
                else
                {
                    SendInput, {SPACE}
                    SendInput, !v ; Alt+V to open Video menu. WinMenuSelectItem doesn't work here
                    Sleep, 500 ; Wait for menu to drop down
                    SendInput, {DOWN 12}{ENTER} ; Video->Take Snapshot

                    Sleep, 1000 ; Wait for file to be created and get its name
                    Loop, %A_MyDocuments%\My Pictures\*.png
                    {
                        szSnapshotPath =  %A_LoopFileFullPath%
                        break
                    }

                    FileGetSize, iFileSize, %szSnapshotPath% ; ~247 KB (253,121 bytes)
                    if ErrorLevel
                        TestsFailed("Error while retrieving file size of '" szSnapshotPath "'.")
                    else
                    {
                        If (iFileSize < 200000)
                            TestsFailed("File size of '" szSnapshotPath "' is less than expected. Is '" iFileSize " KB', should be at least 200000.")
                        else
                            TestsOK("'Video->Take Snapshot' works, because created '" szSnapshotPath "' (" iFileSize " bytes).")
                    }
                }
            }
        }
    }
}


bTerminateProcess(ProcessExe)
