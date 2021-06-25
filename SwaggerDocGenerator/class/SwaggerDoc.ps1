<#
    Swagger class definitons
#>

Enum HttpRequestMethod
{
    GET = 0
    POST = 1
    PUT = 2
    DELETE = 3
}

# components
class SwaggerObject : System.Object 
{
    #hidden [System.String[]] $JSONExceptions

    # default constructor
    SwaggerObject()
    {}

    [string] ToString()
    {
        $sb = [System.Text.StringBuilder]::New()
        $propertyNames = $this.GetType().GetProperties().Where({$_.DeclaringType.Name -eq $this.GetType().Name}).Name
        foreach($propertyName in $propertyNames)
        {
            if ($null -ne $this.($propertyName))
            {
                [void]$sb.Append("$($propertyName): $($this.($propertyName).ToString())`n")
            }
            else 
            {
                [void]$sb.Append("$($propertyName): null")
            }
        }
        return $sb.ToString()
    }

    [string] ConvertToJson()
    {
        # convert to full length > paths are not converted!
        # exlude helper property
        return (ConvertTo-Json -InputObject $this -Depth 4)
    }
}

class SwaggerTag : SwaggerObject
{
    [System.String] $name
    [System.String] $description
    [SwaggerExternalDoc] $externalDocs

    # default constructor
    SwaggerTag($Name, $Description)
    {
        $this.name = $Name
        $this.description = $Description
    }

    SwaggerTag($Name, $Description, $ExternalDocs)
    {
        $this.name = $Name
        $this.description = $Description
        $this.externalDocs = $ExternalDocs
    }

    SwaggerTag($Name, $Description, $ExternalDocDescription, $ExternalDocURL)
    {
        $this.name = $Name
        $this.description = $Description
        $this.externalDocs = [SwaggerExternalDoc]::new($ExternalDocDescription, $ExternalDocURL)
    }

    [void] AddExternalDoc([SwaggerExternalDoc]$ExternalDoc)
    {
        $this.externalDocs = $ExternalDoc
    }
}

class SwaggerInfo : SwaggerObject
{
    [System.String] $description
    [System.String] $version
    [System.String] $title
    [System.String] $termsOfService
    [System.Object] $contact
    [System.Object] $license

    SwaggerInfo($Description, $Version, $Title, $Email)
    {
        $this.description = $Description
        $this.version = $Version
        $this.title = $Title
        $this.contact = [PSCustomObject]@{
            email = $Email
        }
    }

    SwaggerInfo($Description, $Version, $Title, $TermsOfService, $Contact, $License)
    {
        $this.description = $Description
        $this.version = $Version
        $this.title = $Title
        $this.termsOfService = $TermsOfService
        $this.contact = $Contact
        $this.license = $License
    }

    # default constructor
    SwaggerInfo($Description, $Version, $Title, $TermsOfService, $Email, $LicenseName, $LicenseUrl)
    {
        $this.description = $Description
        $this.version = $Version
        $this.title = $Title
        $this.termsOfService = $TermsOfService
        $this.contact = [PSCustomObject]@{
            email = $Email
        }
        $this.license = [PSCustomObject]@{
            name = $LicenseName
            url = $LicenseUrl
        }
    }
}

class SwaggerExternalDoc : SwaggerObject
{
    [string] $description
    [string] $url

    # default constructor
    SwaggerExternalDoc($Description, $Url)
    {
        $this.description = $Description
        $this.url = $Url
    }
}

class SwaggerPath : SwaggerObject
{
    # helper property
    hidden [System.String] $Path

    SwaggerPath($Path)
    {
        $this.Path = $Path
    }

    [void] AddMethod(
        [HttpRequestMethod]$Method,
        [SwaggerPathMethod]$PathMethod
        
    )
    {
        Add-Member -InputObject $this `
                   -MemberType NoteProperty `
                   -Name $Method.ToString().ToLower() `
                   -Value $PathMethod
    }

    [void] AddGetMethod($PathMethod)
    {
        $this.AddMethod([HttpRequestMethod]::GET, [SwaggerPathMethod]$PathMethod)
    }

    [void] AddPostMethod($PathMethod)
    {
        $this.AddMethod([HttpRequestMethod]::POST, [SwaggerPathMethod]$PathMethod)
    }

    [void] AddPutMethod($PathMethod)
    {
        $this.AddMethod([HttpRequestMethod]::PUT, [SwaggerPathMethod]$PathMethod)
    }

    [void] AddDeleteMethod($PathMethod)
    {
        $this.AddMethod([HttpRequestMethod]::DELETE, [SwaggerPathMethod]$PathMethod)
    }

    [string] ConvertToJson()
    {
        # exlude helper (hidden) property
        return Select-Object -InputObject $this -Property $this.PSObject.Properties.Name | ConvertTo-Json -Depth 4
    } 
}

class SwaggerPathMethod : SwaggerObject
{ 
    #hidden [HttpRequestMethod] $Method

    [System.String[]] $tags   
    [System.String] $summary
    [System.String] $description
    #[System.String] $operationId
    [System.String[]] $consumes = @("application/json")
    [System.String[]] $produces = @("application/json")
    [System.Object[]] $parameters
    [System.Object] $responses
    [System.Object] $security

    # default constructor
    SwaggerPathMethod(
        [System.String[]]$Tags,
        [System.String]$Summary,
        [System.String]$Description,
        [System.Object[]]$Parameters
        #[System.Object]$Responses
    )
    {
        $this.tags = $Tags
        $this.summary = $Summary
        $this.description = $Description
        #$this.operationId = $OperationId
        $this.parameters = $Parameters
        #$this.responses = $Responses

        # default
        $this.security = @(
            [PSCustomObject]@{
                api_key = @()
            }
        )
    }

    SwaggerPathMethod($Tags, $Summary, $Description, $Parameters, $Responses, $Security)
    {
        $this.tags = $Tags
        $this.summary = $Summary
        $this.description = $Description
        #$this.operationId = $OperationId
        $this.parameters = $Parameters
        $this.responses = $Responses
        $this.security = $Security
    }

    [void] SetDefaultResponse()
    {
        # default
        $this.responses = [PSCustomObject]@{
            default = [PSCustomObject]@{ 
                description = "Successful operation"
            }
        }
    }

    [void] SetDefaultResponse($Method, $Type)
    {
        # default with preset
        $this.responses = [PSCustomObject]@{ }
        switch ($Method) 
        {
            GET 
            { 
                if ($null -ne $Type)
                { 
                    $this.AddResponse(200, "Successful operation", $Type) 
                }
                else 
                {
                    $this.AddResponse(200, "Successful operation")
                }
                $this.AddResponse(404, "Object not found")
            }
            POST 
            { 
                if ($null -ne $Type)
                { 
                    $this.AddResponse(200, "Successful operation", $Type) 
                }
                else 
                {
                    $this.AddResponse(200, "Successful operation")
                }
                $this.AddResponse(405, "Invalid input")
            }
            PUT 
            {
                $this.AddResponse(200, "Successful operation")
                $this.AddResponse(400, "Invalid input")
                $this.AddResponse(404, "Object not found")
                $this.AddResponse(405, "Invalid input")
            }
            DELETE 
            { 
                $this.AddResponse(200, "Successful operation")
                $this.AddResponse(400, "Invalid input")
                $this.AddResponse(404, "Object not found")
            }
        }
    }

    [void] AddResponse($Code, $Description)
    {
        if ($null -eq $this.responses)
        {
            $this.responses = [PSCustomObject]@{}
        }
        
        Add-Member -InputObject $this.responses `
                   -MemberType NoteProperty `
                   -Name $Code.ToString() `
                   -Value ([PSCustomObject]@{description=$Description})
    }

    [void] AddResponse($Code, $Description, $Type)
    {
        if ($null -eq $this.responses)
        {
            $this.responses = [PSCustomObject]@{}
        }    
        
        # workaround for escaping '$' (vscode bug?)
        $ref = '$ref'
        $value = [PSCustomObject]@{ 
            description=$Description;
            schema=[PSCustomObject]@{$ref="#/definitions/$($Type)"};
        }

        Add-Member -InputObject $this.responses `
                   -MemberType NoteProperty `
                   -Name $Code.ToString() `
                   -Value $value
    }
}

class SwaggerObjectDefinition : SwaggerObject
{
    # helper property
    hidden [System.String] $Name

    [System.String] $type
    [System.Object] $properties

    # default constructor
    SwaggerObjectDefinition(
        [System.String] $Name,
        [System.String] $Type
    )
    {
        $this.Name = $Name
        $this.type = $Type
        $this.properties = [PSCustomObject]@{}
    }

    SwaggerObjectDefinition(
        [System.String] $Name,
        [System.String] $Type, 
        [System.Object] $Properties
    )
    {
        $this.Name = $Name
        $this.type = $Type
        $this.properties = $Properties
    }

    [void] AddProperty(
        [System.String] $PropertyName,
        [System.Object] $Property
    )
    {
        Add-Member -InputObject $this.properties `
                   -MemberType NoteProperty `
                   -Name $PropertyName `
                   -Value $Property
    }

    [string] ConvertToJson()
    {
        # exlude helper (hidden) property
        return Select-Object -InputObject $this -Property $this.PSObject.Properties.Name | ConvertTo-Json -Depth 4
    } 
}

# main configuration document
class SwaggerDoc : SwaggerObject
{
    [System.String] $swagger = "2.0"
    [SwaggerInfo] $info
    [System.String] $host
    [System.String] $basePath
    [SwaggerTag[]] $tags = @()
    [System.String[]] $schemes = @("https", "http")
    [System.Object] $paths
    [System.Object] $securityDefinitions
    [System.Object] $definitions
    [SwaggerExternalDoc] $externalDocs

    # default constructor
    SwaggerDoc(
        [SwaggerInfo] $Info, 
        [System.String] $APIHost, 
        [System.String] $BasePath, 
        [SwaggerTag[]] $Tags, 
        [SwaggerExternalDoc] $ExternalDocs
    )
    {
        $this.info = $Info
        $this.host = $APIHost
        $this.basePath = $BasePath
        $this.tags = $Tags
        $this.paths = [PSCustomObject]@{}
        $this.securityDefinitions = [PSCustomObject]@{}
        $this.definitions = [PSCustomObject]@{}
        $this.externalDocs = $ExternalDocs
    }

    SwaggerDoc(
        [SwaggerInfo] $Info, 
        [System.String] $APIHost, 
        [System.String] $BasePath, 
        [SwaggerTag[]] $Tags, 
        [SwaggerPath] $Paths,
        [System.Object] $SecurityDefinitions,
        [SwaggerObjectDefinition] $Definitions, 
        [SwaggerExternalDoc] $ExternalDocs
    )
    {
        $this.info = $Info
        $this.host = $APIHost
        $this.basePath = $BasePath
        $this.tags = $Tags
        $this.paths = $Paths
        $this.securityDefinitions = $SecurityDefinitions
        $this.definitions = $definitions
        $this.externalDocs = $ExternalDocs
    }

    [void] AddDefinition(
        [SwaggerObjectDefinition]$Definition
    )
    {
        Add-Member -InputObject $this.definitions `
                   -MemberType NoteProperty `
                   -Name $Definition.Name `
                   -Value $Definition
    }

    [void] AddPath(
        [SwaggerPath]$Path
    )
    {
        Add-Member -InputObject $this.paths `
                   -MemberType NoteProperty `
                   -Name $Path.Path `
                   -Value $Path
    }

    [void] AddTag(
        [SwaggerTag]$Tag
    )
    {
        $this.tags += $Tag
    }

    [void] SaveToFile(
        [System.String] $FilePath
    )
    {
        $this.ConvertToJson() | Out-File -FilePath $FilePath
    }

    [string] ConvertToJson()
    {
        <##>
        # replace "paths" / "definitions" in object with converted string of paths
        # replace definition with helper Name property!
        $ReplaceNestedObject = {
            param($Document, $Collection, $ReplaceString)

            $sb = [System.Text.StringBuilder]::New()
            [void]$sb.Append("{")
            foreach ($item in $Collection.PSObject.Properties.Name)
            {
                [void]$sb.Append( ("`n" + '"' + $item + '": ' + $Collection.$item.ConvertToJson() + ',') )
            }
            [void]$sb.Remove($sb.Length-1, 1)
            [void]$sb.Append("`n}")
            
            return $Document.Replace($ReplaceString, $sb.ToString())
        }
        
        # copy instance and set placeholders
        $doc = $this.Copy()
        $doc.paths = "[ReplaceStringPaths]"
        #$doc.definitions = "[ReplaceStringDefinitions]"
        $docAsString = $doc | ConvertTo-Json -Depth 7 -WarningAction:Ignore

        # replace paths
        $docAsString = $ReplaceNestedObject.Invoke(
            $docAsString, 
            $this.paths, 
            '"[ReplaceStringPaths]"'
        )

        <# replace definiton
        $docAsString = $ReplaceNestedObject.Invoke(
            $docAsString, 
            $this.definitions, 
            '"[ReplaceStringDefinitions]"'
        )
        #>

        return $docAsString
    }

    [SwaggerDoc] Copy()
    {
        $newCopyObject = [SwaggerDoc]::New(
            $this.info,
            $this.host,
            $this.basePath, 
            $this.tags, 
            $this.externalDocs
        )

        # copy parsed obejct
        $newCopyObject.paths = $this.paths
        $newCopyObject.definitions = $this.definitions

        return $newCopyObject 
    }
    
}