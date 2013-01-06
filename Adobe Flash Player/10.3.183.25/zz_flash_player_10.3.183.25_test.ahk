/*
 * Designed for Flash Player 10.3.183.25
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
    2.SA_LoadLocalFlash
    3.SA_LoadOnlineFlash

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

            if 1 = 2.SA_LoadLocalFlash
            {
                #include SA_LoadLocalFlash.ahk ; StandAlone Flash Player: play locally located SWF
            }
            else if 1 = 3.SA_LoadOnlineFlash ; StandAlone Flash Player: play online located SWF
            {
                #include SA_LoadOnlineFlash.ahk
            }
        }
    }
}

ShowTestResults()
