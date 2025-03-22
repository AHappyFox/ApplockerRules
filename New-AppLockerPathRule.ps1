function New-AppLockerPathRule {
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

    if ($Output -eq "Shell") {
    Write-Host "<FilePathRule Id=`"$GUID`" Name=`"$FilePathTrimmed`" Description=`"$Description`" UserOrGroupSid=`"S-1-1-0`" Action=`"Allow`">"
    Write-Host "    <Conditions>"
    Write-Host "        <FilePathCondition Path=`"$FilePathTrimmed`" />"
    Write-Host "    </Conditions>"
    Write-Host "</FilePathRule>"
    }
    if ($Output -eq "XML"){
        $FilePath = "$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml"
        $FolderPath = Split-Path -Parent $FilePath
    
        # Ensure the folder exists before writing
        if (!(Test-Path -Path $FolderPath)) {
            New-Item -ItemType Directory -Path $FolderPath -Force | Out-Null
        }
        
        $XML = @"
<FilePathRule Id="$GUID" Name="$FilePathTrimmed" Description="$Description" UserOrGroupSid="S-1-1-0" Action="Allow">
  <Conditions>
        <FilePathCondition Path="$FilePathTrimmed" />
  </Conditions>
</FilePathRule>
"@
    $XML | Out-File -FilePath "$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml" -Encoding UTF8 -Append -Force
    }

    if ($Output -eq "XML") {
        Write-Host "The XML file can be located here: '$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml'"
        }
}