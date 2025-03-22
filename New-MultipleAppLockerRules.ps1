function New-MultipleAppLockerRules {
    param (
        [Parameter(Mandatory=$True)]
        [string] $FilePath,

        [Parameter(Mandatory=$False)]
        [string] $Description,

        [ValidateSet ("XML", "Shell")]
        [Parameter(Mandatory=$True)]
        [string] $Output,

        [Parameter(Mandatory=$False)]
        [switch] $SuppressMessage
    )

    $Files = (Get-ChildItem -Path $FilePath).FullName
    if (Test-Path -Path "$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml") {
        Remove-Item -Path "$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml" -Force
    }

    foreach ($File in $Files) {
        $IsSigned = (Get-AppLockerFileInformation -Path $File).Publisher
        if ($null -eq ($IsSigned)) {
            New-AppLockerHashRule -FilePath $File -Description $Description -OutPut $Output -SuppressMessage
        }
        else {
            New-AppLockerPublisherRule -FilePath $File -Description $Description -OutPut $Output -SuppressMessage
        }
    }

    if ($Output -eq "XML") {
    Write-Host "The XML file can be located here: '$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml'"
    }
}