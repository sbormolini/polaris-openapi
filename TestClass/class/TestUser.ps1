class TestUser : System.Object
{
    [Guid] $Id
    [String] $Name
    [Int] $Age

    TestUser()
    {}

    TestUser($Name, $Age)
    {
        $this.Id = [Guid]::NewGuid()
        $this.Name = $Name
        $this.Age = $Age
    }

    [object] GetDefinition()
    {
        return [TestUser].GetMembers().Where({$_.MemberType -eq "Property"}) | 
            Select-Object -Property Name, PropertyType
    }
}