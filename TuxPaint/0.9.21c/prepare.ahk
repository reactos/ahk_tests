/*
 * Designed for TuxPaint 0.9.21c
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

TestName = prepare

; Test if the app is installed
TestsTotal++
RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Tux Paint_is1, UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    UninstallerPath := ExeFilePathNoParam(UninstallerPath) ; Remove quotes from path
    SplitPath, UninstallerPath,, InstalledDir]
    if (InstalledDir = "")
        TestsFailed("Either registry contains empty string or we failed to read it.")
    else
    {
        ModuleExe = %InstalledDir%\tuxpaint.exe
        TestsOK("")
    }
}


; Terminate application
TestsTotal++
if bContinue
{
    SplitPath, ModuleExe, ProcessExe
    Process, Close, %ProcessExe%
    Process, WaitClose, %ProcessExe%, 4
    if ErrorLevel
        TestsFailed("Unable to terminate '" ProcessExe "' process.")
    else
        TestsOK("")
}


; Delete settings separately from RunApplication() in case we want to write our own settings
TestsTotal++
if bContinue
{
    RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\TuxPaint
    IfExist, %A_AppData%\TuxPaint
    {
        FileRemoveDir, %A_AppData%\TuxPaint, 1
        if ErrorLevel
            TestsFailed("Unable to delete '" A_AppData "\TuxPaint'.")
        else
            TestsOK("")
    }
    else
        TestsOK("")
}


; Test if can start application
RunApplication()
{
    global ModuleExe
    global TestName
    global TestsTotal
    global bContinue
    global ProcessExe

    TestsTotal++
    if bContinue
    {
        IfNotExist, %ModuleExe%
            TestsFailed("Can NOT find '" ModuleExe "'.")
        else
        {
            Run, %ModuleExe% ; Maximize button is disabled
            WinWaitActive, Tux Paint,,5
            if ErrorLevel
            {
                Process, Exist, %ProcessExe%
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("Window 'Tux Paint' failed to appear. No '" ProcessExe "' process detected.")
                else
                    TestsFailed("Window 'Tux Paint' failed to appear. '" ProcessExe "' process detected.")
            }
            else
            {
                WinMove, 0, 0
                MouseMove, (A_ScreenWidth / 2) -50, (A_ScreenHeight / 2) -50 ; Move cursor to screen center
                MouseClick, left ; Close splash screen

                ; Wait until splash screen is properly closed. When runing app for the first time, it takes longer to load
                CoordX := 369
                CoordY := 358
                szSkinColor = 0x000000

                iTimeOut := 800
                while iTimeOut > 0
                {
                    PixelGetColor, SplashColor, %CoordX%, %CoordY% ; Tux skin color (black)
                    if ErrorLevel
                        break ; Unable to get pixel color
                    else
                    {
                        if (SplashColor = szSkinColor)
                        {
                            Sleep, 10
                            iTimeOut--
                        }
                        else
                            break ; colors do not match
                    }
                }
                
                PixelGetColor, SplashColor, %CoordX%, %CoordY% ; Tux skin color (black)
                if ErrorLevel
                    TestsFailed("Unable to get " CoordX "x" CoordY " pixel color (iTimeOut=" iTimeOut ").")
                else
                {
                    if (SplashColor = szSkinColor)
                        TestsFailed("Unable to get thru splash screen (iTimeOut=" iTimeOut ").")
                    else
                        TestsOK("Splash screen closed (iTimeOut=" iTimeOut ").")
                }
            }
        }
    }
}
