[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$SshHost = '159.223.146.168',

    [ValidateNotNullOrEmpty()]
    [string]$SshUser = 'root'
)

$ErrorActionPreference = 'Stop'

$remoteHost = '{0}@{1}' -f $SshUser, $SshHost
$password = & ssh $remoteHost "sed -n 's/^APPLICATION_PASSWORD=//p' /etc/saranutri/gemstone-credentials"

if ($LASTEXITCODE -ne 0) {
    throw "Could not read the production GemStone password through SSH."
}

$password = ($password -join "`n").Trim()
if ([string]::IsNullOrWhiteSpace($password)) {
    throw "The production GemStone password was empty or missing."
}

Set-Clipboard -Value $password
Write-Host 'Production GemStone password copied to the clipboard.'
