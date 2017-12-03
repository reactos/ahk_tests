/*
 * Designed for Total Commander 8.0
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

TestName = 3.ftp_connect
 
; Check if can connect to FTP and download a file
TestsTotal++
RunApplication()
if bContinue
{
    IfWinNotActive, Total Commander 8.0 - NOT REGISTERED
        TestsFailed("'Total Commander 8.0 - NOT REGISTERED' is not active window.")
    else
    {
        WinMenuSelectItem, Total Commander 8.0 - NOT REGISTERED, , Net, FTP Connect
        if ErrorLevel
            TestsFailed("Unable to hit 'Net -> FTP Connect...' in 'Total Commander 8.0 - NOT REGISTERED' window.")
        else
        {
            WinWaitActive, Connect to ftp server,,3
            if ErrorLevel
                TestsFailed("'Connect to ftp server' window failed to appear despite 'Net -> FTP Connect...' being clicked.")
            else
            {
                ControlClick, TButton9, Connect to ftp server ; Hit 'New connection' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'New connection' button in 'Connect to ftp server' window.")
                else
                {
                    WinWaitActive, FTP: connection details,,3
                    if ErrorLevel
                        TestsFailed("'FTP: connection details' window failed to appear despite 'New connection' button being clicked in 'Connect to ftp server' window.")
                    else
                        TestsOK("'FTP: connection details' window appeared.")
                }
            }
        }
    }
}

szHost := "130.89.149.21:21"
szTheFile = welcome.txt
iExpectedFileSize := 1349

TestsTotal++
if bContinue
{
    ControlSetText, TAltEdit6, Session_name, FTP: connection details ; Fill 'Session:' field
    if ErrorLevel
        TestsFailed("Unable to fill 'Session:' field in 'FTP: connection details' window.")
    else
    {
        ControlSetText, TAltEdit5, %szHost%, FTP: connection details ; Fill 'Host name[:Port]:' field
        if ErrorLevel
            TestsFailed("Unable to fill 'Host name[:Port]:' field in 'FTP: connection details' window.")
        else
        {
            ControlSetText, TAltEdit4, anonymous, FTP: connection details ; Fill 'User name:' field
            if ErrorLevel
                TestsFailed("Unable to fill 'User name:' field in 'FTP: connection details' window.")
            else
            {
                ControlSetText, TAltEdit2, %A_Desktop%, FTP: connection details ; Fill 'Local dir:' field
                if ErrorLevel
                    TestsFailed("Unable to fill 'Local dir:' field in 'FTP: connection details' window.")
                else
                {
                    ControlClick, TButton8, FTP: connection details ; Hit 'OK' button
                    if ErrorLevel
                        TestsFailed("Unable to hit 'OK' button in 'FTP: connection details' window.")
                    else
                    {
                        WinWaitClose, FTP: connection details,,3
                        if ErrorLevel
                            TestsFailed("'FTP: connection details' window failed to close despite 'OK' button being closed.")
                        else
                            TestsOK("Successfully filled connection details.")
                    }
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    WinWaitActive, Connect to ftp server,,3
    if ErrorLevel
        TestsFailed("'FTP: connection details' window closed, but 'Connect to ftp server' window did not get activated.")
    else
    {
        ControlClick, TButton10, Connect to ftp server ; Hit 'Connect' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Connect' button in 'Connect to ftp server' window.")
        else
        {
            WinWait, Connect,,3
            if ErrorLevel
                TestsFailed("'Connect' window doesn't exist, despite 'Connect' button was clicked in 'Connect to ftp server' window.")
            else
            {
                WinWaitActive, ftp - Session_name,,5
                if ErrorLevel
                    TestsFailed("'ftp - Session_name (Password)' window failed to appear.")
                else
                {
                    ControlClick, TButton3, ftp - Session_name ; Hit 'OK' button
                    if ErrorLevel
                        TestsFailed("Unable to hit 'OK' button in 'ftp - Session_name' window.")
                    else
                    {
                        WinWaitClose, ftp - Session_name,,3
                        if ErrorLevel
                            TestsFailed("'ftp - Session_name' window failed to close despite 'OK' button being clicked.")
                        else
                        {
                            WinWaitActive, Total Commander 8.0 - NOT REGISTERED,,5
                            if ErrorLevel
                                TestsFailed("'Total Commander 8.0 - NOT REGISTERED' window failed to appear. Failed to connect to FTP server.")
                            else
                                TestsOK("Successfully connected to FTP server.")
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
    WinWaitActive, Total Commander 8.0 - NOT REGISTERED,,3
    if ErrorLevel
        TestsFailed("'Total Commander 8.0 - NOT REGISTERED' window failed to appear.")
    else
    {
        IfExist, %A_Desktop%\%szTheFile%
        {
            FileDelete, %A_Desktop%\%szTheFile%
            if ErrorLevel
                TestsFailed("Unable to delete '" A_Desktop "\" szTheFile "'.")
        }

        if bContinue
        {
            ControlSetText, Edit1, get %szTheFile%, Total Commander 8.0 - NOT REGISTERED ; Enter command to download a file
            if ErrorLevel
                TestsFailed("Unable to enter command in 'Total Commander 8.0 - NOT REGISTERED' window.")
            else
            {
                ControlClick, Edit1, Total Commander 8.0 - NOT REGISTERED ; Focus command field
                if ErrorLevel
                    TestsFailed("Unable to hit on command field in 'Total Commander 8.0 - NOT REGISTERED' window.")
                else
                {
                    SendInput, {ENTER} ; Start downloading

                    ; Wait until download is done
                    iTimeOut := 10
                    while (iTimeOut > 0)
                    {
                        FileGetSize, iFileSize, %A_Desktop%\%szTheFile%
                        if not ErrorLevel
                        {
                            if (iFileSize == iExpectedFileSize)
                                break
                        }
                        Sleep, 500
                        iTimeOut--
                    }

                    IfNotExist, %A_Desktop%\%szTheFile%
                        TestsFailed("Unable to download '" szTheFile "' from '" szHost "'. Check if file still exist.")
                    else
                    {
                        FileGetSize, iFileSize, %A_Desktop%\%szTheFile%
                        if ErrorLevel
                            TestsFailed("Unable to get file size of '" A_Desktop "\" szTheFile "'. File exist!")
                        else
                        {
                            if (iFileSize != iExpectedFileSize)
                                TestsFailed("File size doesn't match. Is '" iFileSize "', should be '" iExpectedFileSize "'. Check it in '" szHost "'.")
                            else
                                TestsOK("Downloaded '" szTheFile "' and its size is the same as expected.")
                        }
                    }
                }
            }
        }
    }
}


if bContinue
{
    bTerminateProcess(ProcessExe)
}
