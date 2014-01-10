/*
 * Designed for clipboard
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

TestName = 1.copy_file
bContinue = true

TestsTotal++
szFile = C:\clipboard_copy_file.txt
IfExist, %szFile%
{
    FileDelete, %szFile%
    if ErrorLevel
        TestsFailed("Unable to delete '" szFile "'.")
}
if bContinue
{
    FileAppend, file_contents`n, %szFile%
    ; sleep, 1552
    clipboard = ; Empty the clipboard
    if clipboard !=
        TestsFailed("Clipboard is NOT empty, but it should! Its contents are: '" clipboard "'.")
    else
    {
        FileToClipboard(szFile)
        ClipWait, 2
        if ErrorLevel
            TestsFailed("Unable to copy existing file (" szFile ") to the clipboard.")
        else
        {
            IfNotInString, clipboard, %szFile%
                TestsFailed("Unexpected clipboard content, is '" clipboard "', should be '" szFile "'.")
            else
                TestsOK("Copying file to clipboard using SetClipboardData works.")
        }
    }
}


FileToClipboard(PathToCopy)
{
    ; Expand to full paths:
    Loop, Parse, PathToCopy, `n, `r
        Loop, %A_LoopField%, 1
            temp_list .= A_LoopFileLongPath "`n"
    PathToCopy := SubStr(temp_list, 1, -1)

    ; Allocate some movable memory to put on the clipboard.
    ; This will hold a DROPFILES struct and a null-terminated list of
    ; null-terminated strings.
    ; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
    hPath := DllCall("GlobalAlloc","uint",0x42,"uint",StrLen(PathToCopy)+22)

    ; Lock the moveable memory, retrieving a pointer to it.
    pPath := DllCall("GlobalLock","uint",hPath)
    NumPut(20, pPath+0) ; DROPFILES.pFiles = offset of file list

    pPath += 20
    ; Copy the list of files into moveable memory.
    Loop, Parse, PathToCopy, `n, `r
    {
        DllCall("lstrcpy","uint",pPath+0,"str",A_LoopField)
        pPath += StrLen(A_LoopField)+1
    }

    ; Unlock the moveable memory.
    DllCall("GlobalUnlock","uint",hPath)
    
    DllCall("OpenClipboard","uint",0)
    ; Empty the clipboard, otherwise SetClipboardData may fail.
    DllCall("EmptyClipboard")
     ; Place the data on the clipboard. CF_HDROP=0xF
    DllCall("SetClipboardData","uint",0xF,"uint",hPath)
    DllCall("CloseClipboard")
}