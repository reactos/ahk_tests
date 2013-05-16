/*
 * Designed for Mono .net Development Framework 2.11.2
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

TestName = 3.compile_winforms ; http://www.mono-project.com/Mono_Basics#Winforms_Hello_World

; Test if can compile and run Winforms application
TestsTotal++
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    szSourceCode = 
    (
        using System;
        using System.Windows.Forms;
     
        public class HelloWorld : Form
        {
            static public void Main ()
            {
                Application.Run (new HelloWorld ());
            }
         
            public HelloWorld ()
            {
                Text = "Hello Mono World";
                var label = new Label();
                label.Text = "This is Mono";
                this.Controls.Add(label);
            }
        }
    )

    IfExist, C:\hello.cs
    {
        FileDelete, C:\hello.cs
        if ErrorLevel
            TestsFailed("Unable to delete existing 'C:\hello.cs'.")
    }

    if bContinue
    {
        FileAppend, %szSourceCode%, C:\hello.cs
        if ErrorLevel
            TestsFailed("Unable to create 'C:\hello.cs'.")
        else
        {
            IfNotExist, %InstalledDir%\bin\setmonopath.bat
                TestsFailed("'" InstalledDir "\bin\setmonopath.bat' does NOT exist.")
            else
            {
                FileCopy, %InstalledDir%\bin\setmonopath.bat, C:\setmonopath.bat, 1 ; Copy and overwrite existing files
                if ErrorLevel <> 0
                    TestsFailed("Can NOT copy '" InstalledDir "\bin\setmonopath.bat' to 'C:\setmonopath.bat'.")
                else
                {
                    FileAppend, cd c:\`nmcs hello.cs -pkg:dotnet, C:\setmonopath.bat
                    if ErrorLevel
                        TestsFailed("Unable to write to 'C:\setmonopath.bat'.")
                    else
                    {
                        Run, cmd.exe /c C:\setmonopath.bat, C:\,, cmdPID
                        Process, WaitClose, %cmdPID%, 3
                        if ErrorLevel <> 0
                            TestsFailed("Process 'cmd.exe (PID: " cmdPID ")' failed to close.")
                        else
                        {
                            IfNotExist, C:\hello.exe
                                TestsFailed("'C:\hello.exe' does NOT exist. Failed to compile?")
                            else
                                TestsOK("Compilation succeeded, because 'C:\hello.exe' exist.")
                        }
                    }
                }
            }
        }
    }
}


; Test if can run compiled application
TestsTotal++
RunApplication("C:\hello.exe")
if bContinue
{
    WinWaitActive, Hello Mono World, This is Mono, 3
    if ErrorLevel
        TestsFailed("'Hello Mono World (This is Mono)' window failed to appear.")
    else
    {
        Sleep, 1000 ; Let window to load properly, maybe it will fail
        if WinNotActive, Hello Mono World
            TestsFailed("Slept for a while and 'Hello Mono World (This is Mono)' window is not active anymore.")
        else
        {
            WinClose
            WinWaitClose,,,3
            if ErrorLevel
                TestsFailed("'Hello Mono World (This is Mono)' window failed to close.")
            else
            {
                Process, WaitClose, %ProcessExe%, 4
                if ErrorLevel
                    TestsFailed("'" ProcessExe "' process failed to close despite 'Hello Mono World (This is Mono)' window being closed.")
                else
                    TestsOK("Closed 'Hello Mono World (This is Mono)' window, then '" ProcessExe "' process closed too.")
            }
        }
    }
}
