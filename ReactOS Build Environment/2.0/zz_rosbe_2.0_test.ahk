/*
 * Designed for ReactOS Build Environment 2.0
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

#Include ..\..\helper_functions.ahk
InitalizeCounters()

params =
(

    1.install
    2.gcc_compile

)

if CheckParam()
{
    ; Those brackets are required!
    if 1 = 1.install
    {
        #include install_test.ahk
    }
    else 
    {
        if 1 != --list
        {
            #include prepare.ahk

            if 1 = 2.gcc_compile
            {
                #include gcc_compile.ahk
            }

            ; We can't just terminate some cmd.exe process, because we will shut down rosautotests
            ; IfWinExist, ReactOS Build Environment 2.0
            ; {
                ; TestsInfo("Ola amigo")
                ; WinClose, ReactOS Build Environment 2.0
                ; WinWaitClose, ReactOS Build Environment 2.0,,3
                ; if ErrorLevel
                ; {
                    ; TestsInfo("Unable to close 'ReactOS Build Environment 2.0' window.")
                    ; if RosBE_PID <> 
                    ; {
                        ; Process, Close, %RosBE_PID%
                        ; Process, WaitClose, %RosBE_PID%, 3
                        ; if ErrorLevel
                            ; TestsInfo("Unable to terminate 'cmd.exe PID " RosBE_PID "' process.")
                    ; }
                ; }
            ; }
        }
    }
}


ShowTestResults()
