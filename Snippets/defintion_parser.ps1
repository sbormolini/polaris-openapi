$block1 = "
<#
Input:[string][Mandatory=true]Name,[int][Mandatory=false]Age
Output:[TestUser]
#>
"

$block2 = "
<#
Input:[string][Mandatory=true]Name,[int][Mandatory=false]Age
Output:[string]
#>
"

function Get-ParseAPICommentBlock
{
    param
    (
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$FilePath
    )

    $matchStart = Get-ChildItem -Path $filePath | 
        Select-String -Pattern '<#API:Definition'

    $matchEnd = Get-ChildItem -Path $filePath | 
        Select-String -Pattern '#>'

    if  ($matchStart.LineNumber -ne 1)
    {
        Write-Warning -Message "API Defintion not found at the begin of script"
    }

    $section = Get-Content -Path $filePath  | 
        Select-Object -First $matchEnd.LineNumber

    return $section
}

function Invoke-ParseAPICommentBlock
{
    param
    (
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.String]$APICommentBlock, 

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
        $match = $APICommentBlock.Trim().Split("`n") | Select-String -Pattern $item -SimpleMatch
        if ($match)
        {
            if ($item -eq "Input")
            {
                $value = @()
                $parameters = $match.Line.Trim().Split(':')[1].Split(',')
                foreach ($parameter in $parameters) 
                {
                    $typeName = ($parameter | Select-String -Pattern "\[(.*?)\]").Matches.Value.Replace('[','').Replace(']','').ToLower()
                    $madatoryValue = ($parameter | Select-String -Pattern "\[(M|m)andatory=(.*?)\]").Matches.Value.ToLower().Replace('[mandatory=','').Replace(']','').ToLower()

                    $p = [PSCustomObject]@{
                        name = $parameter.Split(']')[2]
                        in = $InputType
                        required = [bool]$madatoryValue
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

# test
$definition1 = Invoke-ParseAPICommentBlock -APICommentBlock $block1
$definition2 = Invoke-ParseAPICommentBlock -APICommentBlock $block2

$definition1 | ConvertTo-Json
$definition2 | ConvertTo-Json