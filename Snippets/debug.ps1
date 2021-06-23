<# tests
$info = [SwaggerInfo]::New(
    "This is a sample server",
    "1.0.5",
    "Swagger Petstore",
    $null,
    "apiteam@swagger.io",
    "Apache 2.0",
    "http://www.apache.org/licenses/LICENSE-2.0.html"
)

$tag = [SwaggerTag]::New(
    "store",
    "Access to Petstore orders"
)


# just sample not in use maybe
$securityDefinitions = [PSCustomObject]@{
    api_key = [PSCustomObject]@{
        type = "apiKey"
        name = "api_key"
        in = "header"
    }
}

$definition = [PSCustomObject]@{
    Pet = [PSCustomObject]@{
        id = [PSCustomObject]@{
            type = "integer"
            format = "int64"
        }
        name = [PSCustomObject]@{
            type = "string"
            example = "doggie"
        }
    }
}

$externalDocs = $null

$doc = [SwaggerDoc]::New(
    $info,
    "petstore.swagger.io",
    "/v2",
    $tag,
    $path,
    $securityDefinitions,
    $definition,
    $externalDocs
)


# test path / method
$m = [SwaggerPathMethod]::New(
    @("pet"),
    "Find pet by ID",
    "Returns a single pet",
    @(
        [PSCustomObject]@{
            Name="petid"
            in="body"
            description="ID of pet to return"
            required=$true
            type="integer"
            format="int64"
        },
        [PSCustomObject]@{
            Name="name"
            in="body"
            description="name of pet to return"
            required=$true
            type="string"
        }
    )
)

$p = [SwaggerPath]::New("/pet/{petId}")
$p.AddGetMethod($m)
$p.AddPostMethod($m)
$paths = [PSCustomObject]@{
    $p.Path = $p
} 

# test header parser
$routes = Get-PolarisRoute
$route = $routes[1]
$header = Get-RouteHeader -ScriptBlock $route.Scriptblock.ToString()
$parsedHeader = Invoke-ParseRouteHeader -RouteHeader $header
$parsedHeader.Input

# test path / method with response
$m = [SwaggerPathMethod]::New(
    @("pet"),
    "Find pet by ID",
    "Returns a single pet",
    @(
        [PSCustomObject]@{
            Name="petid"
            in="body"
            description="ID of pet to return"
            required=$true
            type="integer"
            format="int64"
        },
        [PSCustomObject]@{
            Name="name"
            in="body"
            description="name of pet to return"
            required=$true
            type="string"
        }
    )
)

$m.SetDefaultResponse("GET", "User")

#>

# test generator
. C:\source\repos\polaris-swagger\SwaggerDocGenerator\class\SwaggerDoc.ps1
. C:\source\repos\polaris-swagger\SwaggerDocGenerator\class\SwaggerDocGenerator.ps1
. C:\source\repos\polaris-swagger\TestClass\class\TestUser.ps1
. C:\source\repos\polaris-swagger\SwaggerDocGenerator\function\public\New-SwaggerDocGenerator.ps1
. C:\source\repos\polaris-swagger\SwaggerDocGenerator\function\public\Get-RouteHeader.ps1
. C:\source\repos\polaris-swagger\SwaggerDocGenerator\function\public\Invoke-ParseRouteHeader.ps1
# start polaris
. C:\source\repos\polaris-swagger\TestPolaris\test-polaris.ps1
# create swagger doc
$a = New-SwaggerDocGenerator -Type "Polaris" `
                             -Url "http://localhost" `
                             -APIVersion "1.0" `
                             -Title "Test Polaris API" `
                             -Description "This an example doc" `
                             -DocumentVersion "1.0.0" `
                             -ContactEmail "sandro.bormolini@itnetx.ch"


$document = $a.Documentation.ConvertToJson()

# clear
Clear-Polaris
Stop-Polaris

<#

$doc.paths.($path.PSObject.Properties.Name) = $path.($path.PSObject.Properties.Name).ConvertToJson()

foreach($path in $this.paths)
{
    #$doc.paths = $this.paths.ConvertToJson()
    $doc.paths.($path.PSObject.Properties.Name) = $path.($path.PSObject.Properties.Name).ConvertToJson()
}
foreach ($definition in $this.definitions)
{
    $doc.definitions.($definition.PSObject.Properties.Name) = $definition
}

  # replace paths
        $sb = [System.Text.StringBuilder]::New()
        [void]$sb.Append("{`n")
        foreach ($path in $this.paths)
        {
            [void]$sb.Append(('"' + $path.PSObject.Properties.Name + '": ' + $path.($path.PSObject.Properties.Name).ConvertToJson() + ','))
        }
        [void]$sb.Remove($sb.Length-1, 1)
        [void]$sb.Append("`n}")
        $docAsString = $docAsString.Replace('"[ReplaceStringPaths]"', $sb.ToString())

  # replace definiton
        $sb = [System.Text.StringBuilder]::New()
        [void]$sb.Append("{`n")
        foreach ($definition in $this.definitions)
        {
            [void]$sb.Append(('"' + $definition.PSObject.Properties.Name + '": ' + $definition.($definition.PSObject.Properties.Name).ConvertToJson() + ','))
        }
        [void]$sb.Remove($sb.Length-1, 1)
        [void]$sb.Append("`n}")
        $docAsString = $docAsString.Replace('"[ReplaceStringDefinitions]"', $sb.ToString())

#>
