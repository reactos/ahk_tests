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
DetectHiddenText, Off ; Hidden text is not detected


bTerminateProcess(szProcess)
{
    global TestsTotal

    TestsTotal++
    Process, Exist, %szProcess%
    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
    if NewPID = 0
        bExist := false
    else
        bExist := true
    Process, Close, %szProcess%
    Process, WaitClose, %szProcess%, 4
    if ErrorLevel
    {
        TestsFailed("Unable to terminate '" szProcess "' process.")
        return false
    }
    else
    {
        if bExist
            TestsOK("Terminated '" szProcess "' process.")
        else
            TestsOK("We did not need to terminate '" szProcess "' process because it did not exist.")
        return true
    }
}


bIsConnectedToInternet()
{
    szResult := false
    szResult := DllCall("Wininet.dll\InternetGetConnectedState", "Str", 0x40, "Int", 0)
    return szResult
}


WaitUninstallDone(szUninstallerPath, SecondsToWait)
{
    ; Usage:
    ; UninstallerPath = %UninstallerPath% /SILENT ; Pass silent switch
    ; WaitUninstallDone(UninstallerPath, 3)
    ; if bContinue {}
    global TestsTotal
    
    TestsTotal++
    szParentPath := ExeFilePathNoParam(szUninstallerPath) ; Get full path, no params
    IfNotExist, %szParentPath%
        TestsFailed("Can NOT find '" szParentPath "'.")
    else
    {
        RunWait, %szUninstallerPath%,,, PID
        szParentName := GetProcessName(PID)
        ; Sleep, 10 ; Child process doesn't start right away, need some sleep
        ChildPID := GetChildProcessesList(PID)
        szChildName := GetProcessName(ChildPID)
        ; If you really know there is some child process, result can't be '' (increase sleep in GetChildProcessesList())
        if szChildName <>
            TestsInfo("Reported child name is '" szChildName "'.")
        else
            TestsInfo("Are you sure '" szParentName "' haves no child process?")
        Process, WaitClose, %szChildName%, %SecondsToWait%
        if ErrorLevel ; The PID still exists
        {
            WinGetActiveTitle, WndTitle
            TestsInfo("'" szChildName "' failed to close for " SecondsToWait "s, terminating it. Active wnd: '" WndTitle "'.")
            Process, Close, %szChildName%
            Process, WaitClose, %szChildName%, 3
            if ErrorLevel ; The PID still exists
                TestsFailed("Unable to terminate '" szChildName "', child process of '" szParentName "'.")
            else
                TestsOK("")
        }
        else
            TestsOK("")
    }
}


ExeFilePathNoParam(szPath)
{
    ; Usage: szFunctionResult := ExeFilePathNoParam(szSomePath)
    ; szSomePath := ExeFilePathNoParam(szSomePath)
    StringReplace, szPath, szPath, `",, All ; Remove quotes in case there are some
    szExt = .exe
    StringGetPos, iPos, szPath, %szExt%
    if iPos >= 0
    {
        StringLen, iLength, szPath
        StringTrimRight, szResult, szPath, iLength - iPos - 4
        loop, %szResult%, 1
            szResult = %A_LoopFileLongPath%
        return szResult
    }
    else
    {
        loop, %szResult%, 1
            szResult = %A_LoopFileLongPath%
        return szPath
    }
}


TestsInfo(DebugMessage)
{
    ; Usage: TestsInfo("Your message here.")
    global TestName

    OutputDebug, Info: %TestName%: %DebugMessage%`n
}


TerminateDefaultBrowser(SecondsToWait)
{
    ; Usage: if not TerminateDefaultBrowser(10)
    RegRead, szPath, HKEY_CLASSES_ROOT, http\shell\open\command
    StringReplace, szPath, szPath, `",, All ; This will unquote path
    SplitPath, szPath,,,, name_no_ext ; This will get rid of command line options
    Process, Wait, %name_no_ext%.exe, %SecondsToWait%
    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed
    if NewPID = 0
    {
        OutputDebug, FAILED: Helper Functions: '%name_no_ext%.exe' process did not appear within %SecondsToWait% seconds.`n
        return false
    }
    else
    {
        Process, Close, %name_no_ext%.exe ; Teminate process
        Process, WaitClose, %name_no_ext%.exe, 4
        if ErrorLevel ; The PID still exists
        {
            OutputDebug, FAILED: Helper Functions: Unable to terminate default browser ('%name_no_ext%.exe') process.`n
            return false
        }
        else
        {
            OutputDebug, OK: Helper Functions: Default browser process ('%name_no_ext%.exe') was terminated successfully.`n
            return true ; Default browser process is terminated
        }
    }
}


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
    if DebugText =
        OutputDebug, %TestName%: Debug message text is not an optional, please add it.`n
    else
    {
        szEmpty := ""
        if (WndTitle != szEmpty) ; Window haves no title, print its class instead
            OutputDebug, %TestName%: Test failed: %DebugText% Active Wnd: '%WndTitle%'.`n ; Include some window text and active control caption?
        else
        {
            WinGetClass, WndClass, A
            OutputDebug, %TestName%: Test failed: %DebugText% Active Wnd class: '%WndClass%'.`n
        }
    }

    if not bIsConnectedToInternet()
        TestsInfo("TestsFailed(): No internet connection detected.")
    else
    {
        szApp = %A_WorkingDir%\Apps\Cap.exe ; Screenshot capture utility by Mysoft (Grégori Macário Harbs)
        IfNotExist, %szApp%
            TestsInfo("Can NOT find '" szApp "'.")
        else
        {
            clipboard = ; emptry clipboard
            szFileName := SubStr(A_ScriptName, 1, -4) ; remove '.exe' part from our executable name
            szUploadURL = mysoft.zapto.org:8000/Uploads/Captures/%szFileName%_%TestName%.jpg
            Run, %szApp% /full /jpg 40 /silent /revision /nobelt /clipboard /hfs %szUploadURL%
            SplitPath, szApp, ProcessName
            Process, wait, %ProcessName%, 3
            NewPID = %ErrorLevel%
            if NewPID = 0
                TestsInfo("Process '" ProcessName "' failed to appear.")
            else
            {
                iTimeOut := 30
                while iTimeOut > 0
                {
                    Process, Exist, %ProcessName%
                    NewPID = %ErrorLevel%
                    if NewPID = 0
                        break ; process is closed
                    else
                    {
                        Sleep, 1000
                        iTimeOut--
                    }
                }

                Process, Exist, %ProcessName%
                NewPID = %ErrorLevel%
                if NewPID != 0
                {
                    Process, Close, %ProcessName%
                    Process, WaitClose, %ProcessName%, 5
                    if ErrorLevel
                        TestsInfo("Unable to terminate '" ProcessName "' process.")
                }
                else
                {
                    if A_LastError = 0 ; szApp returns 0 in case of success and puts URL in clipboard
                        TestsInfo("Successfully uploaded to: " clipboard ".")
                    else
                        TestsInfo("There were something wrong while running '" szApp "'.")
                }
            }
        }
    }
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

    TerminateTmpProcesses()
    SplitPath, ProcessName,,,, name_no_ext 
    Process, Exist, %name_no_ext%.tmp ; Will kill some setups
    if ErrorLevel != 0
    {
        Process, close, %name_no_ext%.tmp ; Do not remove this code (it will do the job in case DllCall fails)
        Process, WaitClose, %name_no_ext%.tmp, 5
        if ErrorLevel
            OutputDebug, Helper Functions: Unable to terminate '%name_no_ext%.tmp' process.`n
        else
            OutputDebug, Helper Functions: Succesfully terminated '%name_no_ext%.tmp' process.`n
    }

    ; FIXME: remove 'Setup.exe', 'Install.exe' and 'msiexec.exe' termination when CORE-6939 is fixed,
    ; because TerminateTmpProcesses() will do such things for us
    Process, Exist, Setup.exe
    if ErrorLevel != 0
    {
        Process, close, Setup.exe
        Process, WaitClose, Setup.exe, 5
        if ErrorLevel
            OutputDebug, Helper Functions: Unable to terminate 'Setup.exe' process.`n
    }

    Process, Exist, install.exe
    if ErrorLevel != 0
    {
        Process, close, install.exe
        Process, WaitClose, install.exe, 5
        if ErrorLevel
        {
            Process, WaitClose, install.exe, 5
            if ErrorLevel
                OutputDebug, Helper Functions: Unable to terminate 'install.exe' process.`n
        }
    }
    
    Process, Exist, msiexec.exe
    if ErrorLevel != 0
    {
        Process, close, msiexec.exe
        Process, WaitClose, msiexec.exe, 5
        if ErrorLevel
        {
            Process, WaitClose, msiexec.exe, 5
            if ErrorLevel
                OutputDebug, Helper Functions: Unable to terminate 'msiexec.exe' process.`n
            else
                OutputDebug, Helper Functions: Successfully terminated 'msiexec.exe' process.`n
        }
    }

    WinGetActiveTitle, ErrorWinTitle
    if not ErrorLevel
    {
        IfWinExist, %ErrorWinTitle%, OK ; Check if window really haves 'OK'
        {
            ControlFocus, OK, %ErrorWinTitle%
            if ErrorLevel
            {
                WinClose, %ErrorWinTitle%, OK
                WinWaitClose,,,3
                if ErrorLevel
                    OutputDebug, Helper Functions: Unable to focus 'OK' in '%ErrorWinTitle%' window. Tried to close, failed too.`n
                else
                    OutputDebug, Helper Functions: Unable to focus 'OK' in '%ErrorWinTitle%' window. Tried to close and succeeded.`n
            }
            else
            {
                SendInput, {ENTER} ; Hit 'OK'
                OutputDebug, Helper Functions: Sent ENTER to '%ErrorWinTitle%' window to hit 'OK'.`n
            }
        }
    }
}


; Terminates all '*.tmp', '*.bin', '*Setup*' and '*Install*' processes
TerminateTmpProcesses()
{
    ; http://www.autohotkey.com/docs/commands/Process.htm
    ; Example #4: Retrieves a list of running processes via DllCall
    bError := false
    iUnterminated := 0

    d = `n  ; string separator
    s := 4096  ; size of buffers and arrays (4 KB)

    Process, Exist  ; sets ErrorLevel to the PID of this running script
    ; Get the handle of this script with PROCESS_QUERY_INFORMATION (0x0400)
    h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel)
    ; Open an adjustable access token with this process (TOKEN_ADJUST_PRIVILEGES = 32)
    DllCall("Advapi32.dll\OpenProcessToken", "UInt", h, "UInt", 32, "UIntP", t)
    VarSetCapacity(ti, 16, 0)  ; structure of privileges
    NumPut(1, ti, 0)  ; one entry in the privileges array...
    ; Retrieves the locally unique identifier of the debug privilege:
    DllCall("Advapi32.dll\LookupPrivilegeValueA", "UInt", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
    NumPut(luid, ti, 4, "int64")
    NumPut(2, ti, 12)  ; enable this privilege: SE_PRIVILEGE_ENABLED = 2
    ; Update the privileges of this process with the new access token:
    DllCall("Advapi32.dll\AdjustTokenPrivileges", "UInt", t, "Int", false, "UInt", &ti, "UInt", 0, "UInt", 0, "UInt", 0)
    DllCall("CloseHandle", "UInt", h)  ; close this process handle to save memory

    hModule := DllCall("LoadLibrary", "Str", "Psapi.dll")  ; increase performance by preloading the libaray
    s := VarSetCapacity(a, s)  ; an array that receives the list of process identifiers:
    c := 0  ; counter for process idendifiers
    DllCall("Psapi.dll\EnumProcesses", "UInt", &a, "UInt", s, "UIntP", r)
    Loop, % r // 4  ; parse array for identifiers as DWORDs (32 bits):
    {
        id := NumGet(a, A_Index * 4)
        ; Open process with: PROCESS_VM_READ (0x0010) | PROCESS_QUERY_INFORMATION (0x0400)
        h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id)
        if ErrorLevel = -1
            TestsInfo("The [DllFile\]Function parameter is a floating point number. A string or positive integer is required.")
        else if ErrorLevel = -2
            TestsInfo("The return type or one of the specified arg types is invalid. This error can also be caused by passing an expression that evaluates to a number to a string (str)  argument.")
        else if ErrorLevel = -3
            TestsInfo("The specified DllFile could not be accessed. If no explicit path was specified for DllFile, the file must exist in the system's PATH or A_WorkingDir. This error might also occur if the user lacks permission to access the file.")
        else if ErrorLevel = -4
            TestsInfo("The specified function could not be found inside the DLL.")

        TestsInfo("DllCall('OpenProcess'...) last error: '" A_LastError "'")

        VarSetCapacity(n, s, 0)  ; a buffer that receives the base name of the module:
        e := DllCall("Psapi.dll\GetModuleBaseNameA", "UInt", h, "UInt", 0, "Str", n, "UInt", s)
        if ErrorLevel = -1
            TestsInfo("The [DllFile\]Function parameter is a floating point number. A string or positive integer is required.")
        else if ErrorLevel = -2
            TestsInfo("The return type or one of the specified arg types is invalid. This error can also be caused by passing an expression that evaluates to a number to a string (str)  argument.")
        else if ErrorLevel = -3
            TestsInfo("The specified DllFile could not be accessed. If no explicit path was specified for DllFile, the file must exist in the system's PATH or A_WorkingDir. This error might also occur if the user lacks permission to access the file.")
        else if ErrorLevel = -4
            TestsInfo("The specified function could not be found inside the DLL.")

        TestsInfo("DllCall('Psapi.dll\GetModuleBaseNameA'...) last error: '" A_LastError "'")

        DllCall("CloseHandle", "UInt", h)  ; close process handle to save memory
        if (n && e)  ; if image is not null add to list:
        {
            ; Check if we have '.tmp' in process name
            sztmp = .tmp
            szBin = .bin
            szSetup = Setup
            szInstall = Install
            szMsiExec = msiexec
            IfInString, n, %sztmp%
            {
                Process, Exist, %n% ; Will kill all '*.tmp' processes
                if ErrorLevel != 0
                {
                    Process, close, %n%
                    Process, WaitClose, %n%, 5
                    if ErrorLevel
                    {
                        bError := true
                        iUnterminated++
                        OutputDebug, Helper Functions: Unable to terminate '%n%' process.`n
                    }
                    else
                        OutputDebug, Helper Functions: Successfully terminated '%n%' process.`n
                }
            }
            else IfInString, n, %szBin%
            {
                Process, Exist, %n% ; Will kill all '*.bin' processes
                if ErrorLevel != 0
                {
                    Process, close, %n%
                    Process, WaitClose, %n%, 5
                    if ErrorLevel
                    {
                        bError := true
                        iUnterminated++
                        OutputDebug, Helper Functions: Unable to terminate '%n%' process.`n
                    }
                    else
                        OutputDebug, Helper Functions: Successfully terminated '%n%' process.`n
                }
            }
            else IfInString, n, %szSetup%
            {
                Process, Exist, %n% ; Will kill all '*Setup*' processes
                if ErrorLevel != 0
                {
                    Process, close, %n%
                    Process, WaitClose, %n%, 5
                    if ErrorLevel
                    {
                        bError := true
                        iUnterminated++
                        OutputDebug, Helper Functions: Unable to terminate '%n%' process.`n
                    }
                    else
                        OutputDebug, Helper Functions: Successfully terminated '%n%' process.`n
                }
            }
            else IfInString, n, %szInstall%
            {
                Process, Exist, %n% ; Will kill all '*Install*' processes
                if ErrorLevel != 0
                {
                    Process, close, %n%
                    Process, WaitClose, %n%, 5
                    if ErrorLevel
                    {
                        bError := true
                        iUnterminated++
                        OutputDebug, Helper Functions: Unable to terminate '%n%' process.`n
                    }
                    else
                        OutputDebug, Helper Functions: Successfully terminated '%n%' process.`n
                }
            }
            else IfInString, n, %szMsiExec%
            {
                Process, Exist, %n% ; Will kill all '*msiexec*' processes
                if ErrorLevel != 0
                {
                    Process, close, %n%
                    Process, WaitClose, %n%, 5
                    if ErrorLevel
                    {
                        bError := true
                        iUnterminated++
                        OutputDebug, Helper Functions: Unable to terminate '%n%' process.`n
                    }
                    else
                        OutputDebug, Helper Functions: Successfully terminated '%n%' process.`n
                }
            }
        }
    }
    DllCall("FreeLibrary", "UInt", hModule)  ; unload the library to free memory
    if bError
    {
        OutputDebug, Helper Functions: Unable to terminate %iUnterminated% process(es).`n
        return false
    }
    else
        return true
}


GetChildProcessesList(PID)
{
   ChildProcesses = 
   
   ;We get the list of processes of the system (pidlist)
   A:=EnumProcesses(pidlist)
   Loop, Parse, pidlist, `|
   {
      if A_LoopField = %PID%
         continue ;The parent process can't be a child
      parentPID := GetParentProcessID(A_LoopField)
      if parentPID = %PID%
      {
         if StrLen(ChildProcesses) > 0
            ChildProcesses = %ChildProcesses%`n%A_LoopField%
         else
            ChildProcesses = %A_LoopField%
      }
   }
   return %ChildProcesses%
}


; ProcessInfo.ahk - Function library to retrieve various application process informations:
; - Script's own process identifier
; - Parent process ID of a process (the caller application)
; - Process name by process ID (filename without path)
; - Thread count by process ID (number of threads created by process)
; - Full filename by process ID (GetModuleFileNameEx() function)
;
; Tested with AutoHotkey 1.0.46.10
;
; Created by HuBa
; Contact: http://www.autohotkey.com/forum/profile.php?mode=viewprofile&u=4693
;
; Portions of the script are based upon the GetProcessList() function by wOxxOm
; (http://www.autohotkey.com/forum/viewtopic.php?p=65983#65983)

GetCurrentProcessID()
{
  Return DllCall("GetCurrentProcessId")  ; http://msdn2.microsoft.com/ms683180.aspx
}

GetCurrentParentProcessID()
{
  Return GetParentProcessID(GetCurrentProcessID())
}

GetProcessName(ProcessID)
{
  Return GetProcessInformation(ProcessID, "Str", 260, 36)  ; TCHAR szExeFile[MAX_PATH]
}

GetParentProcessID(ProcessID)
{
  Return GetProcessInformation(ProcessID, "UInt *", 4, 24)  ; DWORD th32ParentProcessID
}

GetProcessThreadCount(ProcessID)
{
  Return GetProcessInformation(ProcessID, "UInt *", 4, 20)  ; DWORD cntThreads
}

GetProcessInformation(ProcessID, CallVariableType, VariableCapacity, DataOffset)
{
  hSnapshot := DLLCall("CreateToolhelp32Snapshot", "UInt", 2, "UInt", 0)  ; TH32CS_SNAPPROCESS = 2
  if (hSnapshot >= 0)
  {
    VarSetCapacity(PE32, 304, 0)  ; PROCESSENTRY32 structure -> http://msdn2.microsoft.com/ms684839.aspx
    DllCall("ntdll.dll\RtlFillMemoryUlong", "UInt", &PE32, "UInt", 4, "UInt", 304)  ; Set dwSize
    VarSetCapacity(th32ProcessID, 4, 0)
    if (DllCall("Process32First", "UInt", hSnapshot, "UInt", &PE32))  ; http://msdn2.microsoft.com/ms684834.aspx
      Loop
      {
        DllCall("RtlMoveMemory", "UInt *", th32ProcessID, "UInt", &PE32 + 8, "UInt", 4)  ; http://msdn2.microsoft.com/ms803004.aspx
        if (ProcessID = th32ProcessID)
        {
          VarSetCapacity(th32DataEntry, VariableCapacity, 0)
          DllCall("RtlMoveMemory", CallVariableType, th32DataEntry, "UInt", &PE32 + DataOffset, "UInt", VariableCapacity)
          DllCall("CloseHandle", "UInt", hSnapshot)  ; http://msdn2.microsoft.com/ms724211.aspx
          Return th32DataEntry  ; Process data found
        }
        if not DllCall("Process32Next", "UInt", hSnapshot, "UInt", &PE32)  ; http://msdn2.microsoft.com/ms684836.aspx
          Break
      }
    DllCall("CloseHandle", "UInt", hSnapshot)
  }
  Return  ; Cannot find process
}


GetModuleFileNameEx(ProcessID)  ; modified version of shimanov's function
{
  if A_OSVersion in WIN_95, WIN_98, WIN_ME
    Return GetProcessName(ProcessID)
  
  ; #define PROCESS_VM_READ           (0x0010)
  ; #define PROCESS_QUERY_INFORMATION (0x0400)
  hProcess := DllCall( "OpenProcess", "UInt", 0x10|0x400, "Int", False, "UInt", ProcessID)
  if (ErrorLevel or hProcess = 0)
    Return
  FileNameSize := 260
  VarSetCapacity(ModuleFileName, FileNameSize, 0)
  CallResult := DllCall("Psapi.dll\GetModuleFileNameExA", "UInt", hProcess, "UInt", 0, "Str", ModuleFileName, "UInt", FileNameSize)
  DllCall("CloseHandle", hProcess)
  Return ModuleFileName
}


EnumProcesses(byref Var) {
 IfEqual, A_OSType, WIN32_WINDOWS, Return 0
 List_Sz := VarSetCapacity(Pid_List, 4000)  
 Res := DllCall("psapi.dll\EnumProcesses", UInt,&Pid_List
                , Int,List_Sz, "UInt *",PID_List_Actual) 
 IfLessOrEqual,Res,0, Return, Res
 _a := &PID_List 
 Var :=
 Loop, % (PID_List_Actual//4) { 
   Var := Var "|" (*(_a)+(*(_a+1)<<8)+(*(_a+2)<<16)+(*(_a+3)<<24))
   _a += 4 
   } 
 StringTrimLeft, Var, Var, 1 
Return, (PID_List_Actual//4)
}