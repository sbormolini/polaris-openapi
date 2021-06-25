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
function New-SwaggerDocGenerator
{
    [CmdletBinding()]
    [Alias()]

    Param
    (
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Polaris')]
        [String]$Type = "Polaris",

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$Url,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$APIVersion,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$Title,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 4
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$Description,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 5
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$DocumentVersion,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 6
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$ContactEmail
    )

    return [SwaggerDocGenerator]::New($Type, $Url, $APIVersion, $Title, $Description, $DocumentVersion, $ContactEmail)
}