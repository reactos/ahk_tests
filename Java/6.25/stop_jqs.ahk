/*
 * Designed for Java 6.25
 * Copyright (C) 2016 Sylvain Petreolle
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

TestName = 3.stop_jqs
Process, Exist, jqs.exe
if ErrorLevel
{
    TestsTotal++
    Run sc.exe stop JavaQuickStarterService
    Process, WaitClose, jqs.exe, 30.0
    If ErrorLevel
        TestsFailed("Unable to stop JavaQuickStarterService")
    Else
        TestsOK("Successfully stopped JavaQuickStarterService")
}
