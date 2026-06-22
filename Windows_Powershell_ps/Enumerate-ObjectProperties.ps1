function Enumerate-ObjectProperties {

  <#
    .SYNOPSIS
        Enumerate Powershell Object Properties
    .PARAMETER TYPE
        Object or String .. hell I have no idea .. GD powershell
    #>
    [CmdletBinding()]
    param (

[psobject] $Object,

[int32] $Depth = 10,

[string] $Root
        )
 
 


Write-Output $($Object.PSObject.Properties | Format-Table @{ Label = 'Type'; Expression = { "[$($($_.TypeNameOfValue).Split('.')[-1])]" } }, Name, Value -AutoSize -Wrap | Out-String)



foreach ($Property in $Object.PSObject.Properties) {

# Strings always have a single property "Length". Do not enumerate this.

if (($Property.TypeNameOfValue -ne 'System.String') -and ($($Object.$($Property.Name).PSObject.Properties)) -and ($Level -le $Depth)) {

$NewRoot = $($($Root + '.' + $($Property.Name)).Trim('.'))

$Level++

Write-Output "Property: $($NewRoot) (Level: $Level)"

Enumerate-ObjectProperties -Object $($Object.$($Property.Name)) -Root $NewRoot

$Level--

}

}

}


$test = (Invoke-RestMethod -Uri 'https://api.jokes.one/jod')

Enumerate-ObjectProperties -Object $test
