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
function New-SwaggerInfo
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
        [System.String]$Description, 

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.String]$Version,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.String]$Title,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.String]$TermsOfService,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 4
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.String]$Email,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 5
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.String]$LicenseName,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 6
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.String]$LicenseUrl
    )

    if (
        ($null -ne $LicenseName) -and
        ($null -ne $LicenseUrl) -and
        ($null -ne $TermsOfService)
    )
    {
        $info = [SwaggerInfo]::New($Description, $Version, $Title, $TermsOfService, $Email, $LicenseName, $LicenseUrl)
    }
    else 
    {
        $info = [SwaggerInfo]::New($Description, $Version, $Title, $Email)
    }
    
    return $info 
}