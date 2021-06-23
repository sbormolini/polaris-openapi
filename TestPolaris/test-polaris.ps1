Import-Module Polaris

# Get Example
New-PolarisRoute -Method GET `
                 -Path "/users" `
                 -ScriptPath "$($PSScriptRoot)\api_scriptblock.ps1"

# Post Example
New-PolarisRoute -Method POST `
                 -Path "/users" `
                 -Scriptblock {
                    <#API:Definition
                     Input:[string][Mandatory=true]Name,[int]Age
                     Output:[TestUser]
                     #>
                    $Response.Send($Request.BodyString);
                 } 

# Put Example
New-PolarisRoute -Method PUT `
                 -Path "/users" `
                 -Scriptblock {
                    $Response.Send($json);
                 }

# Delete Example
New-PolarisRoute -Method DELETE `
                 -Path "/users" `
                 -Scriptblock {
                    $Response.Send($json);
                }


New-PolarisGetRoute  -Path '/policies' -ScriptBlock {

   $Response.Json('{}')
}

# start
Start-Polaris





<# cleanup

Stop-Polaris
Clear-Polaris

#>