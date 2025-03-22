function Create-MultipleAppLockerRules {
    param (
        [Parameter(Mandatory=$True)]
        [string] $FilePath
    )

    $Files = (Get-ChildItem -Path $FilePath).FullName

    foreach ($File in $Files) {
        $IsSigned = (Get-AppLockerFileInformation -Path $File).Publisher
        if (($IsSigned) -eq $null) {
            #Write-Host "$File is not signed"
            New-AppLockerHashRule -FilePath $File
        }
        else {
            #Write-Host "$File is signed with ($IsSigned)"
            New-AppLockerPublisherRule -FilePath $File
        }
    }
}