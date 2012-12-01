/*
 * Designed for Java 6.25
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

TestName = 2.run_java_gui_app
szDocument =  %A_WorkingDir%\Media\HelloWorldGui.class ; Case insensitive. compiled with jdk-6u25-windows-i586 from command line using: "C:\FullPath\javac.exe HelloWorldGui.java"

; Test if can run Java Hello World GUI application
TestsTotal++
RunApplication(szDocument)
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    WinWaitActive, Java GUI app works,,3
    if ErrorLevel
        TestsFailed("'Java GUI app works' window failed to appear.")
    else
    {
        Sleep, 1000 ; Let it to load, maybe it will crash
        IfWinNotActive, Java GUI app works
            TestsFailed("Slept for a while and 'Java GUI app works' window is not active anymore.")
        else
        {
            WinClose, Java GUI app works
            WinWaitClose,,,3
            if ErrorLevel
                TestsFailed("'Java GUI app works' window failed to close.")
            else
            {
                Process, WaitClose, %ProcessExe%, 5
                if ErrorLevel ; The PID still exists
                    TestsFailed("'" ProcessExe "' process failed to close despite 'Java GUI app works' window closed.")
                else
                    TestsOK("'Java GUI app works' window appeared, slept, closed it and '" ProcessExe "' process closed too.")
            }
        }
    }
}
