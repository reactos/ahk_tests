/*
 * Designed for 7-Zip 4.65
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

TestName = 3.Benchmark

; Test if can run benchmark (bug 5906)
TestsTotal++
Process, Close, 7zG.exe ; Close Benchmark
RunApplication("")
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    WinWaitActive, 7-Zip File Manager,,7
    if ErrorLevel
        TestsFailed("Window '7-Zip File Manager' failed to appear.")
    else
    {
        Sleep, 1500 ; Let it to fully load
        WinMenuSelectItem, 7-Zip File Manager, , Tools, Benchmark
        if ErrorLevel
            TestsFailed("Unable to hit 'Tools -> Benchmark'.")
        else
        {
            WinWaitActive, Benchmark, Dictionary size, 5
            if ErrorLevel
                TestsFailed("'Benchmark (Dictionary size)' window failed to appear.")
            else
            {
                Control, Choose, 9, ComboBox1, Benchmark ; Choose '32MB' as 'Dictionary size' (9th item of list)
                if ErrorLevel
                    TestsFailed("Unable to choose '32MB' as 'Dictionary size' in 'Benchmark'.")
                else
                {
                    Sleep, 2000
                    ControlGetText, OutputVar, Static30, Benchmark
                    TimeOut := 0
                    while (OutputVar = "...") and (TimeOut < 90)
                    {
                        ControlGetText, OutputVar, Static30, Benchmark
                        Sleep, 1000
                        TimeOut++
                    }

                    if TimeOut = 90
                        TestsFailed("Timed out.")
                    else
                    {
                        Process, Close, 7zFM.exe
                        Process, WaitClose, 7zFM.exe, 4
                        if ErrorLevel
                            TestsFailed("Unable to terminate '7zFM.exe' process.")
                        else
                        {
                            Process, Close, 7zG.exe ; Close Benchmark
                            Process, WaitClose, 7zG.exe, 4
                            if ErrorLevel
                                TestsFailed("Unable to terminate '7zG.exe' process.")
                            else
                                TestsOK("Amount of percent in 'Total Rating' changed, so there is no bug #5906. '7zFM.exe' and '7zG.exe' terminated successfully.")
                        }
                    }
                }
            }
        }
    }
}
