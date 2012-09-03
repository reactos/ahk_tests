/*
 * Helper functions library
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

; These lines are added for performance reasons, as suggested in http://www.autohotkey.com/docs/misc/Performance.htm
#NoEnv
SetBatchLines -1
ListLines Off

SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.


CheckParam() ; Usage: if CheckParam() {..} //No need of ELSE part
{
    global params
    global 1

    if 1 =
    {
        OutputDebug, You did not specify any parameter. Use '--list' to output the list of parameters to stdout.`r`n
        return false
    }
    else if 1 = --list
    {
        FileAppend, %params%, *
        return true
    }
    else
    {
        IfInString, params, %1%
            return true ; OK, we have such parameter.
        else
        {
            OutputDebug, Bad parameters: '%1%'! Use '--list' to output the list of parameters to stdout.`r`n
            return false
        }
    }
}


ShowTestResults() ; Usage: ShowTestResults()
{
    global bContinue
    global TestName
    global TestsSkipped
    global TestsTotal
    global TestsOK
    global TestsFailed
    global TestsExecuted
    global params
    global ModuleExe
    global 1

    IfInString, params, %1% ; Check if right param was specified
    {
        if 1 != --list
        {
            if not bContinue
            {
                SplitPath, ModuleExe, fName ; Extract filename from given path
                WindowCleanUp(fName)  
            }

            TestsSkipped := TestsTotal - TestsOK - TestsFailed
            TestsExecuted := TestsOK + TestsFailed
            if (TestsSkipped < 0 or TestsExecuted < 0)
                OutputDebug, %TestName%: Check TestsTotal, TestsOK and TestsFailed, because results returns less than 0.`n
            OutputDebug, %TestName%: %TestsExecuted% tests executed (0 marked as todo, %TestsFailed% failures), %TestsSkipped% skipped.`n
        }
    }
}


InitalizeCounters() ; Usage: InitalizeCounters()
{
    global bContinue := false
    global TestsOK := 0
    global TestsFailed := 0
    global TestsTotal := 0
}


TestsOK(DebugText)
{
    ; Usage: 
    ; TestsOK("Your text here '" SomeVariable "'.") - will output "OK: NameOfTest: Your text here 'VariableText'."
    ; TestsOK("") - will not output anything
    global TestsOK
    global bContinue
    global TestName

    TestsOK++
    bContinue := true
    if DebugText <> ; We have nothing to output
        OutputDebug, OK: %TestName%: %DebugText%`n
}


TestsFailed(DebugText)
{
    global TestsFailed
    global bContinue
    global TestName

    TestsFailed++
    bContinue := false
    WinGetActiveTitle, WndTitle
    if DebugText <>
        OutputDebug, %TestName%: Test failed: %DebugText% Active Wnd: '%WndTitle%'.`n ; Include some window text and active control caption?
}


LeftClickControl(ControlName)
{
    ; Usage:
    ; if LeftClickControl("Button1") {}
    
    ; http://www.autohotkey.com/docs/commands/PostMessage.htm
    SendMessage, 0x201, 0, 0, %ControlName% ; Left click down
    if ErrorLevel <> FAIL
    {
        Sleep, 120 ; Just in case
        SendMessage, 0x202, 0, 0, %ControlName% ; Left click up 
        if ErrorLevel <> FAIL
        {
            ; Everything went OK
            return 1
        }
        else
        {
            OutputDebug, HelperFunctions: Test failed: SendMessage(left click up) reported an error, trying PostMessage.`n
            PostMessage, 0x202, 0, 0, %ControlName% ; Left click up 
            if ErrorLevel <> FAIL
            {
                ; Everything went OK
                return 1
            }
            else
            {
                OutputDebug, HelperFunctions: Test failed: PostMessage(left click up) failed too.`n
                return 0
            }
        }
    }
    else
    {
        OutputDebug, HelperFunctions: Test failed: SendMessage(left click down) reported an error, trying PostMessage.`n
        PostMessage, 0x201, 0, 0, %ControlName% ; Left click down
        if ErrorLevel <> FAIL
        {
            Sleep, 120 ; Just in case
            PostMessage, 0x202, 0, 0, %ControlName% ; Left click up 
            if ErrorLevel <> FAIL
            {
                ; Everything went OK
                return 1
            }
            else
            {
                OutputDebug, HelperFunctions: Test failed: PostMessage(left click up) failed too.`n
                return 0
            }
        }
        else
        {
            OutputDebug, HelperFunctions: Test failed: PostMessage(left click down) failed too.`n
            return 0
        }
    }
}


FileCountLines(PathToFile)
{
    NumberOfLines := 0 ; In case there is no such file or something
    Loop, read, %PathToFile%
        NumberOfLines++
    return %NumberOfLines%
    ; Usage: i := FileCountLines(szDocument)
}


; Terminates application windows and closes error boxes
WindowCleanup(ProcessName)
{
    Process, Exist, %ProcessName%
    if ErrorLevel != 0
    {
        Process, close, %ProcessName%
        Process, WaitClose, %ProcessName%, 5
        if ErrorLevel
            OutputDebug, Helper Functions: Unable to terminate '%ProcessName%' process.`n
    }
    
    SplitPath, ProcessName,,, name_no_ext 
    Process, Exist, %name_no_ext%.tmp ; Will kill some setups
    if ErrorLevel != 0
    {
        Process, close, %name_no_ext%.tmp
        Process, WaitClose, %name_no_ext%.tmp, 5
        if ErrorLevel
            OutputDebug, Helper Functions: Unable to terminate '%name_no_ext%.tmp' process.`n
    }

    Process, Exist, Setup.exe
    if ErrorLevel != 0
    {
        Process, close, Setup.exe
        Process, WaitClose, Setup.exe, 5
        if ErrorLevel
            OutputDebug, Helper Functions: Unable to terminate 'Setup.exe' process.`n
    }
    
    Sleep, 2500
    IfWinActive, Mozilla Crash Reporter
    {
        SendInput, {SPACE} ; Dont tell Mozilla about this crash
        Sleep, 200
        SendInput, {TAB}
        Sleep, 200
        SendInput, {TAB}
        Sleep, 200
        SendInput, {ENTER} ; Hit 'Quit Firefox'
    }
    else
    {
        WinGetTitle, ErrorWinTitle, A
        if not ErrorLevel
        {
            ControlFocus, OK, %ErrorWinTitle%
            if not ErrorLevel
            {
                Sleep, 1200
                SendInput, {ENTER} ; Hit 'OK' button
                OutputDebug, Helper Functions: Sent ENTER to '%ErrorWinTitle%' window to hit 'OK' button.`n
            }
        }
    }
}