/*
 * Designed for Double Commander 0.5.4
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
RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Double Commander_is1, UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    UninstallerPath := ExeFilePathNoParam(UninstallerPath) ; Remove quotes
    SplitPath, UninstallerPath,, InstalledDir
    if (InstalledDir = "")
        TestsFailed("Either registry contains empty string or we failed to read it.")
    else
    {
        ModuleExe = %InstalledDir%\doublecmd.exe
        TestsOK("")
    }
}


; Terminate application
if bContinue
{
    SplitPath, ModuleExe, ProcessExe
    bTerminateProcess(ProcessExe)
}


; Delete settings separately from RunApplication() in case we want to write our own settings
TestsTotal++
if bContinue
{
    IfExist, %A_AppData%\doublecmd
    {
        FileRemoveDir, %A_AppData%\doublecmd, 1
        if ErrorLevel
            TestsFailed("Unable to delete '" A_AppData "\doublecmd'.")
        else
            TestsOK("")
    }
    else
        TestsOK("")
}


; Write settings
WriteSettings()
{
    global TestName
    global TestsTotal
    global bContinue
    global szPathLeft

    TestsTotal++
    if bContinue
    {
        szPathLeft = %A_AppData%\doublecmd\TestPath ; The path we gonna see in left side of app window
        FileCreateDir, %szPathLeft%
        if ErrorLevel
            TestsFailed("WriteSettings(): Unable to create '" szPathLeft "' directory.")
        else
        {
            szSettingsFile = %A_AppData%\doublecmd\doublecmd.xml
            ; FileEncoding, UTF-8
            FileAppend,
            (
            <?xml version="1.0" encoding="utf-8"?>
            <doublecmd DCVersion="0.5.4 beta" ConfigVersion="1">
            <Tabs>
                <Options>785</Options>
                <CharacterLimit>32</CharacterLimit>
                <Position>0</Position>
                <OpenedTabs>
                  <Left>
                    <ActiveTab>0</ActiveTab>
                    <Tab>
                      <FileView Type="columns">
                        <History>
                          <Entry Active="True">
                            <FileSource Type="FileSystem"/>
                            <Paths>
                              <Path>%szPathLeft%</Path>
                            </Paths>
                          </Entry>
                        </History>
                      </FileView>
                    </Tab>
                  </Left>
                </OpenedTabs>
              </Tabs>
            </doublecmd>
            ), %szSettingsFile%
            if ErrorLevel
                TestsFailed("WriteSettings(): Unable to create '" szSettingsFile "'.")
            else
                TestsOK("")
        }
    }
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
            TestsFailed("RunApplication(): Can NOT find '" ModuleExe "'.")
        else
        {
            Run, %ModuleExe% ; Max doesn't work here
            WinWaitActive, Double Commander,,5
            if ErrorLevel
            {
                Process, Exist, %ProcessExe%
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("RunApplication(): Window 'Double Commander' failed to appear. No '" ProcessExe "' process detected.")
                else
                    TestsFailed("RunApplication(): Window 'Double Commander' failed to appear. '" ProcessExe "' process detected.")
            }
            else
            {
                WinMaximize, Double Commander
                TestsOK("")
            }
        }
    }
}
