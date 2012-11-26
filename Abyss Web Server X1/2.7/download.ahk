/*
 * Designed for Abyss Web Server X1 2.7
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

TestName = 2.download

; Test if can download file from http://localhost/
TestsTotal++
RunApplication("")
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    szDocument =  %InstalledDir%\htdocs\pwrabyss.gif ; File in localhost. Case insensitive. 'pwrabyss.gif' is installed by Abyss
    iFileSizeHard := 1895 ; bytes
    IfNotExist, %szDocument%
        TestsFailed("Can NOT find'" szDocument "'.")
    else
    {
        FileGetSize, iFileSize, %szDocument% ; Get file size
        if ErrorLevel
            TestsFailed("Unable to get file size of existing '" szDocument "'.")
        else
        {
            if (iFileSize != iFileSizeHard) ; We should make sure file size is correct before getting file size of downloaded file
                TestsFailed("FileGetSize returned unexpected file size (is '" iFileSize "', should be '" iFileSizeHard "').")
            else
            {
                SplitPath, szDocument, szFileName ; Get filename from path
                szLocalFile = C:\%szFileName%
                UrlDownloadToFile, http://localhost/%szFileName%, C:\%szFileName%
                if ErrorLevel
                    TestsFailed("Unable to download existing 'http://localhost/" szFileName "' to '" szLocalFile "'.")
                else
                {
                    FileGetSize, iFileSize, %szLocalFile% ; Get file size of downloaded file
                    if ErrorLevel
                        TestsFailed("Unable to get file size of downloaded '" szLocalFile "'.")
                    else
                    {
                        if (iFileSize != iFileSizeHard)
                            TestsFailed("FileGetSize returned unexpected file size of downloaded file (is '" iFileSize "', should be '" iFileSizeHard "').")
                        else
                            TestsOK("Downloaded 'http://localhost/" szFileName "' to '" szLocalFile "' and file size is correct.")
                    }
                }
            }
        }
    }
}

TerminateAbyss()
