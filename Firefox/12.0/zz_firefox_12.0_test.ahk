/*
 * Designed for Mozilla Firefox 12.0
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
    2.address_bar
    3.download
    4.search_bar
    5.fullscreen
    6.prefbar_addon

)

if CheckParam()
{
    if 1 = 1.install
    {
        #include install_test.ahk
    }
    else 
    {
        if 1 != --list
        {
            #include prepare.ahk

            if 1 = 2.address_bar
            {
                #include address_bar.ahk
            }
            else if 1 = 3.download
            {
                #include download.ahk
            }
            else if 1 = 4.search_bar
            {
                #include search_bar.ahk
            }
            else if 1 = 5.fullscreen
            {
                #include fullscreen.ahk
            }
            else if 1 = 6.prefbar_addon
            {
                #include prefbar_addon.ahk
            }
        }
    }
}

ShowTestResults()
