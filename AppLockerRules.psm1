$ScriptPath = $PSScriptRoot

Get-ChildItem -Path $ScriptPath -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
}

#I am lazy, and have no clue how this works as of now, so GPT takes the reins :)