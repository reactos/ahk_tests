[CmdletBinding()]
Param(
    [string]$Ahk2Exe = ".\Compiler\ahk2exe.exe",
    [string]$OutDir = ".\Tests"
)

if (!(Test-Path $Ahk2Exe))
{
    Write-Output "Please add AHK in the Compiler subdirectory or specify -Ahk2Exe option"
    Exit
}

if (Test-Path $OutDir)
{
    Remove-Item $OutDir\zz*_test.exe
}
else
{
    $null = New-Item -Type Directory $OutDir
}

$Tests = Get-ChildItem -Recurse -Filter "zz*.ahk"
foreach ($Test in $Tests)
{
    $In = $Test.FullName
    $Out = "$OutDir\$($Test.BaseName).exe"
    Write-Verbose "Compiling $In"
    Start-Process $Ahk2Exe "/in ""$In"" /out ""$Out""" -Wait -NoNewWindow
}
