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
function Get-RouteHeader
{
   [CmdletBinding(PositionalBinding=$false,
               ConfirmImpact="Low")]
   [Alias()]
   [OutputType([String])]
   param
   (
      [Parameter(
         Mandatory = $true,
         ValueFromPipelineByPropertyName = $true,
         Position = 0
      )]
      [ValidateNotNull()]
      [ValidateNotNullOrEmpty()]
      [String]$ScriptBlock,

      [Parameter(
         Mandatory = $false,
         ValueFromPipelineByPropertyName = $true,
         Position = 1
      )]
      [ValidateNotNull()]
      [ValidateNotNullOrEmpty()]
      [String]$StartPattern = "<#API:Definition",

      [Parameter(
         Mandatory = $false,
         ValueFromPipelineByPropertyName = $true,
         Position = 2
      )]
      [ValidateNotNull()]
      [ValidateNotNullOrEmpty()]
      [String]$EndPattern = "#>",

      [Parameter(
         Mandatory = $false,
         ValueFromPipelineByPropertyName = $true,
         Position = 3
      )]
      [ValidateNotNull()]
      [ValidateNotNullOrEmpty()]
      [ValidateSet("File","Script")]
      [String]$Method = "Script"
   )
   $header = $null
   switch ($Method) 
   {
      Script
      {
         $start = $ScriptBlock.IndexOf("<#API:Definition")
         $end = $ScriptBlock.IndexOf("#>")

         if (($start -eq -1) -or ($end -eq -1))
         {
            #throw "API Defintion not found!"
            Write-Verbose -Message "API Defintion not found!"
         }
         else 
         {
            $header = $ScriptBlock.Substring($start, ($end + $EndPattern.Length))
         }
      }
      File 
      { 
         <#
            $matchStart = Get-ChildItem -Path $filePath | 
               Select-String -Pattern '<#API:Definition'

            $matchEnd = Get-ChildItem -Path $filePath | 
               Select-String -Pattern '#'

            if  ($matchStart.LineNumber -ne 1)
            {
               Write-Warning -Message "API Defintion not found at the begin of script"
            }

            $section = Get-Content -Path $filePath  | 
               Select-Object -First $matchEnd.LineNumber
         #>

         throw [System.NotImplementedException] 
      }
   }

   return $header
}