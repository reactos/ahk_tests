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
if bContinue
{
    WinWaitActive, 7-Zip File Manager,,7
    if not ErrorLevel
    {
        Sleep, 1500 ; Let it to fully load
        WinMenuSelectItem, 7-Zip File Manager, , Tools, Benchmark
        if not ErrorLevel
        {
            WinWaitActive, Benchmark, Dictionary size, 5
            if not ErrorLevel
            {
                Control, Choose, 9, ComboBox1, Benchmark ; Choose '32MB' as 'Dictionary size' (9th item of list)
                if not ErrorLevel
                {
                    Sleep, 2000
                    ControlGetText, OutputVar, Static30, Benchmark
                    while OutputVar = "..."
                    {
                        ControlGetText, OutputVar, Static30, Benchmark
                        Sleep, 1000
                    }
                    TestsOK("Amount of percent in 'Total Rating' changed, so there is no bug #5906.")
                }
                else
                    TestsFailed("Unable to choose '32MB' as 'Dictionary size' in 'Benchmark'.")
            }
            else
                TestsFailed("'Benchmark (Dictionary size)' window failed to appear.")
        }
        else
            TestsFailed("Unable to hit 'Tools -> Benchmark'.")
    }
    else
        TestsFailed("Window '7-Zip File Manager' failed to appear.")
}
else
    TestsFailed("We failed somwehere in 'prepare.ahk'.")


Process, Close, 7zFM.exe
Process, Close, 7zG.exe ; Close Benchmark
