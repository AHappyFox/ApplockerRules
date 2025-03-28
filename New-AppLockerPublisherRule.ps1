function New-AppLockerPublisherRule {
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

    ##bare en test
    $GUID = (New-GUID).GUID
    $User = (whoami) -replace "^.*\\","" -replace "[a-z]$"
    $FilePathTrimmed = $FilePath -replace "`"|'"
    $Publisher = (Get-AppLockerFileInformation -Path $FilePathTrimmed).Publisher
    $TrimmedPublisher = $Publisher -replace '\\.*$',''

    if ($Output -eq "Shell") {
    Write-Host "<FilePublisherRule Id=`"$GUID`" Name=`"Signed by $TrimmedPublisher`" Description=`"InTicket: $TicketNumber - $User`" UserOrGroupSid=`"S-1-1-0`" Action=`"Allow`">"
    Write-Host "  <Conditions>"
    Write-Host "      <FilePublisherCondition PublisherName=`"$TrimmedPublisher`" ProductName=`"*`" BinaryName=`"*`">"
    Write-Host "          <BinaryVersionRange LowSection=`"*`" HighSection=`"*`" />"
    Write-Host "      </FilePublisherCondition>"
    Write-Host "  </Conditions>"
    Write-Host "</FilePublisherRule>"
    }
    if ($Output -eq "XML"){
        $FilePath = "$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml"
        $FolderPath = Split-Path -Parent $FilePath
    
        if (!(Test-Path -Path $FolderPath)) {
            New-Item -ItemType Directory -Path $FolderPath -Force | Out-Null
        }

        $XML = @"
<FilePublisherRule Id="$GUID" Name="Signed by $TrimmedPublisher" Description="InTicket: $TicketNumber - $User" UserOrGroupSid="S-1-1-0" Action="Allow">
  <Conditions>
      <FilePublisherCondition PublisherName="$TrimmedPublisher" ProductName="*" BinaryName="*">
          <BinaryVersionRange LowSection="*" HighSection="*" />
      </FilePublisherCondition>
  </Conditions>
</FilePublisherRule>
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
