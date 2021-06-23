# Implement your module commands in this script.

# Get public and private function definition files.
$class = Get-ChildItem -Path "$($PSScriptRoot)\class\" -Filter "*.ps1"
$functions = Get-ChildItem -Path "$($PSScriptRoot)\function\" -Recurse -Filter "*.ps1"

# Dot source the files
foreach ($item in @($class, $functions)) 
{
    try
    {
        Write-Verbose -Message "Importing $($item.FullName)"
        . $item.FullName
    }
    catch 
    {
        Write-Error -Message "Failed to import function $($item.FullName):`n$($_)"
    }
}


# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function (Get-ChildItem -Path "$($PSScriptRoot)\function\public\*.ps1").BaseName