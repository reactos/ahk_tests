/*
 * Designed for Opera v9.64
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
    2.AddressBar
    3.Download
    4.FlashPlayer
    5.CloseDownload
    6.speed_dial
    7.launch_widget
    8.search_bar

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

            if 1 = 2.AddressBar
            {
                #include AddressBar.ahk
            }
            else if 1 = 3.Download
            {
                #include Download.ahk
            }
            else if 1 = 4.FlashPlayer
            {
                #include FlashPlayer.ahk
            }
            else if 1 = 5.CloseDownload
            {
                #include CloseDownload.ahk
            }
            else if 1 = 6.speed_dial
            {
                #include speed_dial.ahk
            }
            else if 1 = 7.launch_widget
            {
                #include launch_widget.ahk
            }
            else if 1 = 8.search_bar
            {
                #include search_bar.ahk
            }
        }
    }
}

ShowTestResults()
