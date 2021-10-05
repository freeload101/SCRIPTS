# example XML parse
(Invoke-RestMethod -Uri 'https://plex.tv/api/users/?X-Plex-Token=_TOKEN_').MediaContainer.User|select Username, Email |ConvertTo-Csv -NoTypeInformation 

# replace in action
$output | -replace '.*username=\"(.*)" email=\"(.*)" recommend.*','$1,$2

# for each  string ?? object?? 
| foreach { -f $_.Email } 

# I don't even know...powershell had a object and I could not for the life of me figure out how to use it .. Enumerate-ObjectProperties does not work anymore but it use to .. 


------------

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

 

-----------

|Out-String -Stream

Write-Output '---------outputing data ---------------------'
$data| Measure-Object -Line
Write-Output '--------TYPE---------------'
$data.GetType().Name
Write-Output '---------Select-String---------------------'
#$data| Select-String -Pattern '.*adam.*' -AllMatches -List
Write-Output $data| Select-String -Pattern 'adam' -AllMatches  -SimpleMatch

Write-Output '---------CHECK PATTERN---------------------'
$data9| ForEach-Object {
Write-Output "This is an object"
$_ | Select-String -Pattern '.*username.*'
}

Write-Output '--------TYPE---------------'
$data.GetType().BaseType



Write-Output '--------write data---------------'
Write-Output $CONTENT1.length
Write-Output '--------object_properties---------------'

$CONTENT1.RawContent |Select-String -SimpleMatch -Pattern 'adam'  
join ","



Write-Output '--------object_properties---------------'

$data| Get-Member -MemberType Property

foreach($object_properties in $data.PsObject.Properties)
{
    # Access the name of the property
    $object_properties.Name

    # Access the value of the property
    $object_properties.Value
}



