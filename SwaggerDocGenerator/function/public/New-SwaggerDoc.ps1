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
function New-SwaggerDoc
{
    [CmdletBinding()]
    [Alias()]

    Param
    (
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.Object]$Info, 

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.String]$APIHost, 

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.String]$BasePath, 

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.Object]$Tags, 

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 4
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.Object[]]$Paths, 

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 5
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.Object[]]$SecurityDefinitions, 

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 6
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.Object[]]$Definitions, 

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 7
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.Object]$ExternalDocs
    )

    return [SwaggerDoc]::New($Info, $APIHost, $BasePath, $Tags, $Paths, $SecurityDefinitions, $Definitions, $ExternalDocs)
}