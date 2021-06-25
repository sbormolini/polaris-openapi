Enum APISourceType
{
    Polaris = 0
}

# Implementation of Factory - Used to create objects.
class SwaggerDocGenerator : System.Object
{
    hidden [System.Guid] $Id
    [System.String] $Url
    [APISourceType] $Type
    [System.String] $APIVersion
    [SwaggerDoc] $Documentation

    # global doc properties
    [System.String] $Title
    [System.String] $Description
    [System.String] $DocumentVersion
    [System.String] $ContactEmail

    SwaggerDocGenerator()
    {
        $this.Documentation = [SwaggerDoc]::New()
    }

    # default constructor
    SwaggerDocGenerator(
        [System.String] $Type,
        [System.String] $Url,
        [System.String] $APIVersion,
        [System.String] $Title,
        [System.String] $Description,
        [System.String] $DocumentVersion,
        [System.String] $ContactEmail
    )
    {
        $this.Id = [System.Guid]::NewGuid()
        $this.URl = $Url
        $this.Type = [APISourceType]::$Type
        $this.APIVersion = $APIVersion
        $this.Title = $Title
        $this.Description = $Description
        $this.DocumentVersion = $DocumentVersion
        $this.ContactEmail = $ContactEmail

        try 
        {
            switch ($Type)
            {
                Polaris
                {
                    # check if polaris is online
                    if ($null -eq (Get-Polaris))
                    {
                        throw "No local Polaris instance is online"
                    }
                    else
                    {
                        $this.GenerateFromPolaris()
                    }
                }
                default
                {
                    throw [NotSupportedException]
                }
            }
        }
        catch 
        {
            throw "Unhandled error occured: $($_.Exception.Message)"
        }
    }

    # Polaris specific methods
    [void] GenerateFromPolaris()
    {
        # generate doc componentes
        $info = [SwaggerInfo]::New(
            $this.Description,
            $this.DocumentVersion,
            $this.Title,
            $this.ContactEmail
        )

        $externalDocs = [SwaggerExternalDoc]::New(
            "External TestBos Wiki",
            "https://wiki.testbos.local/display/SMARTICT/Swagger+Parser"
        )

        # tags not implemented yet
        $tags = $null

        # create swagger doc
        $this.Documentation = [SwaggerDoc]::New(
            $info,
            $this.Url,
            '',
            $tags, 
            $externalDocs
        )

        # parse routes
        $routes = Get-PolarisRoute
        foreach ($route in $routes)
        {
            $header = Get-RouteHeader -ScriptBlock $route.Scriptblock.ToString()
            if ($header)
            {
                $parsedHeader = Invoke-ParseRouteHeader -RouteHeader $header
                # add defintion
                if ($null -ne $parsedHeader.Output.TypeDefinition)
                {
                    if ( -not[bool]($this.Documentation.definitions.PSObject.Properties.Name -match $parsedHeader.Output.Type) )
                    {
                        $definition = [SwaggerObjectDefinition]::New($parsedHeader.Output.Type, "object", $parsedHeader.Output.TypeDefinition)
                        $this.Documentation.AddDefinition($definition)
                    } 
                }
                
                # add path and methods
                $pathMethod = [SwaggerPathMethod]::New(
                    $null, # tags not implemented
                    $null, # summary not implemented
                    $null, # description not implemented
                    $parsedHeader.Input
                )

                # set default response
                $pathMethod.SetDefaultResponse($route.Method, $parsedHeader.Output.Type)

                # check if path already exists
                $path = $this.Documentation.paths.$($route.Path)
                if ($null -eq $path)
                {
                    $path = [SwaggerPath]::New($route.Path)
                    $this.Documentation.AddPath($path)
                }
                $path.AddMethod([HttpRequestMethod]::($route.Method), $pathMethod)
            }
        }

        #return $this.Documentation
    }
}