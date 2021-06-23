<#
    swagger ui config file wrapper
#>


#Region Classes
class SwaggerFile
{
    Hidden [Guid] $Id
    Hidden [String] $Name
    
    [String] $swagger = "2.0"
    [Object] $info
    [String] $host
    [String] $basePath
    [Object] $tags
    [Object] $schemes
    [Object] $paths
    [Object] $securityDefinitions
    [Object] $definitions
    [Object] $externalDocs
    
    # const
	SwaggerFile ()
	{
		$this.Id = [guid]::NewGuid()
    }
    
    static [SwaggerFile] GenerateFromPolaris()
    {

        return New-Object -TypeName SwaggerFile
    }
}

$a = [SwaggerFile]::GenerateFromPolaris()
$a

$b = [SwaggerFile]::New()
$b