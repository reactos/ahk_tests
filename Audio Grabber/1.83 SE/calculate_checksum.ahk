/*
 * Designed for Audio Grabber 1.83 SE
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

TestName = 2.calculate_checksum
szDocument = %A_WorkingDir%\Media\chimpanzee.wav

; Test if can calculate checksum and close application
TestsTotal++
RunApplication()
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfNotExist, %szDocument%
        TestsFailed("Unable to find '" szDocument "'.")
    else
    {
        IfWinNotActive, Audiograbber
            TestsFailed("'Audiograbber' is not an active window.")
        else
        {
            WinMenuSelectItem, Audiograbber, , File, Calculate checksum
            if ErrorLevel
                TestsFailed("Unable to hit 'File->Calculate checksum' in 'Audiograbber' window.")
            else
            {
                WinWaitActive, Calculate Checksum,,3
                if ErrorLevel
                    TestsFailed("'Calculate Checksum' window failed to appear.")
                else
                {
                    ControlClick, TBitBtn3, Calculate Checksum ; Hit 'Browse' button
                    if ErrorLevel
                        TestsFailed("Unable to hit 'Browse' button in 'Calculate Checksum' window.")
                    else
                    {
                        WinWaitActive, Select a file for checksum calculation,,3
                        if ErrorLevel
                            TestsFailed("'Select a file for checksum calculation' window failed to appear.")
                        else
                            TestsOK("'Select a file for checksum calculation' window appeared.")
                    }
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    ControlSetText, Edit1, %szDocument%, Select a file for checksum calculation
    if ErrorLevel
        TestsFailed("Unable to enter '" szDocument "' as 'File name' in 'Select a file for checksum calculation' window.")
    else
    {
        ControlClick, Button2, Select a file for checksum calculation ; Hit 'Open' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Open' button in 'Select a file for checksum calculation' window.")
        else
        {
            WinWaitClose, Select a file for checksum calculation,,3
            if ErrorLevel
                TestsFailed("'Select a file for checksum calculation' window failed to close despite 'Open' button being clicked.")
            else
            {
                WinWaitActive, Calculate Checksum,,3
                if ErrorLevel
                    TestsFailed("'Calculate Checksum' window did not became active after closing 'Select a file for checksum calculation' window.")
                else
                {
                    ControlClick, TBitBtn1, Calculate Checksum ; Hit 'Calculate' button
                    if ErrorLevel
                        TestsFailed("Unable to hit 'Calculate' button in 'Calculate Checksum' window.")
                    else
                    {
                        ControlGetText, ChecksumText, TEdit2
                        if ErrorLevel
                            TestsFailed("Unable to get text from 'The Checksum is' field in 'Calculate Checksum' window.")
                        else
                            TestsOK("Loaded file and calculated checksum.")
                    }
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    szChecksum = X2E1539D0X
    if (ChecksumText != szChecksum)
        TestsFailed("Wrong checksum (is '" ChecksumText "', should be '" szChecksum "').")
    else
    {
        WinClose, Calculate Checksum
        WinWaitClose,,,3
        if ErrorLevel
            TestsFailed("'Calculate Checksum' window failed to close.")
        else
        {
            WinWaitActive, Audiograbber,,3
            if ErrorLevel
                TestsFailed("'Audiograbber' did no became active after closing 'Calculate Checksum' window.")
            else
            {
                WinClose, Audiograbber
                WinWaitClose,,,3
                if ErrorLevel
                    TestsFailed("Unable to close 'Audiograbber' window.")
                else
                {
                    Process, WaitClose, %ProcessExe%, 4
                    if ErrorLevel
                        TestsFailed("'" ProcessExe "' process failed to close despite 'Audiograbber' window was closed.")
                    else
                        TestsOK("Checksum was the same as expected. Closed app successfully.")
                }
            }
        }
    }
}
