<#API:Definition
    ParameterMethod:Body
    Input:[string][Mandatory=true]Name,[int][Mandatory=false]Age
    Output:[TestUser]
#>

#Import-Module "$($PSScriptRoot)\TestClass\TestClass.psm1" -Force
Import-Module "C:\Users\sandr\OneDrive - itnetX AG\Customers\Swisscom\Polaris\TestClass\TestClass.psm1" -Force

$list = New-Object System.Collections.Generic.List[Object]

# add user to list 
#$list.Add([TestUser]::New("Hans Peter",23))
$list.Add((New-TestUser -Name "Jenny" -Age 44))
$list.Add((New-TestUser -Name "Caro" -Age 44))
$json = ConvertTo-Json -InputObject $list

return $Response.Json($json)