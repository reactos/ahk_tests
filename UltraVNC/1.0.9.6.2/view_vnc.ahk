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

TestName = 2.view_vnc
host = 178.63.22.18
port = 1337
password = rose-dummy

; Test if can connect to VNC server for a view
TestsTotal++
RunVNCViewer()
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, UltraVNC Viewer - Win32 1.0.9.6.2, Quick Options
        TestsFailed("'UltraVNC Viewer - Win32 1.0.9.6.2 (Quick Options)' window is not active.")
    else
    {
        ControlSetText, Edit1, %host%::%port%, UltraVNC Viewer - Win32 1.0.9.6.2, Quick Options ; Enter host and port
        if ErrorLevel
            TestsFailed("Unable to enter 'VNC Server' address '" host "::" port "' in  'UltraVNC Viewer - Win32 1.0.9.6.2 (Quick Options)' window.")
        else
        {
            ControlClick, Button17 ; Hit 'Connect' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Connect' button in 'UltraVNC Viewer - Win32 1.0.9.6.2 (Quick Options)' window.")
            else
            {
                WinWait, VNC Viewer Status for %host%, Traffic, 5 ; Wait until window exist
                if ErrorLevel
                    TestsFailed("'VNC Viewer Status for " host " (Traffic)' window does NOT exist.")
                else
                {
                    WinWaitActive, VNC Authentication, Password, 3
                    if ErrorLevel
                        TestsFailed("'VNC Authentication (Password)' window failed to appear.")
                    else
                    {
                        ControlSetText, Edit1, %password% ; Enter password
                        if ErrorLevel
                            TestsFailed("Unable to enter '" password "' in 'Password' field in 'VNC Authentication (Password)' window.")
                        else
                        {
                            ControlClick, Button1 ; Hit 'Log On' button
                            if ErrorLevel
                                TestsFailed("Unable to hit 'Log On' button in 'VNC Authentication (Password)' window.")
                            else
                                TestsOK("Entered host and port, hit 'Connect' button, entered password, hit 'Log On' button.")
                        }
                    }
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    WinWaitClose, VNC Authentication, Password, 3
    if ErrorLevel
        TestsFailed("'VNC Authentication (Password)' window failed to close despite password entered and 'Log On' button being clicked.")
    else
    {
        WinWaitClose, VNC Viewer Status for %host%, Traffic, 3
        if ErrorLevel
            TestsFailed("'VNC Viewer Status for " host " (Traffic)' window failed to close.")
        else
        {
            WinWaitActive, QEMU (rose-dummy),,5
            if ErrorLevel
                TestsFailed("'QEMU (rose-dummy)' window failed to appear.") ; Window haves brackets in its title
            else
                TestsOK("VNC Viewer works as expected.")
        }
    }
}


TestsTotal++
if bContinue
{
    WinClose, QEMU (rose-dummy)
    WinWaitClose,,,3
    if ErrorLevel
        TestsFailed("'QEMU (rose-dummy)' window failed to close.")
    else
    {
        Process, WaitClose, %VNCViewerExe%, 4
        if ErrorLevel
            TestsFailed("'" VNCViewerExe "' process failed to close despite 'QEMU (rose-dummy)' window closed.")
        else
            TestsOK("Closed 'QEMU (rose-dummy)' window, then '" VNCViewerExe "' process closed on its own.")
    }
}
