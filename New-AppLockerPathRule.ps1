function New-AppLockerPathRule {
    param (
        [Parameter(Mandatory=$True)]
        [string] $FilePath,

        [Parameter(Mandatory=$True)]
        [string] $TicketNumber,

        [ValidateSet ("XML", "Shell")]
        [Parameter(Mandatory=$True)]
        [string] $Output,
        
        [ValidateSet ("Append", "Clear")]
        [Parameter(Mandatory=$False)]
        [String] $Intent = "Append",

        [Parameter(Mandatory=$False)]
        [switch] $SuppressMessage
    )

    $GUID = (New-GUID).GUID
    $User = (whoami) -replace "^.*\\","" -replace "[a-z]$"
    $FilePathTrimmed = $FilePath -replace "`"|'"

    if ($Output -eq "Shell") {
    Write-Host "<FilePathRule Id=`"$GUID`" Name=`"$FilePathTrimmed`" Description=`"InTicket: $TicketNumber - $User`" UserOrGroupSid=`"S-1-1-0`" Action=`"Allow`">"
    Write-Host "    <Conditions>"
    Write-Host "        <FilePathCondition Path=`"$FilePathTrimmed`" />"
    Write-Host "    </Conditions>"
    Write-Host "</FilePathRule>"
    }
    if ($Output -eq "XML"){
        $FilePath = "$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml"
        $FolderPath = Split-Path -Parent $FilePath
    
        if (!(Test-Path -Path $FolderPath)) {
            New-Item -ItemType Directory -Path $FolderPath -Force | Out-Null
        }

        $XML = @"
<FilePathRule Id="$GUID" Name="$FilePathTrimmed" Description="InTicket: $TicketNumber - $User" UserOrGroupSid="S-1-1-0" Action="Allow">
  <Conditions>
        <FilePathCondition Path="$FilePathTrimmed" />
  </Conditions>
</FilePathRule>
"@

        if ($Intent -eq "Clear") {
            Remove-Item -Path "$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml" -Force -ErrorAction SilentlyContinue 
            $XML | Out-File -FilePath "$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml" -Encoding UTF8 -Force
        }
        
        if ($Intent -eq "Append") {
            $XML | Out-File -FilePath "$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml" -Encoding UTF8 -Append -Force
        }

        if (-not $SuppressMessage) {
            Write-Host "The XML file can be located here: '$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml'"
        }
    }
}