/*
 * Designed for UltraVNC 1.0.9.6.2
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

; Test if the app is installed
TestsTotal++
RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Ultravnc2_is1, UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    UninstallerPath := ExeFilePathNoParam(UninstallerPath)
    SplitPath, UninstallerPath,, InstalledDir
    if (InstalledDir = "")
        TestsFailed("Either registry contains empty string or we failed to read it.")
    else
    {
        VNCViewerPath = %InstalledDir%\vncviewer.exe
        VNCServerPath = %InstalledDir%\winvnc.exe
        SplitPath, VNCViewerPath, VNCViewerExe
        SplitPath, VNCServerPath, VNCServerExe
        TestsOK("")
    }
}


; Terminate application
if bContinue
{
    bTerminateProcess(VNCViewerExe)
    if bContinue
        bTerminateProcess(VNCServerExe)
}


; Delete settings separately from RunVNCXXX() in case we want to write our own settings
TestsTotal++
if bContinue
{
    IfExist, %A_AppData%\UltraVNC
    {
        FileRemoveDir, %A_AppData%\UltraVNC, 1
        if ErrorLevel
            TestsFailed("Unable to delete '" A_AppData "\UltraVNC'.")
        else
            TestsOK("")
    }
    else
        TestsOK("")
}


; Test if can start viewer application
RunVNCViewer()
{
    global ModuleExe
    global VNCViewerPath
    global TestName
    global TestsTotal
    global bContinue
    global VNCViewerExe
    
    ModuleExe = %VNCViewerPath% ; For our helper functions

    TestsTotal++
    if bContinue
    {
        IfNotExist, %ModuleExe%
            TestsFailed("Can NOT find '" ModuleExe "'.")
        else
        {
            Run, %ModuleExe%
            WinWaitActive, UltraVNC Viewer - Win32 1.0.9.6.2, Quick Options, 5
            if ErrorLevel
            {
                Process, Exist, %VNCViewerExe%
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("Window 'UltraVNC Viewer - Win32 1.0.9.6.2 (Quick Options)' failed to appear. No '" VNCViewerExe "' process detected.")
                else
                    TestsFailed("Window 'UltraVNC Viewer - Win32 1.0.9.6.2 (Quick Options)' failed to appear. '" VNCViewerExe "' process detected.")
            }
            else
                TestsOK("")
        }
    }
}
