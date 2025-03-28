function New-AppLockerManualRule {
    param (
        [ValidateSet ("Publisher", "Path")]
        [Parameter(Mandatory=$True)]
        [string] $RuleType,

        [Parameter (Mandatory=$True)]
        [string] $InputData,

        [Parameter(Mandatory=$True)]
        [string] $TicketNumber
    )

    $GUID = (New-GUID).GUID
    $User = (whoami) -replace "^.*\\","" -replace "[a-z]$"

    if ($RuleType -eq "Publisher") {
        Write-Host "<FilePublisherRule Id=`"$GUID`" Name=`"Signed by $InputData`" Description=`"InTicket: $TicketNumber - $User`" UserOrGroupSid=`"S-1-1-0`" Action=`"Allow`">"
        Write-Host "  <Conditions>"
        Write-Host "      <FilePublisherCondition PublisherName=`"$InputData`" ProductName=`"*`" BinaryName=`"*`">"
        Write-Host "          <BinaryVersionRange LowSection=`"*`" HighSection=`"*`" />"
        Write-Host "      </FilePublisherCondition>"
        Write-Host "  </Conditions>"
        Write-Host "</FilePublisherRule>"
    }

    if ($RuleType -eq "Path") {
        Write-Host "<FilePathRule Id=`"$GUID`" Name=`"$InputData`" Description=`"$Description`" UserOrGroupSid=`"S-1-1-0`" Action=`"Allow`">"
        Write-Host "    <Conditions>"
        Write-Host "        <FilePathCondition Path=`"$InputData`" />"
        Write-Host "    </Conditions>"
        Write-Host "</FilePathRule>"
    }

}