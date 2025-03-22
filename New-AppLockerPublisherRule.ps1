function New-AppLockerPublisherRule {
    param (
        [Parameter(Mandatory=$True)]
        [string] $FilePath,

        [Parameter(Mandatory=$False)]
        [string] $Description,

        [ValidateSet ("XML", "Shell")]
        [Parameter(Mandatory=$True)]
        [string] $Output
    )

    $GUID = (New-GUID).GUID
    $FilePathTrimmed = $FilePath -replace "`"|'"
    $Publisher = (Get-AppLockerFileInformation -Path $FilePathTrimmed).Publisher
    $TrimmedPublisher = $Publisher -replace '\\.*$',''

    if ($Output -eq "Shell") {
    Write-Host "<FilePublisherRule Id=`"$GUID`" Name=`"Signed by $TrimmedPublisher`" Description=`"$Description`" UserOrGroupSid=`"S-1-1-0`" Action=`"Allow`">"
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

        if (Test-Path -Path "$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml") {
            #Remove-Item -Path "$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml" -Force 
            #This didn't work as expected when creating rules in bulk :)
        }
        
        $XML = @"
<FilePublisherRule Id="$GUID" Name="Signed by $TrimmedPublisher" Description="$Description" UserOrGroupSid="S-1-1-0" Action="Allow">
  <Conditions>
      <FilePublisherCondition PublisherName="$TrimmedPublisher" ProductName="*" BinaryName="*">
          <BinaryVersionRange LowSection="*" HighSection="*" />
      </FilePublisherCondition>
  </Conditions>
</FilePublisherRule>
"@
        $XML | Out-File -FilePath "$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml" -Encoding UTF8 -Append -Force
    }

    if ($Output -eq "XML") {
        Write-Host "The XML file can be located here: '$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml'"
        }
}