function New-AppLockerHashRule {
    param (
        [Parameter(Mandatory=$True)]
        [string] $FilePath,

        [Parameter(Mandatory=$False)]
        [string] $Description,

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
$FilePathTrimmed = $FilePath -replace "`"|'"
$HashInfo = (Get-AppLockerFileInformation -Path $FilePathTrimmed).Hash
$Algorithm, $FileHash = $HashInfo -split '\s+', 2
$FileLength = (Get-Item -Path $FilePathTrimmed).Length
$FileName = Split-Path -Path $FilePathTrimmed -Leaf

    if ($Output -eq "Shell") {
    Write-Host "<FileHashRule Id=`"$GUID`" Name=`"$FileName`" Description=`"$Description`" UserOrGroupSid=`"S-1-1-0`" Action=`"Allow`">"
    Write-Host "    <Conditions>"
    Write-Host "        <FileHashCondition>"
    Write-Host "            <FileHash Type=`"$Algorithm`" Data=`"$FileHash`" SourceFileName=`"$FileName`" SourceFileLength=`"$FileLength`" />"
    Write-Host "        </FileHashCondition>"
    Write-Host "    </Conditions>"
    Write-Host "</FileHashRule>"
    }
    if ($Output -eq "XML"){
        $FilePath = "$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml"
        $FolderPath = Split-Path -Parent $FilePath
    
        if (!(Test-Path -Path $FolderPath)) {
            New-Item -ItemType Directory -Path $FolderPath -Force | Out-Null
        }

        $XML = @"
<FileHashRule Id="$GUID" Name="$FileName" Description="$Description" UserOrGroupSid="S-1-1-0" Action="Allow">
  <Conditions>
      <FileHashCondition>
          <BinaryVersionRange LowSection="*" HighSection="*" />
            <FileHash Type="$Algorithm" Data="$FileHash" SourceFileName="$FileName" SourceFileLength="$FileLength" />
      </FileHashCondition>
  </Conditions>
</FileHashRule>
"@

        if ($Intent -eq "Clear") {
            Remove-Item -Path "$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml" -Force -ErrorAction SilentlyContinue
            $XML | Out-File -FilePath "$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml" -Encoding UTF8 -Force
        }
        if ($Intent -eq "Append") {
            $XML | Out-File -FilePath "$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml" -Encoding UTF8 -Append -Force
        }

    }

    if (-not $SuppressMessage) {
        Write-Host "The XML file can be located here: '$env:USERPROFILE\Documents\AppLocker\AppLockerRules.xml'"
    }
}