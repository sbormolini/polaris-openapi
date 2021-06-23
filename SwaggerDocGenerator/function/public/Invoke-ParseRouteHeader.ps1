<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Invoke-ParseRouteHeader
{
    [CmdletBinding(PositionalBinding=$false,
                   ConfirmImpact="Low")]
    [Alias()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.String]$RouteHeader, 

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.String]$InputType = "body" 

    )

    $defaultProperties = @("Input","Output")
    # create empty defintion object
    $definition = New-Object -TypeName PSCustomObject
    foreach ($item in $defaultProperties) 
    {
        $match = $RouteHeader.Trim().Split("`n") | Select-String -Pattern $item -SimpleMatch
        if ($match)
        {
            if ($item -eq "Input")
            {
                $value = @()
                $parameters = $match.Line.Trim().Split(':')[1].Split(',')
                foreach ($parameter in $parameters) 
                {
                    $typeName = ($parameter | Select-String -Pattern "\[(.*?)\]").Matches.Value.Replace('[','').Replace(']','').ToLower()
                    if ($parameter -match "\[(M|m)andatory=(.*?)\]")
                    {
                        $mandatoryValue = ($parameter | Select-String -Pattern "\[(M|m)andatory=(.*?)\]").Matches.Value.ToLower().Replace('[mandatory=','').Replace(']','').ToLower()
                        $name = $parameter.Split(']')[2]
                    }
                    else 
                    {
                        $mandatoryValue = $false
                        $name = $parameter.Split(']')[1]
                    }
                    
                    $p = [PSCustomObject]@{
                        name = $name
                        in = $InputType
                        required = [System.Convert]::ToBoolean($mandatoryValue)
                    }

                    switch ($typeName) 
                    {
                        "string" 
                        { 
                            Add-Member -InputObject $p `
                                    -MemberType NoteProperty `
                                    -Name "type" `
                                    -Value "string"
                        }
                        "int" 
                        {
                            Add-Member -InputObject $p `
                                    -MemberType NoteProperty `
                                    -Name "type" `
                                    -Value "integer"

                            Add-Member -InputObject $p `
                                    -MemberType NoteProperty `
                                    -Name "format" `
                                    -Value "int32"
                        }
                        "array" 
                        {
                            # special case?                        
                            Add-Member -InputObject $p `
                                    -MemberType NoteProperty `
                                    -Name "type" `
                                    -Value "array"

                            Add-Member -InputObject $p `
                                    -MemberType NoteProperty `
                                    -Name "items" `
                                    -Value [[PSCustomObject]@{
                                        type = Value
                                    }]
                        }
                        "datetime"
                        {
                            Add-Member -InputObject $p `
                                    -MemberType NoteProperty `
                                    -Name "type" `
                                    -Value "string"

                            Add-Member -InputObject $p `
                                    -MemberType NoteProperty `
                                    -Name "format" `
                                    -Value "date-time"
                        }
                        "enum"
                        {
                            Add-Member -InputObject $p `
                                    -MemberType NoteProperty `
                                    -Name "type" `
                                    -Value "string"
                            
                            # todo
                            Add-Member -InputObject $p `
                                    -MemberType NoteProperty `
                                    -Name "enum" `
                                    -Value @("EnumValue1","EnumValue2")
                        }
                    }
                    $value += $p
                }
            }
            elseif ($item -eq "Output")
            {
                # get class
                $value = New-Object -TypeName PSCustomObject
                $className = ($match.Line.Trim().Split(':')[1]).Replace('[','').Replace(']','')

                if ( 
                    $className.ToLower() -eq "string" -or
                    $className.ToLower() -eq "int"
                )
                {
                    Add-Member -InputObject $value `
                               -MemberType NoteProperty `
                               -Name "Type" `
                               -Value $className.ToLower()
                }
                else {
                    $blank = New-Object -TypeName $className
                    Add-Member -InputObject $value `
                               -MemberType NoteProperty `
                               -Name "Type" `
                               -Value $className

                    Add-Member -InputObject $value `
                               -MemberType NoteProperty `
                               -Name "TypeDefinition" `
                               -Value $blank.GetDefinition()
                    
                }
            }

            Add-Member -InputObject $definition `
                    -MemberType NoteProperty `
                    -Name $item `
                    -Value $value
        }
    }

    return $definition
}