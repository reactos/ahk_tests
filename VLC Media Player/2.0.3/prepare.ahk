/*
 * Designed for VLC Media Player 2.0.3
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

ModuleExe = %A_ProgramFiles%\VideoLAN\VLC\vlc.exe
bContinue := true
TestsTotal := 0
TestsSkipped := 0
TestsFailed := 0
TestsOK := 0
TestsExecuted := 0

Process, Close, vlc.exe

; Delete saved settings
Sleep, 1500
FileRemoveDir, %A_AppData%\vlc, 1
Sleep, 800

FileCreateDir, %A_AppData%\vlc
if not ErrorLevel
{
    FileAppend, [General]`nIsFirstRun=0`n, %A_AppData%\vlc\vlc-qt-interface.ini ; Overcome 'Privacy and Network Access Policy' dialog
    if ErrorLevel
    {
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to create and edit '%A_AppData%\vlc\vlc-qt-interface.ini'.'`n
        bContinue := false
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to create '%A_AppData%\vlc'.`n
    bContinue := false
}
