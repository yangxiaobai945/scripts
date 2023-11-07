# install Microsoft.WinGet.Client module first,need powershell 5.1 or later
# https://www.powershellgallery.com/packages/Microsoft.WinGet.Client
# Install-Module -Name Microsoft.WinGet.Client
function Update-SelectedWinGetPackages {
    [CmdletBinding()]
    param()

    # install Microsoft.WinGet.Client module first,need powershell 5.1 or later
    # https://www.powershellgallery.com/packages/Microsoft.WinGet.Client
    # Install-Module -Name Microsoft.WinGet.Client
    Import-Module -Name Microsoft.WinGet.Client

    $Outdated = Get-WinGetPackage | Where-Object { $_.IsUpdateAvailable -eq $true }
    # copy $Outdated to $OutdatedWithUpdateFlag,add NeedUpdate property,boolean
    $OutdatedWithUpdateFlag = $Outdated | Select-Object * | Add-Member -MemberType NoteProperty -Name NeedUpdate -Value $true -PassThru
    Write-Output "press q/Q to quit,press y/Y or enter to update,press space or n/N to skip"
    foreach ($App in $OutdatedWithUpdateFlag) {
        Write-Host "Update $($App.Name) to $($App.AvailableVersions[0])? [y/n/q]"
        # set cursor to the beginning of the line
        # get key binding from user
        $Key = [System.Console]::ReadKey($true)
        # if press space or n/N,then no
        if ($Key.Key -eq "Spacebar" -or $Key.Key -eq "n" -or $Key.Key -eq "N") {
            $App.NeedUpdate = $false
            # move cursor to the beginning of this line
            # [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop - 1)
            # output red color text
            Write-Host "Skip to update" -ForegroundColor Red

        }
        # if press y/Y or enter,then add app.id to $UpdateListCommand
        elseif ($Key.Key -eq "y" -or $Key.Key -eq "Y" -or $Key.Key -eq "Enter") {
            # output green color text
            Write-Host "Yes,Update it" -ForegroundColor Green

        }
        # if press q/Q,then quit
        elseif ($Key.Key -eq "q" -or $Key.Key -eq "Q") {
            Write-Host "Quit" -ForegroundColor Yellow
            exit
        }

    }
    $UpdateList = ""
    $UpdateListCommand = ""
    # filter $OutdatedWithUpdateFlag by NeedUpdate property,and output filtered result
    $OutdatedWithUpdateFlag | Where-Object { $_.NeedUpdate -eq $true } | Select-Object -ExpandProperty Id | 
    ForEach-Object {
        # generate winget update command like "winget upgeade item1;winget upgrade item2;winget upgrade item3"
        $UpdateList += "$_ "
        $UpdateListCommand += "winget upgrade $_;"

    } -End {
        write-host "ensure update list: $UpdateList"
        write-host "press y/Y or enter to update,press space or n/N to skip,press q/Q to quit"
        # get key binding from user
        $Key = [System.Console]::ReadKey($true)
        # if press enter or y/Y,then invoke
        if ($Key.Key -eq "y" -or $Key.Key -eq "Y" -or $Key.Key -eq "Enter") {
            Invoke-Expression $UpdateListCommand
        }
        # if press space or q/Q,then skip
        elseif ($Key.Key -eq "Spacebar" -or $Key.Key -eq "q" -or $Key.Key -eq "Q") {
            Write-Host "skip update"
            exit
        }
    }
}

