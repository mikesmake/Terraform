param (
    [parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [string]$OrganizationName,
    [parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [string]$Pat,
    [parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [string]$agentaccount,
    [parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [string]$agentpass,
    [parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [string]$pool
)



$userName = $agentaccount
$userPassword = $agentpass


$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -force

$credObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)


Invoke-Command -FilePath "C:\Scripts\AzureDevOps\DeployAgent.ps1" -ComputerName AGTPOOL01 -ArgumentList $OrganizationName, $Pat, $agentaccount, $agentpass, $pool -Credential $credObject
Invoke-Command -FilePath "C:\Scripts\AzureDevOps\DeployAgent.ps1" -ComputerName AGTPOOL02 -ArgumentList $OrganizationName, $Pat, $agentaccount, $agentpass, $pool -Credential $credObject
Invoke-Command -FilePath "C:\Scripts\AzureDevOps\DeployAgent.ps1" -ComputerName AGTPOOL03 -ArgumentList $OrganizationName, $Pat, $agentaccount, $agentpass, $pool -Credential $credObject
Invoke-Command -FilePath "C:\Scripts\AzureDevOps\DeployAgent.ps1" -ComputerName AGTPOOL04 -ArgumentList $OrganizationName, $Pat, $agentaccount, $agentpass, $pool -Credential $credObject
Invoke-Command -FilePath "C:\Scripts\AzureDevOps\DeployAgent.ps1" -ComputerName AGTPOOL05 -ArgumentList $OrganizationName, $Pat, $agentaccount, $agentpass, $pool -Credential $credObject

